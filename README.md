# dotfiles

## Installation

まず個人用 dotfiles で基礎環境を構築する。任意の作業ディレクトリで実行できる。

```bash
git clone https://github.com/Fukiwake/dotfiles.git ~/src/dotfiles
bash ~/src/dotfiles/install.sh
```

仕事用設定が必要な場合は、会社管理のリポジトリを別途取得し、追加したい
設定ファイルを同じインストーラーに渡す。最初から追加設定と一緒に実行してもよい。

```bash
bash ~/src/dotfiles/install.sh \
  --extra-ssh-config /path/to/company-dotfiles/ssh/config \
  --extra-zsh-config /path/to/company-dotfiles/zsh/work.zsh
```

各引数は任意。`--links-only` を併用すると、ツールのインストールや macOS の設定変更をせずに
設定を配置できる。同じ指定で繰り返し実行してもリンクは増えない。
既存の異なる設定は `.backup.XXXXXX/original` にバックアップする。
引数を省略した追加設定は再実行しても維持する。

会社ごとの構成・配置規約・作成方法は
[追加設定のインターフェース](docs/additional-settings.md) を参照。
