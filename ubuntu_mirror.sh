#!/usr/bin/env bash
# Run:   curl -fsSL https://raw.githubusercontent.com/dominhhieu1405/code/refs/heads/master/ubuntu_mirror.sh | sudo bash
set -u
RUNS=${RUNS:-2}; TIMEOUT=${TIMEOUT:-8}; DRY=${DRY:-0}
G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; B=$'\e[1m'; N=$'\e[0m'

command -v curl >/dev/null || { echo "${R}Cần curl${N}"; exit 1; }
[ "$(id -u)" -eq 0 ] || [ "$DRY" = 1 ] || { echo "${R}Chạy bằng root/sudo (hoặc DRY=1 để chỉ test)${N}"; exit 1; }

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

# pick "Tiêu đề" "base|testurl" ... -> in bảng, set BEST, BEST_SPD
pick() {
  local title=$1; shift
  local res=() e base url s sorted first=1
  echo; echo "${B}== $title ==${N}"
  for e in "$@"; do
    base=${e%%|*}; url=${e#*|}
    printf '  testing %-60s\r' "$base" >&2
    s=$(bench "$url")
    res+=("$s|$base")
  done
  printf '%80s\r' '' >&2
  sorted=$(printf '%s\n' "${res[@]}" | sort -t'|' -k1,1nr)
  printf '| %-52s | %12s |\n' "Mirror" "Speed Avg"
  printf '|%s|%s|\n' "$(printf -- '-%.0s' {1..54})" "$(printf -- '-%.0s' {1..14})"
  while IFS='|' read -r s base; do
    if [ "$first" = 1 ] && [ "$s" != 0 ]; then
      printf "| ${G}%-52s${N} | ${G}%12s${N} |\n" "★ $base" "$(human "$s")"
    else
      printf '| %-52s | %12s |\n' "$base" "$(human "$s")"
    fi
    first=0
  done <<<"$sorted"
  BEST=$(head -1 <<<"$sorted"); BEST_SPD=${BEST%%|*}; BEST=${BEST#*|}
}

backup() { [ -f "$1" ] && cp -a "$1" "$1.bak.$(date +%s)"; }
SUMMARY=()

# ================= APT (Ubuntu) =================
if [ -r /etc/os-release ] && . /etc/os-release && [ "${ID:-}" = ubuntu ]; then
  CODENAME=${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}
  ARCH=$(dpkg --print-architecture)
  case $ARCH in amd64 | i386) SUF=ubuntu ;; *) SUF=ubuntu-ports ;; esac

  FILES=()
  [ -f /etc/apt/sources.list.d/ubuntu.sources ] && FILES+=(/etc/apt/sources.list.d/ubuntu.sources)
  [ -f /etc/apt/sources.list ] && grep -qE '^deb ' /etc/apt/sources.list && FILES+=(/etc/apt/sources.list)

  CUR=""
  [ ${#FILES[@]} -gt 0 ] && CUR=$(grep -hE '^(URIs:|deb )' "${FILES[@]}" | grep -v security.ubuntu.com |
    grep -oE 'https?://[^ ]+/ubuntu(-ports)?/?' | head -1)
  [ -n "$CUR" ] && CUR="${CUR%/}/"

  LIST="$CUR
http://archive.ubuntu.com/ubuntu/
http://vn.archive.ubuntu.com/ubuntu/
http://sg.archive.ubuntu.com/ubuntu/
http://mirror.bizflycloud.vn/ubuntu/
http://opensource.xtdv.net/ubuntu/
http://mirror.viettelcloud.vn/ubuntu/
http://mirrors.nhanhoa.com/ubuntu/
http://mirror.kakao.com/ubuntu/
http://ftp.jaist.ac.jp/pub/Linux/ubuntu/
http://mirrors.tuna.tsinghua.edu.cn/ubuntu/
${EXTRA_APT:-}"
  # mirror gợi ý theo vị trí từ Canonical
  [ "$SUF" = ubuntu ] && LIST="$LIST
$(curl -s --max-time 5 http://mirrors.ubuntu.com/mirrors.txt | head -8)"

  if [ "$SUF" = ubuntu-ports ]; then
    LIST=$(sed -E 's#archive\.ubuntu\.com/ubuntu/?#ports.ubuntu.com/ubuntu-ports/#; s#/ubuntu/?$#/ubuntu-ports/#' <<<"$LIST")
    LIST="$LIST
http://ports.ubuntu.com/ubuntu-ports/"
  fi

  ARGS=()
  while read -r m; do
    [ -z "$m" ] && continue
    m="${m%/}/"
    ARGS+=("$m|${m}dists/$CODENAME/main/binary-$ARCH/Packages.gz")
  done < <(tr ' ' '\n' <<<"$LIST" | grep -E '^https?://' | sed 's#/*$#/#' | awk '!s[$0]++')

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
      sed -E -i "/security\.ubuntu\.com/! { /^(URIs:|deb(-src)? )/ s#https?://[^ ]+/ubuntu(-ports)?/?#$BEST# }" "$f"
    done
    echo "  apt-get update..."
    if apt-get update -qq; then
      SUMMARY+=("${G}APT: đã đổi sang $BEST${N} (backup *.bak.*)")
    else
      SUMMARY+=("${R}APT: đổi sang $BEST nhưng apt update lỗi — khôi phục từ *.bak.*${N}")
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
    P+=("$m|${m}numpy/")
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
    P+=("$m|${m}typescript")
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
