#!/data/data/com.termux/files/usr/bin/bash
# KOJENG v3.2 - 3D logo, UTF-8 safe, terminal stable

[ -z "$BASH_VERSION" ] && { echo "Gunakan: bash kojeng.sh"; exit 1; }

# === FIX 1: Force UTF-8 locale clean ===
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export TERM="${TERM:-xterm-256color}"

# === FIX 2: Reset terminal on exit (cegah freeze saat Ctrl+C) ===
stty sane 2>/dev/null
trap 'stty sane 2>/dev/null; printf "\033[0m\n"; exit 130' INT

R=$'\033[1;31m'; G=$'\033[1;32m'; Y=$'\033[1;33m'
C=$'\033[1;36m'; W=$'\033[1;37m'; M=$'\033[1;35m'; N=$'\033[0m'

LOG_DIR="$HOME/.kojeng/logs"
mkdir -p "$LOG_DIR" 2>/dev/null

# ============ HELPERS ============
need() { command -v "$1" >/dev/null 2>&1; }

# Safe clear (fallback kalau clear error)
cls() { clear 2>/dev/null || printf '\033[2J\033[H'; }

pause() {
    printf "\n%s[ENTER]%s lanjut  %s[B]%s back  %s[0]%s main\n> " \
        "$C" "$N" "$Y" "$N" "$R" "$N"
    read -r ans || return 0
    case "$ans" in
        b|B|back) return 1 ;;
        0)        return 2 ;;
        *)        return 0 ;;
    esac
}

ensure() {
    local cmd="$1" pkg="$2"
    need "$cmd" && return 0
    printf "%s[!] '%s' belum ada. Install '%s'? (y/n): %s" "$Y" "$cmd" "$pkg" "$N"
    read -r a
    if [ "$a" = "y" ] || [ "$a" = "Y" ]; then
        echo -e "${C}[*] pkg install $pkg...${N}"
        if pkg install "$pkg" -y >/dev/null 2>&1; then
            echo -e "${G}[+] Installed${N}"
            return 0
        fi
        echo -e "${R}[!] Gagal install${N}"
    fi
    return 1
}

save_log() {
    local prefix="$1" content="$2"
    local f="$LOG_DIR/${prefix}_$(date +%Y%m%d_%H%M%S).log"
    printf "%s\n" "$content" > "$f" 2>/dev/null && echo -e "\n${G}[+] Log: $f${N}"
}

back_anim() {
    local dest="${1:-menu}"
    echo
    for i in 1 2 3; do
        local dots=""
        local j
        for j in $(seq 1 "$i"); do dots+="."; done
        printf "\r${Y}  <<  Kembali ke ${dest} ${C}%s${N}   " "$dots"
        sleep 0.12
    done
    printf "\r${Y}  <<  Kembali ke ${dest}          ${N}\n"
    printf "  ${G}["
    local k
    for k in $(seq 1 20); do printf "#"; sleep 0.02; done
    printf "]${N} ${G}100%%${N}\n"
    printf "\r${G}  [+] ${W}Selamat datang di ${dest}${N}          \n"
    sleep 0.3
    cls
}

# ============ LOGO 3D ============
logo() {
    echo -e "${G}"
    cat <<'EOF'
██╗  ██╗ ██████╗      ██╗███████╗███╗   ██╗ ██████╗ 
██║ ██╔╝██╔═══██╗     ██║██╔════╝████╗  ██║██╔════╝ 
█████╔╝ ██║   ██║     ██║█████╗  ██╔██╗ ██║██║  ███╗
██╔═██╗ ██║   ██║██   ██║██╔══╝  ██║╚██╗██║██║   ██║
██║  ██╗╚██████╔╝╚█████╔╝███████╗██║ ╚████║╚██████╔╝
╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
EOF
    echo -e "${N}"
}

banner() {
    cls
    logo
    echo -e "${C}          >>> KOJENG v3.2 - Stable <<<${N}\n"
}

sub_header() {
    echo -e "${G}+--------------------------------------+${N}"
    printf "${G}|${N}  ${C}%-34s${G}|${N}\n" "$1"
    echo -e "${G}+--------------------------------------+${N}"
}

# ============ BOOT ANIMATIONS ============
anim_wakeup() {
    cls
    printf "${G}Termux Session ${N}"
    local i
    for i in 1 2 3 4 5; do printf "${G}.${N}"; sleep 0.1; done
    echo -e "\n${C}[*] Initializing bootloader...${N}"
    sleep 0.3
}

# === FIX 3: Matrix rain pakai ASCII (bukan UTF-8 Jepang) ===
anim_matrix_intro() {
    local chars="0123456789ABCDEF"
    local clen=${#chars}
    cls
    echo -e "${G}+--------------------------------------+${N}"
    echo -e "${G}|${C}   KOJENG SECURE BOOT SEQUENCE v3.2  ${G}|${N}"
    echo -e "${G}+--------------------------------------+${N}"
    echo
    local t i idx line
    for t in $(seq 1 15); do
        line=""
        for i in $(seq 1 50); do
            if (( RANDOM % 4 == 0 )); then
                idx=$(( RANDOM % clen ))
                line+="${G}${chars:$idx:1}${N}"
            elif (( RANDOM % 3 == 0 )); then
                idx=$(( RANDOM % clen ))
                line+="\033[2;32m${chars:$idx:1}${N}"
            else
                line+=" "
            fi
        done
        echo -e "$line"
        sleep 0.04
    done
    sleep 0.2
    stty sane 2>/dev/null
}

anim_glitch_logo() {
    cls
    local word="KOJENG"
    local glitch='#@%&*!$?<>/\|'
    local glen=${#glitch}
    local f i gi out
    for ((f=0; f<4; f++)); do
        cls; echo; echo
        out=""
        for ((i=0; i<${#word}; i++)); do
            if (( RANDOM % 2 == 0 )); then
                gi=$(( RANDOM % glen ))
                out+="${R}${glitch:$gi:1}${N}"
            else
                out+="${G}${word:$i:1}${N}"
            fi
        done
        echo -e "        ${out}"
        echo -e "        ${R}.............${N}"
        sleep 0.06
    done
    cls; echo; echo
    echo -e "        ${G}K O J E N G${N}"
    echo -e "        ${G}===========${N}"
    sleep 0.2
    stty sane 2>/dev/null
}

anim_syscheck() {
    cls
    echo -e "${C}+--[ SECURITY CHECK ]-----------------+${N}"
    local mods=("Kernel integrity" "Encryption module" "Network interface" "Payload database" "Cyber engine")
    local m s
    for m in "${mods[@]}"; do
        printf "${G}|${N} ${C}[*]${N} %-24s" "$m"
        for s in "|" "/" "-" "\\"; do
            printf "\b${Y}${s}${N}"
            sleep 0.05
        done
        printf "\b${G}[ OK ]${N}\n"
    done
    echo -e "${C}+--------------------------------------+${N}"
    sleep 0.2
    stty sane 2>/dev/null
}

anim_loading_bar() {
    echo
    printf "${G}  Loading ${N}["
    local i
    for ((i=0; i<30; i++)); do
        printf "${G}#${N}"
        sleep 0.02
    done
    printf "] ${G}100%%${N}\n"
    echo
    stty sane 2>/dev/null
}

anim_access() {
    cls; echo; echo
    echo -e "${R}        ACCESS DENIED${N}"
    sleep 0.15
    cls; echo; echo
    echo -e "${G}        [+] ACCESS GRANTED${N}"
    echo -e "${G}        WELCOME, OPERATOR${N}"
    sleep 0.3
    stty sane 2>/dev/null
}

boot() {
    anim_wakeup
    anim_matrix_intro
    anim_glitch_logo
    anim_syscheck
    anim_loading_bar
    anim_access
    cls
    logo
    echo -e "${C}        >>> CYBER JACKING FRAMEWORK <<<${N}"
    echo -e "${M}          * Powered by Kojeng Team *${N}\n"
    echo -e "${G}[+] ${W}Sistem siap, Operator.${N}"
    sleep 0.8
    # === FIX 4: Reset terminal setelah boot ===
    stty sane 2>/dev/null
}

# ============ 1) NETWORK SCAN ============
m_scan() {
    while true; do
        banner
        sub_header "NETWORK SCAN"
        echo -e "${Y}[1]${N} Nmap fast        ${Y}[4]${N} Ping test"
        echo -e "${Y}[2]${N} Nmap full port   ${Y}[5]${N} Traceroute"
        echo -e "${Y}[3]${N} Nmap service ver ${Y}[6]${N} Port check (nc)"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) ensure nmap nmap || { pause; continue; }
               read -p "Target: " t
               nmap -T4 -F "$t"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) ensure nmap nmap || { pause; continue; }
               read -p "Target: " t
               echo -e "${R}[!] Full scan bisa lama${N}"
               nmap -T4 -p- "$t"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) ensure nmap nmap || { pause; continue; }
               read -p "Target: " t
               nmap -sV "$t"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) read -p "Host: " h
               ping -c4 "$h"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            5) ensure traceroute traceroute || { pause; continue; }
               read -p "Target: " t
               traceroute "$t"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            6) ensure nc netcat-openbsd || { pause; continue; }
               read -p "Host: " h
               read -p "Port: " p
               nc -zv -w3 "$h" "$p" 2>&1
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 2) WEB RECON ============
m_web() {
    while true; do
        banner
        sub_header "WEB RECON"
        echo -e "${Y}[1]${N} HTTP headers     ${Y}[4]${N} HTTP methods"
        echo -e "${Y}[2]${N} SSL certificate  ${Y}[5]${N} Directory check"
        echo -e "${Y}[3]${N} Robots.txt"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) read -p "URL: " u
               curl -sIL "$u" | head -25
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) ensure openssl openssl-tool || { pause; continue; }
               read -p "Domain: " d
               echo | openssl s_client -servername "$d" -connect "$d:443" 2>/dev/null \
                   | openssl x509 -noout -subject -dates
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) read -p "Domain: " d
               curl -s "http://$d/robots.txt" | head -40
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) read -p "URL: " u
               curl -s -X OPTIONS -i "$u" | head -20
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            5) read -p "Domain: " d
               for p in admin login wp-admin .env backup config.php phpinfo.php server-status; do
                   code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 3 "http://$d/$p")
                   if [ -n "$code" ] && [ "$code" != "404" ] && [ "$code" != "000" ]; then
                       echo -e "${G}[$code]${N} http://$d/$p"
                   fi
               done
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 3) DNS TOOLS ============
m_dns() {
    while true; do
        banner
        sub_header "DNS TOOLS"
        echo -e "${Y}[1]${N} Dig ANY          ${Y}[3]${N} Reverse DNS"
        echo -e "${Y}[2]${N} Dig specific     ${Y}[4]${N} Host lookup"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) ensure dig dnsutils || { pause; continue; }
               read -p "Domain: " d
               dig "$d" ANY +noall +answer
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) ensure dig dnsutils || { pause; continue; }
               read -p "Domain: " d
               read -p "Type (A/MX/TXT/NS): " t
               dig "$d" "$t" +noall +answer
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) ensure dig dnsutils || { pause; continue; }
               read -p "IP: " ip
               dig -x "$ip" +noall +answer
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) ensure host dnsutils || { pause; continue; }
               read -p "Domain/IP: " d
               host "$d"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 4) OSINT ============
m_osint() {
    while true; do
        banner
        sub_header "OSINT"
        echo -e "${Y}[1]${N} My public IP     ${Y}[3]${N} Whois domain"
        echo -e "${Y}[2]${N} IP geolocation   ${Y}[4]${N} Whois IP"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) curl -s https://api.ipify.org; echo
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) read -p "IP: " ip
               curl -s "http://ip-api.com/json/$ip?fields=query,country,regionName,city,isp,org,as,timezone"; echo
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) ensure whois whois || { pause; continue; }
               read -p "Domain: " d
               whois "$d" | head -30
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) ensure whois whois || { pause; continue; }
               read -p "IP: " ip
               whois "$ip" | head -20
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 5) PASSWORD TOOLS ============
m_pass() {
    while true; do
        banner
        sub_header "PASSWORD TOOLS"
        echo -e "${Y}[1]${N} Generate password"
        echo -e "${Y}[2]${N} Hash string (md5/sha1/sha256)"
        echo -e "${Y}[3]${N} Base64 encode/decode"
        echo -e "${Y}[4]${N} Verify hash (compare)"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) read -p "Length (1-256): " n
               if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -gt 0 ] && [ "$n" -le 256 ]; then
                   LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c "$n"; echo
               else
                   echo -e "${R}[!] Length harus 1-256${N}"
               fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) read -p "String: " s
               echo -e "  MD5   : $(printf %s "$s" | md5sum | cut -d' ' -f1)"
               echo -e "  SHA1  : $(printf %s "$s" | sha1sum | cut -d' ' -f1)"
               echo -e "  SHA256: $(printf %s "$s" | sha256sum | cut -d' ' -f1)"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) read -p "(e)ncode/(d)ecode: " m
               read -p "String: " s
               if [ "$m" = "e" ]; then printf %s "$s" | base64
               else printf %s "$s" | base64 -d 2>/dev/null || echo -e "${R}[!] Bukan base64 valid${N}"; echo; fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) read -p "String asli: " s
               read -p "Hash target: " h
               echo -e "  MD5    : $([ "$(printf %s "$s" | md5sum | cut -d' ' -f1)" = "$h" ] && echo "${G}MATCH${N}" || echo "no")"
               echo -e "  SHA1   : $([ "$(printf %s "$s" | sha1sum | cut -d' ' -f1)" = "$h" ] && echo "${G}MATCH${N}" || echo "no")"
               echo -e "  SHA256 : $([ "$(printf %s "$s" | sha256sum | cut -d' ' -f1)" = "$h" ] && echo "${G}MATCH${N}" || echo "no")"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 6) SYSTEM INFO ============
m_sysinfo() {
    while true; do
        banner
        sub_header "SYSTEM INFO"
        echo -e "${Y}[1]${N} Device info      ${Y}[4]${N} Running processes"
        echo -e "${Y}[2]${N} Storage usage    ${Y}[5]${N} Termux environment"
        echo -e "${Y}[3]${N} Network interfaces"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) echo -e "${C}=== Device ===${N}"
               uname -a
               echo
               echo -e "${C}=== Android ===${N}"
               if need getprop; then
                   echo "Model  : $(getprop ro.product.model 2>/dev/null)"
                   echo "Brand  : $(getprop ro.product.brand 2>/dev/null)"
                   echo "Android: $(getprop ro.build.version.release 2>/dev/null)"
                   echo "SDK    : $(getprop ro.build.version.sdk 2>/dev/null)"
               else
                   echo "(getprop tidak tersedia)"
               fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) echo -e "${C}=== Storage ===${N}"
               df -h "$HOME" 2>/dev/null
               echo
               echo -e "${C}=== Ukuran HOME ===${N}"
               du -sh "$HOME" 2>/dev/null
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) echo -e "${C}=== Network ===${N}"
               if need ip; then ip addr 2>/dev/null
               elif need ifconfig; then ifconfig 2>/dev/null
               else echo "(ip/ifconfig tidak tersedia)"; fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) echo -e "${C}=== Processes (top 20) ===${N}"
               ps aux 2>/dev/null | head -21
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            5) echo -e "${C}=== Termux Env ===${N}"
               echo "PREFIX : $PREFIX"
               echo "HOME   : $HOME"
               echo "SHELL  : $SHELL"
               echo "BASH   : $BASH_VERSION"
               echo "LANG   : $LANG"
               echo "LC_ALL : $LC_ALL"
               echo "TERM   : $TERM"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 7) UTILITIES ============
m_utils() {
    while true; do
        banner
        sub_header "UTILITIES"
        echo -e "${Y}[1]${N} Extract archive  ${Y}[5]${N} View logs"
        echo -e "${Y}[2]${N} QR generator     ${Y}[6]${N} Clean cache"
        echo -e "${Y}[3]${N} URL shortener    ${Y}[7]${N} Speed test"
        echo -e "${Y}[4]${N} Subdomain finder"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            1) read -p "File archive: " f
               if [ -f "$f" ]; then
                   case "$f" in
                       *.tar.gz|*.tgz) tar xzf "$f" && echo -e "${G}[+] Extracted${N}" ;;
                       *.tar.bz2)     tar xjf "$f" && echo -e "${G}[+] Extracted${N}" ;;
                       *.tar.xz)      tar xJf "$f" && echo -e "${G}[+] Extracted${N}" ;;
                       *.zip)         ensure unzip unzip && unzip "$f" ;;
                       *.rar)         ensure unrar unrar && unrar x "$f" ;;
                       *) echo -e "${R}[!] Format tidak dikenal${N}" ;;
                   esac
               else
                   echo -e "${R}[!] File tidak ada${N}"
               fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) ensure qrencode qrencode || { pause; continue; }
               read -p "Text/URL: " q
               qrencode -t ANSIUTF8 "$q"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) read -p "URL panjang: " u
               curl -s "https://tinyurl.com/api-create.php?url=$u"; echo
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            4) read -p "Domain: " d
               for sub in www mail ftp admin api dev test blog shop cdn static; do
                   if host "$sub.$d" 2>/dev/null | grep -q "has address"; then
                       echo -e "${G}[FOUND]${N} $sub.$d"
                   fi
               done
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            5) if [ -d "$LOG_DIR" ]; then
                   ls -lh "$LOG_DIR" 2>/dev/null
               else
                   echo "(belum ada log)"
               fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            6) read -p "Hapus isi ~/.cache? (y/n): " a
               if [ "$a" = "y" ]; then
                   rm -rf "$HOME/.cache"/* 2>/dev/null
                   echo -e "${G}[+] Cache dibersihkan${N}"
               fi
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            7) echo -e "${C}[*] Testing download speed (1MB)...${N}"
               curl -o /dev/null -w "Speed: %{speed_download} B/s\nTime: %{time_total}s\nSize: %{size_download} B\n" \
                   --max-time 15 "http://speedtest.tele2.net/1MB.zip" 2>/dev/null \
                   || echo -e "${R}[!] Gagal konek${N}"
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 8) FUN / EFFECT ============
m_fun() {
    while true; do
        banner
        sub_header "FUN / EFFECT"
        echo -e "${Y}[1]${N} Matrix rain"
        echo -e "${Y}[2]${N} Hacker typing"
        echo -e "${Y}[3]${N} Fake breach"
        echo -e "${R}[0] << BACK${N}"
        echo -ne "${G}> ${N}"
        read -r c || { back_anim "menu utama"; return; }
        case "$c" in
            # === FIX 5: Matrix rain ASCII ===
            1) local chars="0123456789ABCDEF"
               local clen=${#chars}
               local t i idx line
               for t in $(seq 1 40); do
                   line=""
                   for i in $(seq 1 50); do
                       if (( RANDOM % 3 == 0 )); then
                           idx=$(( RANDOM % clen ))
                           line+="${G}${chars:$idx:1}${N}"
                       else line+=" "; fi
                   done
                   echo -e "$line"; sleep 0.05
               done
               stty sane 2>/dev/null
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            2) local txt="Initializing Kojeng... Access granted!"
               local i
               for ((i=0; i<${#txt}; i++)); do
                   printf "${G}%s${N}" "${txt:$i:1}"; sleep 0.04
               done; echo
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            3) for s in "Scanning ports..." "Injecting payload..." "Decrypting hashes..." "Bypassing firewall..." "ACCESS GRANTED"; do
                   echo -e "${G}[*] $s${N}"; sleep 0.6
               done
               pause; r=$?
               [ "$r" -eq 1 ] && continue
               [ "$r" -eq 2 ] && { back_anim "menu utama"; return; } ;;
            0) back_anim "menu utama"; return ;;
            *) echo -e "${R}[!] Salah${N}"; sleep 1 ;;
        esac
    done
}

# ============ 9) INSTALL TOOLS ============
install_tools() {
    cls
    echo -e "${C}[*] Installing tools...${N}\n"
    for t in nmap whois dnsutils curl wget openssl-tool traceroute git python netcat-openbsd unzip qrencode; do
        printf "  %-22s" "$t"
        if pkg install "$t" -y >/dev/null 2>&1; then
            echo -e "${G}[OK]${N}"
        else
            echo -e "${R}[SKIP]${N}"
        fi
    done
    echo -e "\n${G}[+] Done${N}"
}

# ============ MAIN MENU ============
menu_main() {
    echo -e "${G}+-[${W}MAIN MENU v3.2${G}]-------------+${N}"
    echo -e "${G}|${N} ${Y}[1]${N} ${C}Network Scan${N}              ${G}|${N}"
    echo -e "${G}|${N} ${Y}[2]${N} ${C}Web Recon${N}                 ${G}|${N}"
    echo -e "${G}|${N} ${Y}[3]${N} ${C}DNS Tools${N}                 ${G}|${N}"
    echo -e "${G}|${N} ${Y}[4]${N} ${C}OSINT${N}                     ${G}|${N}"
    echo -e "${G}|${N} ${Y}[5]${N} ${C}Password Tools${N}            ${G}|${N}"
    echo -e "${G}|${N} ${Y}[6]${N} ${C}System Info${N}               ${G}|${N}"
    echo -e "${G}|${N} ${Y}[7]${N} ${C}Utilities${N}                 ${G}|${N}"
    echo -e "${G}|${N} ${Y}[8]${N} ${C}Fun/Effect${N}                ${G}|${N}"
    echo -e "${G}|${N} ${Y}[9]${N} ${C}Install All Tools${N}         ${G}|${N}"
    echo -e "${G}|${N} ${Y}[0]${N} ${R}Exit${N}                      ${G}|${N}"
    echo -e "${G}+-----------------------------+${N}"
    echo -ne "${G}kojeng${N}${W}@${N}${G}termux${N}${W}>${N} "
}

# ============ BOOT ============
boot

# ============ MAIN LOOP ============
while true; do
    banner
    menu_main
    read -r choice || { echo -e "\n${R}Bye${N}"; exit 0; }
    case "$choice" in
        1) m_scan ;;
        2) m_web ;;
        3) m_dns ;;
        4) m_osint ;;
        5) m_pass ;;
        6) m_sysinfo ;;
        7) m_utils ;;
        8) m_fun ;;
        9) install_tools
           pause; r=$?
           [ "$r" -eq 2 ] && continue ;;
        0) echo -e "\n${R}  [!] Keluar dari KOJENG...${N}"; exit 0 ;;
        *) echo -e "${R}[!] Pilihan salah${N}"; sleep 1 ;;
    esac
done
