#!/bin/bash

# iname-macos - macOS Kernel Information Utility
# iname - Enhanced Kernel Information Utility
# Version: 1.0
# Author: Iván E. Rodriguez
# Description: Comprehensive kernel information and analysis tool
# This is Free Software.

SCRIPT_NAME="iname-macos"
SCRIPT_VERSION="2.0"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Status indicators
OK="${GREEN}[OK]${NC}"
FAIL="${RED}[FAIL]${NC}"
INFO="${BLUE}[INFO]${NC}"
WARN="${YELLOW}[WARN]${NC}"

# Function to show version
show_version() {
    echo "iname v1.0 - This is a free software utility for MAC OS systems"
    echo "author: Iván Rodriguez // https://github.com/IRodriguez13"
}

# macOS specific functions
get_macos_kernel_info() {
    echo -e "${BOLD}macOS Kernel Information:${NC}"
    
    # Kernel version (XNU)
    echo -e "  $OK Kernel: $(uname -s) $(uname -r)"
    echo -e "  $OK Version: $(uname -v)"
    
    # macOS version
    if command -v sw_vers >/dev/null 2>&1; then
        local macos_version=$(sw_vers -productVersion)
        local build_version=$(sw_vers -buildVersion)
        echo -e "  $OK macOS: $macos_version (Build $build_version)"
    fi
    
    # Architecture
    echo -e "  $OK Architecture: $(uname -m)"
}

get_macos_hardware_info() {
    echo -e "${BOLD}macOS Hardware:${NC}"
    
    # CPU information
    if command -v sysctl >/dev/null 2>&1; then
        local cpu_brand=$(sysctl -n machdep.cpu.brand_string)
        local cpu_cores=$(sysctl -n hw.ncpu)
        echo -e "  $OK CPU: $cpu_brand"
        echo -e "  $OK Cores: $cpu_cores"
    fi
    
    # Memory
    if command -v sysctl >/dev/null 2>&1; then
        local mem_total=$(sysctl -n hw.memsize)
        local mem_gb=$((mem_total / 1024 / 1024 / 1024))
        echo -e "  $OK Memory: ${mem_gb} GB"
    fi
    
    # Model identifier
    if command -v sysctl >/dev/null 2>&1; then
        local model=$(sysctl -n hw.model)
        echo -e "  $OK Model: $model"
    fi
}

get_macos_security_info() {
    echo -e "${BOLD}macOS Security:${NC}"
    
    # SIP status
    if command -v csrutil >/dev/null 2>&1; then
        local sip_status=$(csrutil status 2>/dev/null | grep -o "enabled\|disabled" | head -1)
        if [[ "$sip_status" == "enabled" ]]; then
            echo -e "  $OK SIP: Enabled"
        else
            echo -e "  $INFO SIP: Disabled"
        fi
    else
        echo -e "  $INFO SIP: Status unknown"
    fi
    
    # Gatekeeper status
    local gatekeeper_status=$(spctl --status 2>/dev/null | grep -o "enabled\|disabled")
    if [[ "$gatekeeper_status" == "enabled" ]]; then
        echo -e "  $OK Gatekeeper: Enabled"
    else
        echo -e "  $INFO Gatekeeper: Disabled"
    fi
    
    # FileVault status
    local fv_status=$(fdesetup status 2>/dev/null | grep -o "On\|Off")
    if [[ "$fv_status" == "On" ]]; then
        echo -e "  $OK FileVault: Enabled"
    else
        echo -e "  $INFO FileVault: Disabled"
    fi
}

get_macos_system_info() {
    echo -e "${BOLD}System Information:${NC}"
    
    # Boot time
    if command -v sysctl >/dev/null 2>&1; then
        local boot_time=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
        local boot_date=$(date -r "$boot_time" +"%Y-%m-%d %H:%M:%S")
        echo -e "  $OK Boot Time: $boot_date"
    fi
    
    # Hostname
    echo -e "  $OK Hostname: $(hostname)"
    
    # Uptime
    if command -v uptime >/dev/null 2>&1; then
        local uptime_info=$(uptime | sed 's/^.*up //')
        echo -e "  $OK Uptime: $uptime_info"
    fi
}

# Main technical report for macOS
get_technical_info() {
    get_macos_kernel_info
    echo
    get_macos_hardware_info
    echo
    get_macos_system_info
    echo
    get_macos_security_info
    
    echo
    echo -e "${BOLD}Report generated on: $(date)${NC}"
}

# Help function
show_help() {
    echo -e "${BOLD}${CYAN}$SCRIPT_NAME - macOS Kernel Information Utility v$SCRIPT_VERSION${NC}"
    echo
    echo -e "${BOLD}USAGE:${NC}"
    echo "  $SCRIPT_NAME [OPTIONS]"
    echo
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -T, --technical    Display comprehensive technical report"
    echo "  -H, --hardware     Display hardware information"
    echo "  -S, --security     Display security information"
    echo "  --version          Display version information"
    echo "  -h, --help         Show this help message"
    echo
}

# Main execution
main() {
    if [[ $# -eq 0 ]]; then
        echo "macOS Kernel"
        exit 0
    fi

    case "$1" in
        -T|--technical)
            get_technical_info
            ;;
        -H|--hardware)
            get_macos_hardware_info
            ;;
        -S|--security)
            get_macos_security_info
            ;;
        --version)
            show_version
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"