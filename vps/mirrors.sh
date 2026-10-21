#!/usr/bin/env bash
# mirrors.sh — benchmark mirrors and switch apt (Ubuntu), pip and npm to the fastest one
#
# Usage:
#   bash mirrors.sh                 # test mirrors from all countries
#   bash mirrors.sh JP              # only Japan (+ official archive)
#   bash mirrors.sh VN SG HK        # several countries
#   bash mirrors.sh --dry-run JP    # test only, change nothing
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/dominhhieu1405/code/refs/heads/master/vps/mirrors.sh | sudo bash -s -- JP
#
# Env overrides: TOP=10 (mirrors speed-tested after ping), RUNS=2, TIMEOUT=8, EXTRA_APT="http://x/ubuntu/ ..."
set -u
RUNS=${RUNS:-2}; TIMEOUT=${TIMEOUT:-8}; DRY=${DRY:-0}; TOP=${TOP:-10}
G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'

# Top 5 mirrors per country (by bandwidth on launchpad.net/ubuntu/+archivemirrors)
APT_MIRRORS="
VN http://mirror.bizflycloud.vn/ubuntu/
VN http://mirror.viettelcloud.vn/ubuntu/
VN https://mirrors.bkns.vn/ubuntu/
VN https://mirrors.tino.org/ubuntu/
VN http://opensource.xtdv.net/ubuntu/
SG http://mirror.sg.gs/ubuntu/
SG http://mirror.0x.sg/ubuntu/
SG https://mirror.freedif.org/ubuntu/
SG https://sg-mirrors.vhost.vn/ubuntu/
SG http://mirror.soonkeat.sg/ubuntu/
HK https://mirror.xtom.com.hk/ubuntu/
HK https://mirror.01link.hk/ubuntu/
HK http://mirror.as.kamatera.com/ubuntu/
HK http://ftp.hostrino.com/pub/ubuntu/archive/
JP https://ftp.udx.icscoe.jp/Linux/ubuntu/
JP https://linux.yz.yamagata-u.ac.jp/ubuntu/
JP http://ftp.jaist.ac.jp/pub/Linux/ubuntu/
JP http://ftp.riken.jp/Linux/ubuntu/
JP http://ubuntutym.u-toyama.ac.jp/ubuntu/
KR https://ftp.kaist.ac.kr/ubuntu/
KR https://mirror.kakao.com/ubuntu/
KR https://mirror.elice.io/ubuntu/
KR http://mirror.navercorp.com/ubuntu/
KR http://kr.archive.ubuntu.com/ubuntu/
TW https://mirror.twds.com.tw/ubuntu/
TW http://free.nchc.org.tw/ubuntu/
TW http://ftp.ubuntu-tw.org/mirror/ubuntu/
TW http://mirror.ossplanet.net/ubuntu/
TW http://ftp.tku.edu.tw/ubuntu/
CN https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
CN https://mirrors.nju.edu.cn/ubuntu/
CN https://mirrors.bupt.edu.cn/ubuntu/
CN http://mirrors.aliyun.com/ubuntu/
CN https://mirrors.cloud.tencent.com/ubuntu/
US https://mirror.pilotfiber.com/ubuntu/
US http://mirror.pit.teraswitch.com/ubuntu/
US https://mirrors.xtom.com/ubuntu/
US https://us.mirrors.clouvider.net/ubuntu/
US https://mirrors.wikimedia.org/ubuntu/
DE https://ftp.uni-stuttgart.de/ubuntu/
DE http://ftp.halifax.rwth-aachen.de/ubuntu/
DE https://mirror.dogado.de/ubuntu/
DE https://de.mirrors.clouvider.net/ubuntu/
DE https://mirrors.xtom.de/ubuntu/
--  http://archive.ubuntu.com/ubuntu/
"
KNOWN=$(awk 'NF && $1!="--"{print $1}' <<<"$APT_MIRRORS" | sort -u | tr '\n' ' ')

usage() {
  echo "Usage: $0 [--dry-run] [COUNTRY ...]"
  echo "Countries: ${KNOWN}(default: all)"
  exit 0
}

# ---- args ----
COUNTRIES=""
for a in "$@"; do
  case $a in
    -h | --help) usage ;;
    -n | --dry-run) DRY=1 ;;
    *)
      cc=$(tr '[:lower:]' '[:upper:]' <<<"$a")
      if [[ " $KNOWN" == *" $cc "* ]]; then COUNTRIES="$COUNTRIES $cc"
      else echo "${Y}Unknown country '$a' — available: $KNOWN${N}"; exit 1; fi
      ;;
  esac
done

command -v curl >/dev/null || { echo "${R}curl is required${N}"; exit 1; }
[ "$(id -u)" -eq 0 ] || [ "$DRY" = 1 ] || { echo "${R}Run as root/sudo (or use --dry-run to only test)${N}"; exit 1; }
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

human() { awk -v b="$1" 'BEGIN{ if (b<=0) {print "FAIL"; exit}
  if (b>=1048576) printf "%.2f MB/s", b/1048576; else printf "%.1f KB/s", b/1024 }'; }

# bench URL -> average speed (bytes/s), 0 on failure
bench() {
  local url=$1 total=0 ok=0 out code spd i
  for ((i = 0; i < RUNS; i++)); do
    out=$(curl -sL -o /dev/null --connect-timeout 3 --max-time "$TIMEOUT" \
      -w '%{http_code} %{speed_download}' "$url" 2>/dev/null) || true
    code=${out%% *}; spd=${out#* }
    if [ "$code" = 200 ]; then
      total=$(awk -v a="$total" -v b="$spd" 'BEGIN{print a+b}'); ok=$((ok + 1))
    fi
  done
  if [ "$ok" -gt 0 ]; then awk -v t="$total" -v n="$ok" 'BEGIN{printf "%.0f", t/n}'; else echo 0; fi
}

# pick "Title" "label|base|testurl" ...
#  1) ping all in parallel (TTFB on 1 byte), drop dead mirrors
#  2) speed-test the TOP lowest-latency ones -> table -> BEST, BEST_SPD
pick() {
  local title=$1; shift
  local i=0 e r label base url s sorted first=1 cand res=() total=$#
  echo; echo "${B}== $title ==${N}"
  rm -f "$TMP"/p.*
  for e in "$@"; do
    url=${e##*|}
    ( r=$(curl -sL -o /dev/null -r 0-0 --connect-timeout 3 --max-time 5 \
        -w '%{http_code} %{time_starttransfer}' "$url" 2>/dev/null)
      case ${r%% *} in 200 | 206) echo "${r#* }|$e" >"$TMP/p.$i" ;; esac ) &
    i=$((i + 1))
  done
  wait
  cand=$(cat "$TMP"/p.* 2>/dev/null | sort -t'|' -k1,1n | head -n "$TOP")
  if [ -z "$cand" ]; then echo "  ${R}no mirror responded${N}"; BEST=""; BEST_SPD=0; return; fi
  echo "  ${D}pinged $total, $(cat "$TMP"/p.* | wc -l) alive, speed-testing the $(wc -l <<<"$cand") fastest${N}"

  while IFS='|' read -r _ label base url; do
    printf '\r\e[K  testing %s' "$label" >&2
    s=$(bench "$url")
    res+=("$s|$label|$base")
  done <<<"$cand"
  printf '\r\e[K' >&2

  sorted=$(printf '%s\n' "${res[@]}" | sort -t'|' -k1,1nr)
  printf '| %-58s | %12s |\n' "Mirror" "Speed Avg"
  printf '|%s|%s|\n' "$(printf -- '-%.0s' {1..60})" "$(printf -- '-%.0s' {1..14})"
  while IFS='|' read -r s label base; do
    if [ "$first" = 1 ] && [ "$s" != 0 ]; then
      printf "| ${G}%-60s${N} | ${G}%12s${N} |\n" "★ $label" "$(human "$s")" # ★ = 3 bytes, 1 column
    else
      printf '| %-58s | %12s |\n' "$label" "$(human "$s")"
    fi
    first=0
  done <<<"$sorted"
  r=$(head -1 <<<"$sorted"); BEST_SPD=${r%%|*}; BEST=${r##*|}
}

# keep backups outside sources.list.d (apt complains about .bak files there)
BK=/var/backups/mirrors-sh
backup() { [ -f "$1" ] && mkdir -p "$BK" && cp -a "$1" "$BK/$(basename "$1").$(date +%s)"; }
if [ "$DRY" != 1 ] && ls /etc/apt/sources.list.d/*.bak.* >/dev/null 2>&1; then
  mkdir -p "$BK" && mv /etc/apt/sources.list.d/*.bak.* "$BK"/
fi
SUMMARY=()

# ================= APT (Ubuntu) =================
if [ -r /etc/os-release ] && . /etc/os-release && [ "${ID:-}" = ubuntu ]; then
  CODENAME=${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}
  ARCH=$(dpkg --print-architecture)
  case $ARCH in amd64 | i386) PORTS=0 ;; *) PORTS=1 ;; esac

  FILES=()
  [ -f /etc/apt/sources.list.d/ubuntu.sources ] && FILES+=(/etc/apt/sources.list.d/ubuntu.sources)
  [ -f /etc/apt/sources.list ] && grep -qE '^deb ' /etc/apt/sources.list && FILES+=(/etc/apt/sources.list)

  # every mirror URI in use (except security); path need not be /ubuntu
  # (e.g. Vultr uses http://ubuntu.mirror.constant.com)
  CURS=""
  [ ${#FILES[@]} -gt 0 ] && CURS=$(grep -hE '^(URIs:|deb(-src)? )' "${FILES[@]}" |
    grep -oE 'https?://[^ ]+' | grep -v security.ubuntu.com | awk '!s[$0]++')
  CUR=$(head -1 <<<"$CURS"); [ -n "$CUR" ] && CUR="${CUR%/}/"

  LIST=$(grep -E '^[A-Z-]{2} ' <<<"$APT_MIRRORS")
  if [ -n "$COUNTRIES" ]; then
    LIST=$(grep -E "^($(tr -s ' ' '|' <<<"${COUNTRIES# }")|--) " <<<"$LIST")
  fi
  [ -n "$CUR" ] && LIST="cur $CUR
$LIST"
  for x in ${EXTRA_APT:-}; do LIST="$LIST
++ $x"; done

  if [ "$PORTS" = 1 ]; then
    LIST=$(sed -E 's#archive\.ubuntu\.com/ubuntu/?#ports.ubuntu.com/ubuntu-ports/#; s#/ubuntu/$#/ubuntu-ports/#' <<<"$LIST")
  fi

  ARGS=()
  while read -r cc m; do
    [ -z "${m:-}" ] && continue
    m="${m%/}/"
    ARGS+=("[$cc] $m|$m|${m}dists/$CODENAME/main/binary-$ARCH/Packages.gz")
  done < <(awk '!s[$2]++' <<<"$LIST")

  pick "APT Ubuntu $CODENAME ($ARCH) — current: ${CUR:-?}" "${ARGS[@]}"

  if [ "$BEST_SPD" = 0 ]; then
    SUMMARY+=("${R}APT: no working mirror, unchanged${N}")
  elif [ "$BEST" = "$CUR" ]; then
    SUMMARY+=("APT: current mirror is already the fastest ($BEST)")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}APT (dry-run): would switch to $BEST${N}")
  elif [ ${#FILES[@]} -eq 0 ]; then
    SUMMARY+=("${Y}APT: no sources.list / ubuntu.sources found${N}")
  else
    for f in "${FILES[@]}"; do
      backup "$f"
      c=$(<"$f")
      while read -r u; do
        [ -z "$u" ] && continue
        # keep the original trailing-slash style
        if [ "${u%/}" = "$u" ]; then c=${c//"$u"/${BEST%/}}; else c=${c//"$u"/$BEST}; fi
      done <<<"$CURS"
      printf '%s\n' "$c" >"$f"
    done
    if ! grep -qF "${BEST%/}" "${FILES[@]}"; then
      SUMMARY+=("${R}APT: failed to replace URIs in ${FILES[*]}${N}")
    else
      echo "  apt-get update..."
      if apt-get update -qq; then
        SUMMARY+=("${G}APT: switched to $BEST${N} (backup: $BK)")
      else
        SUMMARY+=("${R}APT: switched to $BEST but apt update failed — restore from $BK${N}")
      fi
    fi
  fi
else
  SUMMARY+=("APT: not Ubuntu, skipped")
fi

# ================= PIP =================
if command -v pip3 >/dev/null || command -v pip >/dev/null || python3 -m pip --version >/dev/null 2>&1; then
  P=()
  for m in https://pypi.org/simple/ \
    https://mirrors.aliyun.com/pypi/simple/ \
    https://pypi.tuna.tsinghua.edu.cn/simple/ \
    https://mirrors.cloud.tencent.com/pypi/simple/ \
    https://mirrors.ustc.edu.cn/pypi/simple/; do
    P+=("$m|$m|${m}numpy/")
  done
  pick "PIP" "${P[@]}"
  if [ "$BEST_SPD" = 0 ]; then
    SUMMARY+=("${R}PIP: no working mirror${N}")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}PIP (dry-run): would use $BEST${N}")
  else
    HOST=$(awk -F/ '{print $3}' <<<"$BEST")
    backup /etc/pip.conf
    printf '[global]\nindex-url = %s\ntrusted-host = %s\ntimeout = 60\n' "$BEST" "$HOST" >/etc/pip.conf
    SUMMARY+=("${G}PIP: /etc/pip.conf -> $BEST${N}")
  fi
else
  SUMMARY+=("PIP: not installed, skipped")
fi

# ================= NPM =================
if command -v npm >/dev/null; then
  P=()
  for m in https://registry.npmjs.org/ \
    https://registry.npmmirror.com/ \
    https://mirrors.cloud.tencent.com/npm/; do
    P+=("$m|$m|${m}typescript")
  done
  pick "NPM" "${P[@]}"
  if [ "$BEST_SPD" = 0 ]; then
    SUMMARY+=("${R}NPM: no working registry${N}")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}NPM (dry-run): would use $BEST${N}")
  else
    npm config set registry "$BEST" -g >/dev/null 2>&1 && SUMMARY+=("${G}NPM: registry -> $BEST${N}")
  fi
fi

echo; echo "${B}== Result ==${N}"
printf '  %s\n' "${SUMMARY[@]}"
