# dotfiles

Apple Silicon Mac 用の環境設定。Homebrew・mise、Zsh、macOS・アプリの設定をまとめて適用する。
アプリ一覧は [Brewfile](apps/homebrew/Brewfile)、ツールのバージョンは [mise](apps/mise/config.toml) で管理する。

## セットアップ

Command Line Tools（`xcode-select --install`）の導入と App Store へのログインを済ませる。
iTerm2・AltTab を終了し、Rosetta を使用しない **Terminal.app** で実行する。

```bash
git clone https://github.com/Fukiwake/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles
bash install.sh
```

`install.sh` でツールの導入と、iTerm2・LinearMouse・AltTab・k9s・uv・Colima の保存済み設定まで適用する。
既存の異なる設定はバックアップしてから配置する。完了後はログアウト・再ログインし、次を行う。

- Alfred：Powerpack を有効化し、**Advanced → Set preferences folder…** で
  `~/src/dotfiles/apps/alfred` を選ぶ。ホットキー・検索範囲・クリップボード履歴・スニペット自動展開は各 Mac で設定する。
- 各アプリ：ログインと権限の許可を行う。1Password の SSH Agent も有効化する。
- Git：`git config --global user.email <メールアドレス>` を実行する。
- Colima：`colima start` で起動する（CPU 4・メモリ 8 GiB・ディスク 160 GiB）。

認証情報、Colima のデータ、`~/.config/dotfiles/local.zsh`、日本語ユーザー辞書は別途移行する。
SDKMAN・Flutter・Android SDK などの追加環境も必要に応じて導入する。

## 追加設定

仕事用などの設定ファイルを指定できる。各引数は任意。

```bash
bash install.sh \
  --extra-ssh-config /path/to/company-dotfiles/ssh/config \
  --extra-zsh-config /path/to/company-dotfiles/zsh/work.zsh
```

設定ファイルの配置だけなら `bash install.sh --links-only`。
詳しくは[追加設定の仕様](docs/additional-settings.md)を参照。

## SSH の移行

1Password から GitHub 用の公開鍵を書き出し、`~/.ssh/github_private.pub`（私用）と
`~/.ssh/github_work.pub`（仕事用）に保存する。

仕事用の SSH 設定を `--extra-ssh-config` で指定する。セットアップ時に指定しなかった場合は後から配置する。

```bash
bash install.sh --links-only --extra-ssh-config /path/to/company-dotfiles/ssh/config
```

接続先のアカウントを確認する。

```bash
ssh -T git@github.com          # 仕事用アカウント
ssh -T git@github-private      # 私用アカウント
```

## Zsh 履歴の移行

旧 Mac の Zsh で履歴を書き出す。

```zsh
fc -AI
cp -p "$HISTFILE" ~/zsh-history-export
```

ファイルを新しい Mac の `~/Downloads/` に転送する。
セットアップ後の Zsh を1つだけ開き、ほかのターミナルや IDE のシェルを閉じて取り込む。

```zsh
fc -W ~/zsh-history-before-import
fc -RI ~/Downloads/zsh-history-export
fc -W "$HISTFILE"
chmod 600 "$HISTFILE"
```

履歴は最大10万件。Git には追加せず、移行確認後に転送用ファイルと不要なバックアップを削除する。
