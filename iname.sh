#!/bin/bash

# iname - Enhanced Kernel Information Utility
# Version: 2.0
# Author: $(whoami)
# Description: Comprehensive kernel information and analysis tool

SCRIPT_NAME="iname"
SCRIPT_VERSION="2.0"

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Status indicators
OK="${GREEN}[OK]${NC}"
FAIL="${RED}[FAIL]${NC}"
INFO="${BLUE}[INFO]${NC}"
WARN="${YELLOW}[WARN]${NC}"

# Function to show version information
show_version() {
    echo "iname v1.0"
    echo "This is free software utility for GNU/Linux OS"
    echo "author: Iván Rodriguez // https://github.com/IRodriguez13"
}

# Function to check command availability
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect virtualization
detect_virtualization() {
    echo -e "${BOLD}Virtualization Environment:${NC}"
    
    local virt_detected=false
    
    # systemd-detect-virt
    if command_exists systemd-detect-virt; then
        local virt=$(systemd-detect-virt 2>/dev/null)
        if [[ "$virt" != "none" ]]; then
            echo -e "  $OK Type: $virt"
            virt_detected=true
        else
            echo -e "  $OK Type: Bare metal"
        fi
    else
        echo -e "  $INFO systemd-detect-virt not available"
    fi
    
    # CPU hypervisor flag
    if grep -q "hypervisor" /proc/cpuinfo; then
        echo -e "  $OK Hypervisor: CPU flags detected"
        virt_detected=true
    fi
    
    # Container detection
    if [[ -f /.dockerenv ]]; then
        echo -e "  $OK Container: Docker"
        virt_detected=true
    fi
    
    if grep -q "container" /proc/1/environ 2>/dev/null; then
        echo -e "  $OK Container: LXC/LXD"
        virt_detected=true
    fi
    
    if [[ "$virt_detected" == false ]]; then
        echo -e "  $INFO No virtualization detected"
    fi
}

# Function to get security information
get_security_info() {
    echo -e "${BOLD}Security Status:${NC}"
    
    # SELinux
    if command_exists sestatus; then
        local selinux_status=$(sestatus 2>/dev/null | grep "SELinux status" | cut -d: -f2 | tr -d ' ' | head -1)
        local selinux_mode=$(sestatus 2>/dev/null | grep "Current mode" | cut -d: -f2 | tr -d ' ' | head -1)
        if [[ -n "$selinux_status" ]]; then
            echo -e "  $OK SELinux: $selinux_status ($selinux_mode)"
        fi
    elif command_exists getenforce; then
        echo -e "  $OK SELinux: $(getenforce 2>/dev/null)"
    else
        echo -e "  $INFO SELinux: Not available"
    fi
    
    # AppArmor
    if command_exists aa-status; then
        if aa-status --enabled 2>/dev/null; then
            local aa_profiles=$(aa-status 2>/dev/null | grep -E "profiles are loaded" | cut -d' ' -f1)
            echo -e "  $OK AppArmor: Enabled ($aa_profiles profiles)"
        else
            echo -e "  $INFO AppArmor: Disabled"
        fi
    else
        echo -e "  $INFO AppArmor: Not available"
    fi
    
    # Kernel security features
    if [[ -d "/sys/kernel/security" ]]; then
        echo -e "  $OK SecurityFS: Mounted"
    fi
    
    # Kernel pointer authentication
    if grep -q "paca" /proc/cpuinfo 2>/dev/null; then
        echo -e "  $OK PAC: Pointer Authentication available"
    fi
}

# Function to get kernel build and OS information
get_kernel_build_info() {
    echo -e "${BOLD}Kernel Build Information:${NC}"
    
    # Kernel version
    echo -e "  $OK Version: $(uname -r)"
    
    # Build information
    if [[ -f /proc/version ]]; then
        local build_string=$(cat /proc/version | sed 's/^Linux version //')
        echo -e "  $OK Build: $build_string"
    fi
    
    # OS information
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo -e "  $OK Distribution: $NAME $VERSION"
        echo -e "  $OK ID: $ID"
    elif command_exists lsb_release; then
        local distro=$(lsb_release -d | cut -f2)
        echo -e "  $OK Distribution: $distro"
    fi
    
    # System architecture
    echo -e "  $OK Architecture: $(uname -m)"
    
    # Page size
    if command_exists getconf; then
        echo -e "  $OK Page Size: $(getconf PAGESIZE) bytes"
    fi
}

# Function to get kernel configuration
get_kernel_config() {
    echo -e "${BOLD}Kernel Configuration:${NC}"
    
    local config_file="/boot/config-$(uname -r)"
    local config_count=0
    
    if [[ ! -f "$config_file" ]]; then
        echo -e "  $FAIL Config file not available"
        return 1
    fi
    
    # Check important security features
    check_config_option() {
        local option=$1
        local description=$2
        local value=$(grep "^CONFIG_${option}=" "$config_file" 2>/dev/null | head -1 | cut -d= -f2)
        
        if [[ "$value" == "y" ]]; then
            echo -e "  $OK $description: Enabled"
            ((config_count++))
        elif [[ "$value" == "m" ]]; then
            echo -e "  $INFO $description: Module"
        elif [[ -n "$value" ]]; then
            echo -e "  $FAIL $description: Disabled"
        fi
    }
    
    check_config_option "KPTI" "Page Table Isolation"
    check_config_option "RETPOLINE" "Retpoline"
    check_config_option "CC_STACKPROTECTOR" "Stack Protector"
    check_config_option "CC_STACKPROTECTOR_STRONG" "Stack Protector Strong"
    check_config_option "SLAB_FREELIST_HARDENED" "SLAB Freelist Hardening"
    check_config_option "STATIC_USERMODEHELPER" "Static Usermode Helper"
    
    echo -e "  $INFO Features checked: $config_count"
}

# Function to get hardware information
get_hardware_info() {
    echo -e "${BOLD}Hardware Information:${NC}"
    
    # CPU information
    local cpu_cores=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo)
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//')
    
    echo -e "  $OK CPU Cores: $cpu_cores"
    if [[ -n "$cpu_model" ]]; then
        echo -e "  $OK CPU Model: $cpu_model"
    fi
    
    # Memory information
    if [[ -f /proc/meminfo ]]; then
        local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2 $3}')
        echo -e "  $OK Memory Total: $mem_total"
    fi
    
    # Boot method
    if [[ -d /sys/firmware/efi ]]; then
        echo -e "  $OK Boot: UEFI"
    else
        echo -e "  $OK Boot: Legacy BIOS"
    fi
}

# Function to get kernel runtime information
get_runtime_info() {
    echo -e "${BOLD}Kernel Runtime:${NC}"
    
    # Uptime
    if [[ -f /proc/uptime ]]; then
        local uptime_seconds=$(cut -d' ' -f1 /proc/uptime)
        local uptime_days=$(echo "scale=1; $uptime_seconds/86400" | bc)
        echo -e "  $OK Uptime: $uptime_days days"
    fi
    
    # Load average
    if [[ -f /proc/loadavg ]]; then
        local loadavg=$(cat /proc/loadavg | cut -d' ' -f1-3)
        echo -e "  $OK Load Average: $loadavg"
    fi
    
    # Kernel time
    local kernel_time=$(date -d "@$(cut -d' ' -f1 /proc/uptime)" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
    echo -e "  $OK Boot Time: $kernel_time"
    
    # Time source
    if command_exists chronyc; then
        local chrony_status=$(chronyc sources 2>/dev/null | grep "^^\*" | head -1)
        if [[ -n "$chrony_status" ]]; then
            echo -e "  $OK Time Sync: Chrony active"
        fi
    elif command_exists ntpq; then
        local ntp_status=$(ntpq -p 2>/dev/null | grep "^*" | head -1)
        if [[ -n "$ntp_status" ]]; then
            echo -e "  $OK Time Sync: NTP active"
        fi
    fi
}

# Function to get filesystem information
get_filesystem_info() {
    echo -e "${BOLD}Filesystem Information:${NC}"
    
    # Root filesystem
    local root_fs=$(findmnt -n -o FSTYPE /)
    local root_dev=$(findmnt -n -o SOURCE /)
    
    echo -e "  $OK Root FS: $root_fs"
    echo -e "  $OK Root Device: $root_dev"
    
    # Available filesystems
    local supported_fs=$(cat /proc/filesystems | awk '{print $1}' | tr '\n' ' ' | sed 's/ $//')
    echo -e "  $INFO Supported FS: $supported_fs"
    
    # Inotify limits
    if [[ -f /proc/sys/fs/inotify/max_user_watches ]]; then
        local inotify_watches=$(cat /proc/sys/fs/inotify/max_user_watches)
        echo -e "  $OK Inotify Watches: $inotify_watches"
    fi
}

# Function to get network stack information
get_network_info() {
    echo -e "${BOLD}Network Stack:${NC}"
    
    # TCP congestion control
    local tcp_congestion=$(cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || echo "unknown")
    echo -e "  $OK TCP Congestion: $tcp_congestion"
    
    # Network stack features
    if [[ -d /sys/kernel/debug/tracing/events/net ]]; then
        echo -e "  $OK Network Tracing: Available"
    fi
    
    # Connection tracking
    if [[ -d /proc/sys/net/netfilter ]]; then
        echo -e "  $OK Netfilter: Available"
    fi
}

# Function to get basic kernel information
get_basic_info() {
    local real_sysname=$(uname -s)
    local real_release=$(uname -r)
    local real_version=$(uname -v)
    local real_machine=$(uname -m)
    local real_processor=$(uname -p 2>/dev/null || echo "unknown")
    local real_hardware=$(uname -i 2>/dev/null || echo "unknown")
    local real_os=$(uname -o 2>/dev/null || echo "unknown")
    
    case "$1" in
        -s|--kernel-name)
            echo "The Linux Kernel"
            ;;
        -r|--kernel-release)
            echo "$real_release"
            ;;
        -v|--kernel-version)
            echo "$real_version"
            ;;
        -m|--machine)
            echo "$real_machine"
            ;;
        -p|--processor)
            echo "$real_processor"
            ;;
        -i|--hardware-platform)
            echo "$real_hardware"
            ;;
        -o|--operating-system)
            echo "$real_os"
            ;;
        -a|--all)
            echo "The Linux Kernel $real_release $real_version $real_machine"
            ;;
    esac
}

# Function to display comprehensive technical information
get_technical_info() {
    echo -e "${BOLD}${CYAN}"
    echo "┌──────────────────────────────────────────────────────────────┐"
    echo "│                    KERNEL TECHNICAL REPORT                   │"
    echo "│                      iname v$SCRIPT_VERSION                          │"
    echo "└──────────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
    
    get_kernel_build_info
    echo
    get_hardware_info
    echo
    get_runtime_info
    echo
    get_kernel_config
    echo
    get_security_info
    echo
    detect_virtualization
    echo
    get_filesystem_info
    echo
    get_network_info
    
    echo
    echo -e "${BOLD}Report generated on: $(date)${NC}"
}

# Function to show help
show_help() {
    echo -e "${BOLD}${CYAN}$SCRIPT_NAME - Enhanced Kernel Information Utility v$SCRIPT_VERSION${NC}"
    echo
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $SCRIPT_NAME [OPTIONS]"
    echo
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -s, --kernel-name        Display kernel name"
    echo "  -r, --kernel-release     Display kernel release"
    echo "  -v, --kernel-version     Display kernel version"
    echo "  -m, --machine            Display machine architecture"
    echo "  -p, --processor          Display processor type"
    echo "  -i, --hardware-platform  Display hardware platform"
    echo "  -o, --operating-system   Display operating system"
    echo "  -a, --all                Display all basic information"
    echo "  -T, --technical          Display comprehensive technical report"
    echo "  -H, --hardware           Display hardware information"
    echo "  -N, --network            Display network stack information"
    echo "  -F, --filesystem         Display filesystem information"
    echo "  -h, --help               Display this help message"
    echo "  --version                Display iname version information"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "  $SCRIPT_NAME -T          # Full technical report"
    echo "  $SCRIPT_NAME -H          # Hardware information"
    echo "  $SCRIPT_NAME -N          # Network information"
    echo "  $SCRIPT_NAME -s          # Kernel name"
    echo
}

# Main execution
main() {
    # If no arguments, show kernel name
    if [[ $# -eq 0 ]]; then
        get_basic_info -s
        exit 0
    fi

    case "$1" in
        -s|--kernel-name|-r|--kernel-release|-v|--kernel-version|-m|--machine|-p|--processor|-i|--hardware-platform|-o|--operating-system|-a|--all)
            get_basic_info "$1"
            ;;
        -T|--technical)
            get_technical_info
            ;;
        -H|--hardware)
            get_hardware_info
            ;;
        -N|--network)
            get_network_info
            ;;
        -F|--filesystem)
            get_filesystem_info
            ;;
        -h|--help)
            show_help
            ;;
        --version)
            show_version
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"