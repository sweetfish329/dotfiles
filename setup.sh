#!/bin/bash

# ==========================================
# Dotfiles Setup Script for WSL Ubuntu
# ==========================================

LOGFILE="/tmp/dotfiles_setup.log"
rm -f "$LOGFILE"
touch "$LOGFILE"

# Colors & Styles
ESC=$(printf '\033')
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
BLUE="${ESC}[34m"
CYAN="${ESC}[36m"
MAGENTA="${ESC}[35m"
YELLOW="${ESC}[33m"

# Icons
ICON_ROCKET="🚀"
ICON_CHECK="✅"
ICON_ERROR="❌"
ICON_INFO="ℹ️ "
ICON_GEAR="⚙️ "
ICON_PKG="📦"

# --- UI Functions ---

log_header() {
    local title="$1"
    local len=${#title}
    local border=$(printf '%.0s=' $(seq 1 $((len + 4))))
    echo -e "\n${MAGENTA}${BOLD}${border}${RESET}"
    echo -e "${MAGENTA}${BOLD}| ${title} |${RESET}"
    echo -e "${MAGENTA}${BOLD}${border}${RESET}\n"
}

log_step() {
    echo -e "${BLUE}${BOLD}${ICON_ROCKET} $1${RESET}"
}

log_success() {
    echo -e "${GREEN}${BOLD}${ICON_CHECK} $1${RESET}"
}

log_error() {
    echo -e "${RED}${BOLD}${ICON_ERROR} $1${RESET}"
}

log_info() {
    echo -e "${CYAN}${ICON_INFO} $1${RESET}"
}

log_task() {
    echo -n -e "${YELLOW}${ICON_GEAR} $1... ${RESET}"
}

finish_task() {
    echo -e "${GREEN}OK!${RESET}"
}

fail_task() {
    echo -e "${RED}FAILED!${RESET}"
    echo -e "\n${RED}エラー詳細 (直近20行):${RESET}"
    tail -n 20 "$LOGFILE"
    echo -e "\n${RED}ログファイル: $LOGFILE${RESET}"
    exit 1
}

# Wrapper for sudo commands
PASSWORD=$1
run_sudo() {
    if [ -n "$PASSWORD" ]; then
        echo "$PASSWORD" | sudo -S "$@" >>"$LOGFILE" 2>&1
    else
        sudo "$@" >>"$LOGFILE" 2>&1
    fi
}

log_cmd() {
    "$@" >>"$LOGFILE" 2>&1
}

# --- Main Script ---

clear
log_header "Dotfiles Setup for WSL"

log_info "セットアップを開始します..."
log_info "管理者権限(sudo)が必要です。"
log_info "詳細ログ: $LOGFILE"

# 1. Validation Sudo
if [ -n "$PASSWORD" ]; then
    echo "$PASSWORD" | sudo -S ls /root >/dev/null 2>&1
else
    sudo ls /root >/dev/null 2>&1
fi

if [ $? -ne 0 ]; then
    log_error "管理者権限の取得に失敗しました。パスワードを確認してください。"
    exit 1
fi
log_success "管理者権限を確認しました。"

# 1.5 Backup .bashrc
if [ -f "$HOME/.bashrc" ]; then
    BACKUP_NAME=".bashrc.bk.$(date +%Y%m%d)"
    log_task ".bashrc を $BACKUP_NAME にバックアップ"
    cp -f "$HOME/.bashrc" "$HOME/$BACKUP_NAME"
    if [ -f "$HOME/$BACKUP_NAME" ]; then finish_task; else fail_task; fi
fi

# 2. System Update
log_step "ステップ 1/7: システム更新"
log_task "apt updateを実行中"
run_sudo apt update -y
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 3. Install Essentials
log_step "ステップ 2/7: 必須ツールのインストール"
PACKAGES="zsh vim git curl unzip build-essential"
log_task "インストール中: $PACKAGES"
run_sudo apt install -y $PACKAGES
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 4. Install Homebrew
log_step "ステップ 3/7: Homebrewのセットアップ"
if ! command -v brew &> /dev/null; then
    log_task "Homebrewインストール準備"
    # Pre-check & Action: Create directory
    if [ ! -d "/home/linuxbrew/.linuxbrew" ]; then
        run_sudo mkdir -p /home/linuxbrew/.linuxbrew >/dev/null 2>&1
        run_sudo chown -R "$USER:$USER" /home/linuxbrew/.linuxbrew >/dev/null 2>&1
    fi
    finish_task

    log_task "Homebrewをダウンロード＆インストール中"
    # Action
    /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then fail_task; fi
    finish_task
    
    # Post-check: Configure PATH and Verify
    log_task "Homebrewの動作確認"
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        
        if command -v brew &> /dev/null; then
            finish_task
            
            # Action: Persist to .bashrc
            BASHRC_PATH="$HOME/.bashrc"
            BREW_ENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
            
            if ! grep -qF "$BREW_ENV" "$BASHRC_PATH"; then
                echo "$BREW_ENV" >> "$BASHRC_PATH"
                log_success ".bashrc にパスを追加しました"
            else
                log_info ".bashrc は設定済みです"
            fi
        else
            log_error "brewコマンドが見つかりません"
            fail_task
        fi
    else
        log_error "Homebrewディレクトリが見つかりません"
        fail_task
    fi
else
    log_success "Homebrewは既にインストールされています"
fi

# 5. Install Tools via Homebrew
log_step "ステップ 4/7: 便利ツールのインストール"
TOOLS="sheldon eza fzf"
log_task "Brewインストール中: $TOOLS"
log_cmd brew install $TOOLS
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 6. Download Dotfiles
log_step "ステップ 5/7: 設定ファイルのダウンロード"

download_file() {
    local url=$1
    local dest=$2
    local filename=$(basename "$dest")
    
    log_task "$filename をダウンロード"
    log_cmd curl -L -o "$dest" "$url"
    
    if [ $? -eq 0 ]; then
        finish_task
    else
        fail_task
    fi
}

BASE_URL="https://raw.githubusercontent.com/sweetfish329/dotfiles/main"

download_file "$BASE_URL/.zshrc" "$HOME/.zshrc"
download_file "$BASE_URL/.p10k.zsh" "$HOME/.p10k.zsh"
download_file "$BASE_URL/.vimrc" "$HOME/.vimrc"

# Inject Homebrew path to .zshrc (Must be before sheldon initialization)
if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
    log_task ".zshrc に Homebrew の設定を追記"
    BREW_ENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    
    # Pre-check: Check validity
    if ! grep -qF "$BREW_ENV" "$HOME/.zshrc"; then
        # Change
        echo "$BREW_ENV" | cat - "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
        
        # Post-check: Verify brew command works inside zsh
        if zsh -c "source $HOME/.zshrc && command -v brew"; then
            finish_task
        else
            log_error "Zsh内でのHomebrew認識に失敗しました"
            fail_task
        fi
    else
        log_info ".zshrc は設定済みです"
    fi
fi

mkdir -p "$HOME/.config/sheldon"
download_file "$BASE_URL/.plugins/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

# Initialize Sheldon (Must satisfy dependencies before sourcing .zshrc)
log_step "ステップ 6/7: プラグインの初期化"
log_task "sheldon lock を実行中"
log_cmd zsh -c "sheldon lock"
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 7. Set Default Shell
log_step "ステップ 7/7: シェル設定"
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    log_task "デフォルトシェルをzshに変更"
    run_sudo chsh -s "$(which zsh)" "$USER"
    if [ $? -eq 0 ]; then finish_task; else fail_task; fi
else
    log_info "デフォルトシェルは既にzshです"
fi



# Completion
echo -e "\n${MAGENTA}${BOLD}========================================${RESET}"
echo -e "${GREEN}${BOLD}✨ セットアップが完了しました！ 🎉${RESET}"
echo -e "${MAGENTA}${BOLD}========================================${RESET}"
echo -e "\n${CYAN}次のステップ:${RESET}"
echo -e "1. Ubuntuターミナルを一度閉じて、再起動してください。"
echo -e "2. 設定は自動的に適用されます。"
echo -e "\n${YELLOW}※ HackGen NFフォントの設定もお忘れなく！${RESET}\n"
