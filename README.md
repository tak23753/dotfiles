# dotfiles

## Installation

macOS 用の dotfiles。まず個人用 dotfiles で基礎環境を構築する。任意の作業ディレクトリで実行できる。

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

ツールのバージョンは mise で管理する。
[グローバル設定](apps/mise/config.toml) を `~/.config/mise/config.toml` に配置し、
通常のインストール時に `mise install` で導入する。`--links-only` では設定の配置だけを行う。
既存プロジェクトの `.tool-versions` も mise で読み込めるため、会社の共有設定はそのまま使える。
.NET SDK はバージョンごとに分離し、指定した SDK を選択する。

会社ごとの構成・配置規約・作成方法は
[追加設定のインターフェース](docs/additional-settings.md) を参照。

## 構成

macOS 専用。設定の対象ごとに配置し、適用する処理は `scripts/` と `install.sh` が担当する。
リポジトリ内の名前とホームディレクトリへの配置先は
[`scripts/link-configs.sh`](scripts/link-configs.sh) で明示的に対応させる。

| ディレクトリ | 内容 |
| --- | --- |
| `shell/zsh/` | Zsh の基本設定、プラグイン、ツール連携、関数、プロンプト |
| `system/` | macOS の設定、フォント、ユーザー辞書の保管 |
| `apps/` | Homebrew、mise、SSH、Terraform、エディタ固有の設定 |
| `scripts/` | 設定のリンク、ツールとフォントのインストール |
| `tests/` | 配置・移行、シェル起動、セットアップの検証 |

パッケージ一覧は [`apps/homebrew/Brewfile`](apps/homebrew/Brewfile) で管理し、
従来どおり `~/.Brewfile` にリンクする。各設定の配置先も変更しない。
フォントは `~/Library/Fonts/` にコピーする。ユーザー辞書は保管のみで、自動適用しない。

### Zsh の分割と読み込み順

`shell/zsh/zshrc` を `~/.zshrc`、`shell/zsh/` を `~/.zsh` にリンクする。
`zshrc` は instant prompt → aliases → options → plugins → paths → integrations →
追加設定の順に読み込む。

`paths.zsh` は基本の PATH と環境変数を設定する。
ツール固有の PATH 変更は、初期化時に見える PATH の順序を維持するため
`integrations.zsh` の該当箇所に置く。
独自関数は `functions/` に分け、`integrations.zsh` から順番を指定して読み込む。
ファイルを追加しただけでは自動で読み込まない。
共通設定 → 追加設定 → 機器固有設定の順序は維持する。

### 旧構成からの移行

ファイルを移動したあと、既存のリンクを新しい配置先に更新する。

```bash
bash /path/to/dotfiles/install.sh --links-only
```

古いリンクは通常のバックアップ規則で退避する。
追加設定の引数を省略しても、既存の会社用・機器固有の設定は維持する。

## 検証

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v
```

一時 HOME で実行し、ツール導入・macOS 設定変更・外部サービス連携はテスト用の処理に置き換える。
実際のホームディレクトリや OS 設定は変更しない。
