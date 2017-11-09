# ------ Color Config ------
grep '^# Custom Color Config' /etc/profile>/dev/null 2>&1 || cat >> /etc/profile <<COLOR
# Custom Color Config $(date +%F_%T)
export red='\e[1;31m'
export redbg='\e[1;41m'
export blue='\e[1;34m'
export bluebg='\e[1;44m'
export green='\e[1;32m'
export greenbg='\e[1;42m'
export eol='\e[0m'
COLOR
source /etc/profile

# ----- Check Root User Privileges -----
if [ $(id -u) != 0 ]; then
    echo -e "${redbg}${green}Error: You Must Be root To Run This Script, su root Please ...{$eol}"
    exit 1
fi

