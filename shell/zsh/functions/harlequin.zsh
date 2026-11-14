# Harlequin ラッパー: harlequin の引数をそのまま受け取り、対象プロファイルが
# proxy 対応表にあれば cloud-sql-proxy を自動起動/停止する。
# -P/--profile を見て判定し、未指定なら default_profile を採用。
# 使い方:  hq                 -> default_profile で起動
#          hq -P company      -> cloud-sql-proxy を自動起動して起動
#          hq -a sqlite a.db  -> harlequin の任意オプションがそのまま通る
# proxy 対応表: ~/.harlequin-proxies.conf / プロファイル定義: ~/.harlequin.toml
hq() {
  local conf="$HOME/.harlequin-proxies.conf"
  local toml="$HOME/.harlequin.toml"

  # 引数から profile を検出 (-P NAME / --profile NAME / --profile=NAME / -PNAME)
  local profile="" i
  local -a args=("$@")
  for (( i=1; i<=$#args; i++ )); do
    case "${args[i]}" in
      -P|--profile) profile="${args[i+1]}" ;;
      --profile=*)  profile="${args[i]#--profile=}" ;;
      -P?*)         profile="${args[i]#-P}" ;;
    esac
  done
  # -P 未指定なら default_profile を採用
  if [[ -z "$profile" ]]; then
    profile=$(grep -E '^[[:space:]]*default_profile[[:space:]]*=' "$toml" 2>/dev/null \
      | head -1 | sed -E 's/.*=[[:space:]]*"?([^"#]+)"?.*/\1/' | tr -d '[:space:]')
  fi

  # profile が proxy 対応表になければ、そのまま harlequin へ委譲
  local instance=""
  [[ -n "$profile" && -f "$conf" ]] && \
    instance=$(grep -E "^[[:space:]]*${profile}=" "$conf" | grep -v '^[[:space:]]*#' | head -1 | cut -d= -f2-)
  if [[ -z "$instance" ]]; then
    harlequin "$@"
    return
  fi

  # 空きポートを動的取得 → proxy 起動 → ポート待機 → 起動(-p でポート注入) → 終了時に停止
  local port
  port=$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')
  cloud-sql-proxy --auto-iam-authn --private-ip --port "$port" "$instance" &
  local pid=$!
  trap 'kill $pid 2>/dev/null' EXIT INT TERM
  for (( i=1; i<=30; i++ )); do nc -z 127.0.0.1 "$port" 2>/dev/null && break; sleep 0.3; done
  harlequin "$@" -p "$port"
  kill $pid 2>/dev/null
  trap - EXIT INT TERM
}

# 補完: -P/--profile の後はプロファイル名、それ以外はファイル
_hq() {
  local -a profiles
  profiles=(${(f)"$(grep -oE '^\[profiles\.[^]]+\]' "$HOME/.harlequin.toml" 2>/dev/null | sed -E 's/^\[profiles\.(.+)\]$/\1/')"})
  if [[ "${words[CURRENT-1]}" == (-P|--profile) ]]; then
    compadd -- $profiles
  else
    _files
  fi
}
compdef _hq hq
