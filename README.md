# dotfiles

macOS 用の環境設定。Homebrew・mise によるツール導入、シェル・macOS・アプリの設定をまとめて行う。

## 新しい Mac への移行

設定の適用は標準の **Terminal.app** から実行する。
**iTerm2・AltTab は終了しておく。**

1. リポジトリを取得する。

   ```bash
   git clone https://github.com/Fukiwake/dotfiles.git ~/src/dotfiles
   cd ~/src/dotfiles
   ```

2. セットアップを実行する。仕事用設定も必要な場合は、下の「追加設定」のコマンドを使う。

   ```bash
   bash install.sh
   ```

3. Alfred を起動して Powerpack を有効化し、**Advanced → Set preferences folder…** で
   `~/src/dotfiles/apps/alfred` を選ぶ（`Alfred.alfredpreferences` が入っている親フォルダ）。
   メインホットキー（⌘Space）・検索範囲・クリップボード履歴・スニペット自動展開は各 Mac で設定する。

4. 新しいシェルを開き、各アプリでログインや必要な権限の許可を行う。Colima は次で起動する。

   ```bash
   colima start
   ```

復元するアプリ設定は iTerm2・Alfred・LinearMouse・AltTab・k9s・uv・Colima。
Alfred は dotfiles 内の設定を直接使う。Workflow・Snippet・アイコンを Git で管理し、
Mac ごとの設定と、使っていない Remote のデータは Git 対象外。
Colima は Apple Silicon 向けで、CPU 4・メモリ 8 GiB・ディスク 160 GiB に設定している。
認証情報、Colima のコンテナ・Volume などのデータ、機器固有の
`~/.config/dotfiles/local.zsh` は別途移行する。既存の異なる設定はバックアップしてから配置する。

## 追加設定（必要な場合）

会社用リポジトリを別途取得し、手順 2 で次のように実行する。各引数は任意。

```bash
bash install.sh \
  --extra-ssh-config /path/to/company-dotfiles/ssh/config \
  --extra-zsh-config /path/to/company-dotfiles/zsh/work.zsh
```

設定ファイルだけ再配置するときは `bash install.sh --links-only`。
GUI アプリの設定適用やツール導入は行わない。詳しくは[追加設定の仕様](docs/additional-settings.md)を参照。

## アプリ設定の保存内容を更新するとき

Alfred の変更は、そのまま Git の差分になる。
ほかの 6 アプリの設定を取り込む場合は、iTerm2・AltTab を終了して実行する。

```bash
python3 scripts/app-settings.py capture
```

差分を確認してコミットする。不要な Alfred の Workflow・Snippet は Alfred 上で削除する。
アプリ一覧は [Brewfile](apps/homebrew/Brewfile)、ツールのバージョンは [mise](apps/mise/config.toml) で管理する。
