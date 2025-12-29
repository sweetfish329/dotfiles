#!/bin/bash

# ==========================================
# Dotfiles Setup Script for WSL Ubuntu
# ==========================================

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
    exit 1
}

# Wrapper for sudo commands
PASSWORD=$1
run_sudo() {
    if [ -n "$PASSWORD" ]; then
        echo "$PASSWORD" | sudo -S "$@" 2>/dev/null
    else
        sudo "$@"
    fi
}

# --- Main Script ---

clear
log_header "Dotfiles Setup for WSL"

log_info "セットアップを開始します..."
log_info "管理者権限(sudo)が必要です。"

# 1. Validation Sudo
if [ -n "$PASSWORD" ]; then
    echo "$PASSWORD" | sudo -S ls /root >/dev/null 2>&1
else
    # Sudo warm-up
    sudo ls /root >/dev/null 2>&1
fi

if [ $? -ne 0 ]; then
    log_error "管理者権限の取得に失敗しました。パスワードを確認してください。"
    exit 1
fi
log_success "管理者権限を確認しました。"

# 2. System Update
log_step "ステップ 1/7: システム更新"
log_task "apt updateを実行中"
run_sudo apt update -y >/dev/null 2>&1
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 3. Install Essentials
log_step "ステップ 2/7: 必須ツールのインストール"
PACKAGES="zsh vim git curl unzip build-essential"
log_task "インストール中: $PACKAGES"
run_sudo apt install -y $PACKAGES >/dev/null 2>&1
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 4. Install Homebrew
log_step "ステップ 3/7: Homebrewのセットアップ"
if ! command -v brew &> /dev/null; then
    log_task "Homebrewをダウンロード＆インストール中"
    /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        finish_task
        
        # Add to PATH for this session
        if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
        fi
        log_success "Homebrewインストール完了"
    else
        fail_task
    fi
else
    log_success "Homebrewは既にインストールされています"
fi

# 5. Install Tools via Homebrew
log_step "ステップ 4/7: 便利ツールのインストール"
TOOLS="sheldon eza fzf"
log_task "Brewインストール中: $TOOLS"
brew install $TOOLS >/dev/null 2>&1
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# 6. Download Dotfiles
log_step "ステップ 5/7: 設定ファイルのダウンロード"

download_file() {
    local url=$1
    local dest=$2
    local filename=$(basename "$dest")
    
    log_task "$filename をダウンロード"
    curl -L -o "$dest" "$url" >/dev/null 2>&1
    
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

mkdir -p "$HOME/.config/sheldon"
download_file "$BASE_URL/.plugins/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

# 7. Set Default Shell
log_step "ステップ 6/7: シェル設定"
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    log_task "デフォルトシェルをzshに変更"
    run_sudo chsh -s "$(which zsh)" "$USER" >/dev/null 2>&1
    if [ $? -eq 0 ]; then finish_task; else fail_task; fi
else
    log_info "デフォルトシェルは既にzshです"
fi

# 8. Initialize Sheldon
log_step "ステップ 7/7: プラグインの初期化"
log_task "sheldon lock を実行中"
zsh -c "sheldon lock" >/dev/null 2>&1
if [ $? -eq 0 ]; then finish_task; else fail_task; fi

# Completion
echo -e "\n${MAGENTA}${BOLD}========================================${RESET}"
echo -e "${GREEN}${BOLD}✨ セットアップが完了しました！ 🎉${RESET}"
echo -e "${MAGENTA}${BOLD}========================================${RESET}"
echo -e "\n${CYAN}次のステップ:${RESET}"
echo -e "1. Ubuntuターミナルを一度閉じて、再起動してください。"
echo -e "2. 設定は自動的に適用されます。"
echo -e "\n${YELLOW}※ HackGen NFフォントの設定もお忘れなく！${RESET}\n"
