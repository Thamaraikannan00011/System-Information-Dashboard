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
    
    # Calculate how many characters should be filled
    # Uses bash arithmetic: $((expression))
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
    # Check if /proc/uptime file exists (Linux-specific)
    # This file contains system uptime information
    if [[ ! -f /proc/uptime ]]; then
        echo "Error: /proc/uptime not found"
        return 1  # Return error code 1 if file doesn't exist
    fi
    
    # Extract uptime in seconds from /proc/uptime
    # /proc/uptime format: "12345.67 9876.54" (first field = system uptime in seconds)
    # awk '{print int($1)}' gets the first field and converts it to integer
    # 2>/dev/null suppresses any error messages from awk
    local uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null)
    
    # Verify that we successfully read the uptime value
    # -z checks if the variable is empty/null
    if [[ -z "$uptime_seconds" ]]; then
        echo "Error: Could not read uptime"
        return 1  # Return error code 1 if reading failed
    fi
    
    # Calculate days: total seconds divided by seconds in a day (86400)
    # 86400 = 24 hours * 60 minutes * 60 seconds
    local days=$((uptime_seconds / 86400))
    
    # Calculate hours: remaining seconds after removing days, divided by seconds in an hour (3600)
    # % 86400 gives the remainder after dividing by seconds per day
    # / 3600 converts remaining seconds to hours
    local hours=$(((uptime_seconds % 86400) / 3600))
    
    # Calculate minutes: remaining seconds after removing hours, divided by seconds in a minute (60)
    # % 3600 gives the remainder after dividing by seconds per hour
    # / 60 converts remaining seconds to minutes
    local minutes=$(((uptime_seconds % 3600) / 60))
    
    # Output the formatted uptime string
    # Example: "3d 12h 45m"
    echo "${days}d ${hours}h ${minutes}m"
}

display_header(){
    clear
    echo -e "${bold}${bg_white}${black}=======================================================================${reset}"
    echo -e "${bold}${bg_white}                        ${black}SYSTEM INFORMATION DASHBOARD${reset}${bg_white}                   ${reset}"
    echo -e "${bold}${bg_white}${black}=======================================================================${reset}"
    echo 

    echo -e "${dim}${red}${bg_white}last updated: `date +"%Y-%m-%d %T"`${reset}"
    echo
}

system_info() {
    echo -e "${bold}${cyan}${underline}------------------------- System Information -------------------------${reset}"
    echo
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Hostname" "$(hostname)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Current Username" "$(whoami)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Operating System" "$(uname -s)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Kernel Version" "$(uname -r)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Architecture" "$(uname -m)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Uptime" "$(get_uptime)"
    printf "${bold}${bg_green}%-20s${reset}: %s\n" "Date" "$(date)"
    echo
}

cpu_info(){
    echo -e "-------------------------- CPUs Information --------------------------"
    echo 
    local logical_core=$(grep "cpu cores" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')
    local physical_core=$(nproc)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    printf "${bold}${bg_magenta}%-20s${reset}: ${bg_black}${white}%-30s${reset}\n" "CPU Model" "$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')"
    printf "${bold}${bg_magenta}%-20s${reset}: ${bg_black}${white}%-30s${reset}\n" "CPU Cores" "$logical_core Logical, $physical_core Physical"
    printf "${bold}${bg_magenta}%-20s${reset}: ${bg_black}${white}%-30s${reset}\n" "Frequency" "$(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//' | cut -d'.' -f1) MHz"
    printf "${bold}${bg_magenta}%-20s${reset}: ${bg_black}${white}%-30s${reset}\n" "CPU Usage" "$(progress_bar ${cpu_usage%.*})"
    printf "${bold}${bg_magenta}%-20s${reset}: ${bg_black}${white}%-30s${reset}\n" "Load Average" "$load_avg"
    
}

main() {
    # Check if running as root (EUID = Effective User ID, 0 = root)
    if [ "$EUID" -eq 0 ]; then
        echo -e "${yellow}Running with root privileges${nc}"
    fi
    
    # Infinite loop to continuously update display
    while true; do
        # Call all display functions in order
        display_header          # Clear screen and show title
        system_info            # Show system information
        cpu_info
        # Wait 5 seconds before next update
        # This prevents excessive CPU usage from constant updates
        sleep 10
    done
}

main










