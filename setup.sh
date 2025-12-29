#!/bin/bash

# ==========================================
# Dotfiles Setup Script for WSL Ubuntu (Japanese & Rich UI)
# ==========================================

# --- Gum Installation & Helper Functions ---

install_gum() {
    if ! command -v gum &> /dev/null; then
        echo "📦 Installing gum for reliable UI..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y gum
    fi
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

# --- Initialization ---

# Install gum first to ensure UI works
# We assume sudo is available. If not, this might fail, but standard WSL Ubuntu users have sudo.
if [ -n "$PASSWORD" ]; then
    echo "$PASSWORD" | sudo -S ls /root >/dev/null 2>&1
else
    # Simple check to warm up sudo or prompt if needed before gum is ready
    sudo ls /root >/dev/null 2>&1
fi

install_gum

# --- UI Functions using Gum ---

log_header() {
    gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" "$1"
}

log_step() {
    gum style --foreground 99 "🚀 $1"
}

log_success() {
    gum style --foreground 82 "✅ $1"
}

log_error() {
    gum style --foreground 196 "❌ $1"
}

log_info() {
    gum style --foreground 39 "ℹ️  $1"
}

confirm() {
    gum confirm "$1" || exit 1
}

# --- Main Script ---

clear
log_header "Dotfiles Setup for WSL"

log_info "セットアップを開始します..."
log_info "管理者権限(sudo)が必要です。"

# 1. System Update
log_step "システムを更新しています..."
gum spin --spinner dot --title "apt updateを実行中..." -- run_sudo apt update -y
log_success "システム更新完了！"

# 2. Install Essentials
log_step "必須ツールをインストール中..."
PACKAGES="zsh vim git curl unzip build-essential"
gum spin --spinner line --title "インストール中: $PACKAGES" -- run_sudo apt install -y $PACKAGES
log_success "必須ツールインストール完了！"

# 3. Install Homebrew
log_step "Homebrewを確認中..."
if ! command -v brew &> /dev/null; then
    log_info "Homebrewをインストールします (少し時間がかかります)"
    # Install Homebrew (Non-interactive)
    gum spin --spinner minidot --title "Homebrewをダウンロード＆インストール中..." -- \
        /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for this session
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    fi
    log_success "Homebrewインストール完了！"
else
    log_success "Homebrewは既にインストールされています"
fi

# 4. Install Tools via Homebrew
log_step "便利ツールをインストール中..."
TOOLS="sheldon eza fzf"
gum spin --spinner points --title "Brewインストール中: $TOOLS" -- brew install $TOOLS
log_success "便利ツールインストール完了！"

# 5. Download Dotfiles
log_step "設定ファイルをダウンロード中..."

download_file() {
    local url=$1
    local dest=$2
    local filename=$(basename "$dest")
    
    gum spin --spinner globe --title "$filename をダウンロード中..." -- curl -L -o "$dest" "$url"
    
    if [ $? -eq 0 ]; then
        log_success "$filename ダウンロードOK"
    else
        log_error "$filename のダウンロードに失敗しました"
    fi
}

BASE_URL="https://raw.githubusercontent.com/sweetfish329/dotfiles/main"

download_file "$BASE_URL/.zshrc" "$HOME/.zshrc"
download_file "$BASE_URL/.p10k.zsh" "$HOME/.p10k.zsh"
download_file "$BASE_URL/.vimrc" "$HOME/.vimrc"

mkdir -p "$HOME/.config/sheldon"
download_file "$BASE_URL/.plugins/sheldon/plugins.toml" "$HOME/.config/sheldon/plugins.toml"

# 6. Set Default Shell
log_step "デフォルトシェルを設定中..."
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    run_sudo chsh -s "$(which zsh)" "$USER"
    log_success "デフォルトシェルをzshに変更しました"
else
    log_info "デフォルトシェルは既にzshです"
fi

# 7. Initialize Sheldon
log_step "プラグインを初期化中..."
gum spin --spinner moon --title "sheldon lock を実行中..." -- zsh -c "sheldon lock"
log_success "プラグイン準備完了！"

# Completion
clear
log_header "Setup Complete! 🎉"

gum style \
	--foreground 212 --border-foreground 212 --border rounded --align center --width 50 --margin "1 2" --padding "1 2" \
	"セットアップが完了しました！" \
	"" \
	"Ubuntuターミナルを再起動してください。" \
	"再起動後、Powerlevel10kの設定が始まります。" \
	"" \
	"HackGen NFフォントの設定もお忘れなく！"

