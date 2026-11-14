# ヒストリ (履歴) を保存、数を増やす
HISTFILE=~/.zhistory
HISTSIZE=100000
SAVEHIST=100000

# 同時に起動した zsh の間でヒストリを共有する
setopt inc_append_history
setopt share_history

# 直前と同じコマンドの場合はヒストリに追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# ヒストリに時刻を保存する
setopt extended_history

# 英数字以外を区切り文字にする
typeset -g WORDCHARS=
