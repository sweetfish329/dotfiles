# Dotfiles セットアップガイド

このガイドでは、WSL（Windows Subsystem for Linux）のUbuntuに便利なシェル環境を構築する手順を説明します。

---

## 🚀 セットアップ手順

### ステップ1: フォントをインストール（Windows側で実施）

ターミナルでアイコンを正しく表示するために、まずフォントをインストールします。

1. 以下のリンクを開くいて、zipファイルをダウンロードしてください
   - <https://github.com/yuru7/HackGen/releases/download/v2.10.0/HackGen_NF_v2.10.0.zip>

2. ダウンロードしたZIPファイルを展開（右クリック → すべて展開）

3. 展開したフォルダ内の `.ttf` ファイルを全選択 → 右クリック → 「インストール」

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

### ステップ6: 設定ファイルをダウンロード

以下のコマンドを**1行ずつ**実行してください：

```bash
curl -L -o ~/.zshrc https://raw.githubusercontent.com/sweetfish329/dotfiles/main/.zshrc
```

```bash
curl -L -o ~/.p10k.zsh https://raw.githubusercontent.com/sweetfish329/dotfiles/main/.p10k.zsh
```

```bash
curl -L -o ~/.vimrc https://raw.githubusercontent.com/sweetfish329/dotfiles/main/.vimrc
```

```bash
mkdir -p ~/.config/sheldon
```

```bash
curl -L -o ~/.config/sheldon/plugins.toml https://raw.githubusercontent.com/sweetfish329/dotfiles/main/.plugins/sheldon/plugins.toml
```

---

### ステップ7: zshをデフォルトシェルに設定

```bash
chsh -s $(which zsh)
```

> パスワードを聞かれたら入力してEnterを押してください

---

### ステップ8: プラグインをインストール

```bash
zsh -c "sheldon lock"
```

---

### ステップ9: Windowsターミナルのフォント設定

1. Ubuntuのタブの右にある▽をクリック → 「設定」
2. 左メニューから「Ubuntu」を選択
3. 「外観」タブをクリック
4. 「フォントフェイス」を「**HackGen Console NF**」に変更
5. 「保存」をクリック

---

### ステップ10: Ubuntuを再起動

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
