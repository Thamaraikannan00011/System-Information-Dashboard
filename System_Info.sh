#!/bin/bash

#colour formatting

:' ========== MULTILINE COMMENT ==========
   syntax = '\033[type;color"m"'
   where, 
   type
	1-bold
	2-dim
	3-italic
	4-underline
	5-blinking
	7-reverse
	8-hidden
   color
	30-black
	31-red
	32-green
	33-yellow
	34-blue
	35-magenta
	36-cyan
	37-white
'
# colour 
black='\033[30m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[35m'
cyan='\033[36m'
white='\033[37m'

# Background colors
bg_black='\033[40m'
bg_red='\033[41m'
bg_green='\033[42m'
bg_yellow='\033[43m'
bg_blue='\033[44m'
bg_magenta='\033[45m'
bg_cyan='\033[46m'
bg_white='\033[47m'

#type
reset='\033[0m'        # Reset all attributes
bold='\033[1m'         # Bold or increased intensity
dim='\033[2m'          # Dim or secondary color
italic='\033[3m'       # Italic
underline='\033[4m'    # Underline
blink='\033[5m'        # Slow blink
reverse='\033[7m'      # Reverse (change foreground to background colour and background to foreground)
hidden='\033[8m'       # Hidden (invisible)
strike='\033[9m'       # Strikethrough

# function to visualize progress

progress_bar() {
    local percentage=$1    # Get the percentage from first argument
    local width=20         # Set bar width to 20 characters
    
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    # Build the progress bar
    printf "["                                    # Opening bracket
    printf "%*s" $filled | tr ' ' '|'            # Filled portion (+ = used block)
    printf "%*s" $empty | tr ' ' '.'             # Empty portion (- = unused shade)
    printf "] %3d%%\n" $percentage               # Closing bracket + percentage
}

# covert given bytes to human readable format

bytes_to_human() {
    local bytes=$1
    # Array of unit suffixes
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0

    # Divide by 1024 until we get a manageable number
    # Continue while bytes > 1024 AND we haven't reached the largest unit
    while [ $bytes -gt 1024 ] && [ $unit -lt 4 ]; do
        bytes=$((bytes / 1024))    # Integer division
        unit=$((unit + 1))         # Move to next unit
    done

    echo "${bytes}${units[$unit]}"
}

# convert the uptime to day, hour, minutes

get_uptime() {
    if [[ ! -f /proc/uptime ]]; then
        echo "Error: /proc/uptime not found"
        return 1 
    fi
    local uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
    
    if [[ -z "$uptime_seconds" ]]; then
        echo "Error: Could not read uptime"
        return 1 
    fi
    local days=$((uptime_seconds / 86400))
    local hours=$(((uptime_seconds % 86400) / 360))
    local minutes=$(((uptime_seconds % 3600) / 60))
    
    echo "${days}d ${hours}h ${minutes}m"
}

display_header(){
    clear
    echo -e "${bold}${bg_white}${black}=======================================================================${reset}"
    echo -e "${bold}${bg_white}                        ${black}SYSTEM INFORMATION DASHBOARD${reset}${bg_white}                   ${reset}"
    echo -e "${bold}${bg_white}${black}=======================================================================${reset}"
    echo 

    echo -e "${dim}${red}last updated: `date +"%Y-%m-%d %T"`${reset}"
    echo
}

:'
    the resources for system information 
    commands : hostname, uname, date
    file sys : /proc/uptime
' 

system_info() {
    echo -e "${bold}${cyan}---------------------- ${white}System Information${reset}${cyan} ----------------------------${reset}"
    echo
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Hostname" "$(hostname)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Current Username" "$(whoami)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Operating System" "$(uname -s)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Kernel Version" "$(uname -r)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Architecture" "$(uname -m)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Uptime" "$(get_uptime)"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Date" "$(date)"
    echo
}

:'
    the resources for cpu information 
    commands : top, nproc, uptime
    file sys : /proc/cpuinfo
' 

cpu_info(){
    echo -e "${bold}${cyan}---------------------- ${white}CPUs Information${reset}${cyan} ------------------------------${reset}"
    echo 
    local logical_core=$(grep "cpu cores" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')
    local physical_core=$(nproc)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    printf "${bold}${bg_magenta}%-20s${reset} : ${bg_red}%-47s${reset}\n" "CPU Model" "$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')"
    printf "${bold}${bg_magenta}%-20s${reset} : ${bg_red}%-47s${reset}\n" "CPU Cores" "$logical_core Logical, $physical_core Physical"
    printf "${bold}${bg_magenta}%-20s${reset} : ${bg_red}%-47s${reset}\n" "Frequency" "$(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' | cut -d'.' -f1) MHz"
    printf "${bold}${bg_magenta}%-20s${reset} : ${bg_red}%-47s${reset}\n" "CPU Usage" "$(progress_bar ${cpu_usage%.*})"
    printf "${bold}${bg_magenta}%-20s${reset} : ${bg_red}%-47s${reset}\n" "Load Average" "$load_avg"
    echo
}

:'
    the resources for mem information 
    commands : free
    file sys : /proc/meminfo
' 

mem_info(){
    echo -e "${bold}${cyan}---------------------- ${white}Memory Information${reset}${cyan} ----------------------------${reset}"
    echo 
    local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')        # Total physical memory
    local mem_free=$(grep MemFree /proc/meminfo | awk '{print $2}')          # Completely free memory
    local mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}') # Available for new processes
    local mem_used=$((mem_total - mem_available))
    local mem_usage_percent=$((mem_used * 100 / mem_total))

    mem_total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total / 1024 / 1024 }")
    mem_used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used / 1024 / 1024 }")
    mem_available_gb=$(awk "BEGIN {printf \"%.1f\", $mem_available / 1024 / 1024}")
    
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Total Memory" "$mem_total_gb GB"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Used Memory" "$mem_used_gb GB"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Available Memory" "$mem_available_gb GB"
    printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-46s ${reset}\n" "Memory usage" "$(progress_bar $mem_usage_percent)"
    
    local swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    local swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
    local swap_used=$((swap_total - swap_free))
    
    # Only show swap info if swap is configured
    if [ $swap_total -gt 0 ]; then
        local swap_usage_percent=$((swap_used * 100 / swap_total))
        
        # Convert swap to GB with decimal precision
        swap_total_gb=$(awk "BEGIN {printf \"%.1f\", $swap_total / 1024 / 1024}")
        swap_used_gb=$(awk "BEGIN {printf \"%.1f\", $swap_used / 1024 / 1024}")
        
        printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Swap Total" "$swap_total_gb GB"
        printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Swap Used" "$swap_used_gb GB"
        printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-46s ${reset}\n" "Swap Usage" "$(progress_bar $swap_usage_percent)"
    else
        printf "${bold}${bg_green}%-20s${reset} : ${bg_yellow}%-47s${reset}\n" "Swap" "Not configured"
    fi
    echo
}

:'
    the resource for disk information
    command : df 
    file system : 
'

disk_info(){
    echo -e "${bold}${cyan}---------------------- ${white}Disk Information${reset}${cyan} ------------------------------${reset}"
    echo 

    df -h | grep -E '^/dev/' | while read filesystem size used avail usage mount; do
        usage_percent=${usage%\%}
        bar_output=$(progress_bar $usage_percent)

        printf "${bold}${bg_cyan}%-30s${reset} : ${bg_white}${black}${blink}${italic}%-37s${reset}\n" "FileSystem" "${filesystem}"
        printf "${bold}${bg_cyan}%-30s${reset} : ${bg_white}${black}%-37s${reset}\n" "Size | Used | Available" "${size} | ${used} | ${avail}"
        printf "${bold}${bg_cyan}%-30s${reset} : ${bg_white}${black}%-37s${reset}\n" "Usage" "${bar_output}"
        echo
    done

    echo
}

display_footer() {
    echo -e "${red}Press ${green}Ctrl+C${red} to exit | Refreshes every 10 seconds${reset}"
    echo
}

main() {
    # Check if running as root (EUID = Effective User ID, 0 = root)
    if [ "$EUID" -eq 0 ]; then
        echo -e "${yellow}Running with root privileges${nc}"
    fi
    
    # Infinite loop to continuously update display
    while true; do
        display_header
        system_info
        cpu_info
        mem_info
        disk_info
        display_footer
        # Wait 10 seconds before next update
        sleep 10
    done
}

main # starts execution 
