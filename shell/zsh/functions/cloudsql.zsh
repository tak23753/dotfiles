# cloudsql: `connect --direct` のときだけ psql の代わりに pgcli を使う薄いラッパー。
# cloudsql は psql を PATH 経由で `bash -c` 起動するため、その回だけ psql シムを
# PATH 先頭に差し込んで pgcli にすり替える。それ以外は素通し（オプションもそのまま）。
cloudsql() {
  if [[ "$1" == "connect" && " $* " == *" --direct "* ]] && command -v pgcli >/dev/null; then
    local shim; shim="$(mktemp -d)"
    cat >"$shim/psql" <<'EOF'
#!/usr/bin/env bash
exec pgcli "$@"
EOF
    chmod +x "$shim/psql"
    PATH="$shim:$PATH" command cloudsql "$@"
    local rc=$?
    rm -rf "$shim"
    return $rc
  fi
  command cloudsql "$@"
}
