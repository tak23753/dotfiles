# 仕事用 dotfiles

個人 dotfiles の `docs/additional-settings.md` に定義するインターフェース v1 に従う。
このリポジトリは設定ファイルを提供し、独自のインストーラーは持たない。

`zsh/work.zsh` と `ssh/config` を会社に合わせて編集し、個人側から適用する。

```bash
bash /path/to/personal-dotfiles/install.sh \
  --extra-ssh-config /path/to/company-dotfiles/ssh/config \
  --extra-zsh-config /path/to/company-dotfiles/zsh/work.zsh
```

片方だけ渡してもよい。設定配置のみなら `--links-only` を併用する。
会社を問わず使うツールは個人側で管理する。
秘密鍵・API キー・トークン本体はこのリポジトリに入れない。
元ファイルを移動したら、新しいパスを渡して再実行する。
