# Completion for ~/commands/dev.

_dev_robin_services() {
  local config_dir="${ROBIN_MPROCS_CONFIG_DIR:-$HOME/.config/robin-mprocs}"
  local -a configs services

  configs=("$config_dir"/*.yaml(N))
  services=("${configs:t:r}")
  _describe -t services 'robin services' services
}

_dev() {
  local -a commands
  commands=(
    'start:Start the mprocs development environment'
    'open:Open Cursor and IntelliJ IDEA'
    'close:Close the service IDE windows'
    'clean:Alias for close'
    'config:Print the mprocs config path'
    'help:Show help'
  )

  if (( CURRENT == 2 )); then
    _alternative \
      'commands:commands:((start\\:Start open\\:Open close\\:Close clean\\:Clean config\\:Config help\\:Help))' \
      'services:services:_dev_robin_services'
    return
  fi

  if (( CURRENT == 3 )); then
    case "$words[2]" in
      start|open|close|clean|config)
        _dev_robin_services
        ;;
    esac
  fi
}

compdef _dev dev
