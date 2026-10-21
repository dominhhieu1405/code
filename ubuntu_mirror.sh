#!/usr/bin/env bash
# mirror.sh — tự test & chuyển sang mirror nhanh nhất cho apt (Ubuntu), pip, npm
# Chạy:   curl -fsSL https://raw.githubusercontent.com/dominhhieu1405/code/refs/heads/master/ubuntu_mirror.sh | sudo bash
# Chỉ test, không sửa:   curl -fsSL https://your.host/mirror.sh | sudo DRY=1 bash
# Tuỳ chỉnh:
#   COUNTRIES="VN SG JP"   chỉ test mirror các nước này (mặc định: tất cả)
#   TOP=10                 số mirror có ping tốt nhất được đem đi test tốc độ
#   RUNS=2 TIMEOUT=8       số lần test / thời gian tối đa mỗi lần (giây)
#   EXTRA_APT="http://x/ubuntu/ ..."
set -u
RUNS=${RUNS:-2}; TIMEOUT=${TIMEOUT:-8}; DRY=${DRY:-0}; TOP=${TOP:-10}; COUNTRIES=${COUNTRIES:-}
G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; B=$'\e[1m'; D=$'\e[2m'; N=$'\e[0m'

command -v curl >/dev/null || { echo "${R}Cần curl${N}"; exit 1; }
[ "$(id -u)" -eq 0 ] || [ "$DRY" = 1 ] || { echo "${R}Chạy bằng root/sudo (hoặc DRY=1 để chỉ test)${N}"; exit 1; }
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# Top 5 mirror (theo băng thông trên launchpad.net/ubuntu/+archivemirrors) mỗi nước
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

human() { awk -v b="$1" 'BEGIN{ if (b<=0) {print "FAIL"; exit}
  if (b>=1048576) printf "%.2f MB/s", b/1048576; else printf "%.1f KB/s", b/1024 }'; }

# bench URL -> tốc độ trung bình (bytes/s), 0 nếu lỗi
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

# pick "Tiêu đề" "label|base|testurl" ...
#  1) ping song song tất cả (TTFB, 1 byte), loại mirror chết
#  2) TOP mirror ping tốt nhất -> test tốc độ tuần tự -> bảng -> BEST, BEST_SPD
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
  if [ -z "$cand" ]; then echo "  ${R}không mirror nào phản hồi${N}"; BEST=""; BEST_SPD=0; return; fi
  echo "  ${D}ping $total mirror, $(cat "$TMP"/p.* | wc -l) sống, test tốc độ $(wc -l <<<"$cand") cái nhanh nhất${N}"

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
      printf "| ${G}%-60s${N} | ${G}%12s${N} |\n" "★ $label" "$(human "$s")" # ★ = 3 byte, 1 cột
    else
      printf '| %-58s | %12s |\n' "$label" "$(human "$s")"
    fi
    first=0
  done <<<"$sorted"
  r=$(head -1 <<<"$sorted"); BEST_SPD=${r%%|*}; BEST=${r##*|}
}

# backup ra ngoài sources.list.d (apt sẽ kêu nếu để .bak trong đó)
BK=/var/backups/mirror-sh
backup() { [ -f "$1" ] && mkdir -p "$BK" && cp -a "$1" "$BK/$(basename "$1").$(date +%s)"; }
# dọn backup cũ do bản trước để nhầm chỗ
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

  # mọi URI mirror đang dùng (trừ security), không giả định path phải là /ubuntu
  # vd Vultr dùng http://ubuntu.mirror.constant.com
  CURS=""
  [ ${#FILES[@]} -gt 0 ] && CURS=$(grep -hE '^(URIs:|deb(-src)? )' "${FILES[@]}" |
    grep -oE 'https?://[^ ]+' | grep -v security.ubuntu.com | awk '!s[$0]++')
  CUR=$(head -1 <<<"$CURS"); [ -n "$CUR" ] && CUR="${CUR%/}/"

  LIST=$(grep -E '^[A-Z-]{2} ' <<<"$APT_MIRRORS")
  if [ -n "$COUNTRIES" ]; then
    LIST=$(grep -E "^($(tr ' ,' '||' <<<"$COUNTRIES" | sed 's/|*$//')|--) " <<<"$LIST")
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

  pick "APT Ubuntu $CODENAME ($ARCH) — hiện tại: ${CUR:-?}" "${ARGS[@]}"

  if [ "$BEST_SPD" = 0 ]; then
    SUMMARY+=("${R}APT: không mirror nào chạy được, giữ nguyên${N}")
  elif [ "$BEST" = "$CUR" ]; then
    SUMMARY+=("APT: mirror hiện tại đã nhanh nhất ($BEST)")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}APT (DRY): sẽ đổi sang $BEST${N}")
  elif [ ${#FILES[@]} -eq 0 ]; then
    SUMMARY+=("${Y}APT: không tìm thấy sources.list / ubuntu.sources${N}")
  else
    for f in "${FILES[@]}"; do
      backup "$f"
      c=$(<"$f")
      while read -r u; do
        [ -z "$u" ] && continue
        # giữ kiểu dấu / cuối như bản gốc
        if [ "${u%/}" = "$u" ]; then c=${c//"$u"/${BEST%/}}; else c=${c//"$u"/$BEST}; fi
      done <<<"$CURS"
      printf '%s\n' "$c" >"$f"
    done
    if ! grep -qF "${BEST%/}" "${FILES[@]}"; then
      SUMMARY+=("${R}APT: không thay được URI trong ${FILES[*]}${N}")
    else
    echo "  apt-get update..."
    if apt-get update -qq; then
      SUMMARY+=("${G}APT: đã đổi sang $BEST${N} (backup: $BK)")
    else
      SUMMARY+=("${R}APT: đổi sang $BEST nhưng apt update lỗi — khôi phục từ $BK${N}")
    fi
    fi
  fi
else
  SUMMARY+=("APT: không phải Ubuntu, bỏ qua")
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
    SUMMARY+=("${R}PIP: không mirror nào chạy được${N}")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}PIP (DRY): sẽ dùng $BEST${N}")
  else
    HOST=$(awk -F/ '{print $3}' <<<"$BEST")
    backup /etc/pip.conf
    printf '[global]\nindex-url = %s\ntrusted-host = %s\ntimeout = 60\n' "$BEST" "$HOST" >/etc/pip.conf
    SUMMARY+=("${G}PIP: /etc/pip.conf -> $BEST${N}")
  fi
else
  SUMMARY+=("PIP: không có pip, bỏ qua")
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
    SUMMARY+=("${R}NPM: không registry nào chạy được${N}")
  elif [ "$DRY" = 1 ]; then
    SUMMARY+=("${Y}NPM (DRY): sẽ dùng $BEST${N}")
  else
    npm config set registry "$BEST" -g >/dev/null 2>&1 && SUMMARY+=("${G}NPM: registry -> $BEST${N}")
  fi
fi

echo; echo "${B}== Kết quả ==${N}"
printf '  %s\n' "${SUMMARY[@]}"
