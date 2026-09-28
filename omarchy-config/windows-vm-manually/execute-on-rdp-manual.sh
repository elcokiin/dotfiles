#!/bin/bash

# 1. Read saved credentials
CRED_FILE="$HOME/.config/windows/credentials"
WIN_USER=$(grep -E '^USERNAME=' "$CRED_FILE" 2>/dev/null | cut -d'=' -f2)
WIN_PASS=$(grep -E '^PASSWORD=' "$CRED_FILE" 2>/dev/null | cut -d'=' -f2)

: "${WIN_USER:=docker}"
: "${WIN_PASS:=admin}"

# 2. Configure Kerberos to avoid network hangs
KRB5_CONF="$HOME/.config/windows/krb5.conf"
mkdir -p "$(dirname "$KRB5_CONF")"
if [[ ! -f $KRB5_CONF ]]; then
  printf '[libdefaults]\n  dns_lookup_kdc = false\n  dns_lookup_realm = false\n' >"$KRB5_CONF"
fi
export KRB5_CONFIG="$KRB5_CONF"

# 3. Detect Hyprland scale
RDP_SCALE=""
HYPR_SCALE=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select (.focused == true) | .scale' 2>/dev/null)
SCALE_PERCENT=$(echo "$HYPR_SCALE" | awk '{print int($1 * 100)}')

if ((SCALE_PERCENT >= 170)); then
  RDP_SCALE="/scale:180"
elif ((SCALE_PERCENT >= 130)); then
  RDP_SCALE="/scale:140"
fi

# 4. Launch FreeRDP directly
xfreerdp3 /u:"$WIN_USER" /p:"$WIN_PASS" /v:127.0.0.1:3389 -grab-keyboard /sound /microphone /clipboard /cert:ignore /title:"Windows VM - Omarchy" /dynamic-resolution /gfx:AVC444 /floatbar:sticky:off,default:visible,show:fullscreen $RDP_SCALE
