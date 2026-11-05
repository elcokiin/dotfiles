# Proxy helpers for interactive shells.
#
# Managed by ~/Work/dotfiles/omarchy-config/proxy/shell.sh and sourced from
# ~/.bashrc. The real state (systemd user session, GNOME proxy settings, git,
# npm) is handled by `omarchy-proxy`.

_omarchy_proxy_env_file() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/proxy/env.sh"
}

_omarchy_proxy_apply() {
  local env_file
  env_file="$(_omarchy_proxy_env_file)"
  if [[ -f "$env_file" ]]; then
    # shellcheck disable=SC1090
    source "$env_file"
  else
    unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
  fi
}

# A new shell should inherit the proxy when it is enabled system-wide.
if [[ -f "$(_omarchy_proxy_env_file)" ]]; then
  _omarchy_proxy_apply
fi

proxyon() { omarchy-proxy on && _omarchy_proxy_apply; }
proxyoff() { omarchy-proxy off && _omarchy_proxy_apply; }
proxytoggle() { omarchy-proxy toggle && _omarchy_proxy_apply; }
proxystatus() { omarchy-proxy status; }
proxytest() { omarchy-proxy test; }
