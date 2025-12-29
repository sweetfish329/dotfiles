# Dotfiles セットアップガイド

このガイドでは、WSL（Windows Subsystem for Linux）のUbuntuに便利なシェル環境を構築する手順を説明します。

---

## 🚀 セットアップ手順

### ステップ1: フォントをインストール（Windows側で実施）

ターミナルでアイコンを正しく表示するために、まずフォントをインストールします。

1. 以下のリンクを開く
   - <https://github.com/yuru7/HackGen/releases/latest>

2. 「**HackGen_NF_vX.X.X.zip**」（Xはバージョン番号）をダウンロード
   > ⚠️ 「NF」が付いているものを選んでね（Nerd Font対応版）

3. ダウンロードしたZIPファイルを展開（右クリック → すべて展開）

4. 展開したフォルダ内の `.ttf` ファイルを全選択 → 右クリック → 「インストール」

---

### ステップ2: ターミナルを開く

1. Windowsのスタートメニューで「**Ubuntu**」と検索
2. 「Ubuntu」アプリをクリックして起動
3. 黒い画面（ターミナル）が開きます

> 💡 **ヒント**: この後のコマンドは、この黒い画面に入力してEnterキーを押して実行します

---

### ステップ3: 基本パッケージをインストール

以下のコマンドを**1行ずつ**コピーして、ターミナルに貼り付けてEnterキーを押してください。

```bash
sudo apt update
```

> パスワードを聞かれたら、Ubuntuのパスワードを入力してEnterを押してください  
> （入力中は画面に何も表示されませんが、入力されています）

```bash
sudo apt install -y zsh vim git curl
```

---

### ステップ4: Homebrewをインストール

Homebrewは便利なツールをインストールするためのアプリです。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> ⏳ 途中でEnterキーを押すよう求められたら、押してください  
> インストールには数分かかります

インストールが終わったら、**以下のコマンドを実行**して設定を反映させます：

```bash
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Homebrewに必要な追加パッケージをインストールします：

```bash
sudo apt install -y build-essential
```

---

### ステップ5: 必要なツールをインストール

Homebrewを使って必要なツールをインストールします。

```bash
brew install sheldon eza fzf
```

---

### ステップ6: dotfilesをダウンロード

```bash
cd ~
git clone https://github.com/あなたのユーザー名/dotfiles.git
```

> ⚠️ 上のコマンドの「あなたのユーザー名/dotfiles」はリポジトリのURLに置き換えてね

---

### ステップ7: 設定ファイルを配置

以下のコマンドを**1行ずつ**実行してください：

```bash
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```

```bash
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
```

```bash
ln -sf ~/dotfiles/.vimrc ~/.vimrc
```

```bash
mkdir -p ~/.config/sheldon
```

```bash
ln -sf ~/dotfiles/.plugins/sheldon/plugins.toml ~/.config/sheldon/plugins.toml
```

---

### ステップ8: zshをデフォルトシェルに設定

```bash
chsh -s $(which zsh)
```

> パスワードを聞かれたら入力してEnterを押してください

---

### ステップ9: プラグインをインストール

```bash
zsh -c "sheldon lock"
```

---

### ステップ10: Windowsターミナルのフォント設定

1. Ubuntuのタブを右クリック → 「設定」
2. 左メニューから「Ubuntu」を選択
3. 「外観」タブをクリック
4. 「フォントフェイス」を「**HackGen Console NF**」に変更
5. 「保存」をクリック

---

### ステップ11: Ubuntuを再起動

1. ターミナルに `exit` と入力してEnterを押す
2. 再度「Ubuntu」アプリを起動する

---

## 🎨 初回起動時の設定

初めてzshを起動すると、**Powerlevel10k**の設定画面が表示されます。

質問に答えていくだけで、見た目のカスタマイズができます：

1. 「Does this look like a diamond?」→ 見えたら `y`、見えなければ `n`
2. 以降も見た目の好みに合わせて選択してください

> 💡 後で変更したい場合は `p10k configure` コマンドで再設定できます

---

## ✅ 完了

これでセットアップは完了です！🎉

ターミナルがカラフルになり、便利なコマンドが使えるようになりました。

### 覚えておくと便利なコマンド

| 入力 | 動作 |
|------|------|
| `ls` | ファイル一覧を表示（アイコン付き） |
| `ll` | ファイル一覧を詳細表示 |
| `la` | 隠しファイルも含めて一覧表示 |
| `tree` | フォルダ構造をツリー表示 |
