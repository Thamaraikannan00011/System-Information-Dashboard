#!/bin/bash

# Script metadata
readonly SCRIPT_NAME="user_info.sh"
readonly VERSION="1.0"
readonly AUTHOR="Bash Learner"

# Function to display script header
display_header() {
    echo "======================================"
    printf "%-20s %s\n" "Script:" "$SCRIPT_NAME"
    printf "%-20s %s\n" "Version:" "$VERSION"
    printf "%-20s %s\n" "Author:" "$AUTHOR"
    echo "======================================"
}

# Function to collect user information
collect_user_info() {
    # Get user's name
    read -p "Enter your full name: " full_name
    
    # Get user's age
    read -p "Enter your age: " age
    
    # Get user's favorite color
    read -p "Enter your favorite color: " color
    
    # Confirm information
    echo
    echo "Please confirm your information:"
    printf "Name: %s\n" "$full_name"
    printf "Age: %d\n" "$age"
    printf "Favorite Color: %s\n" "$color"
    echo
    
    read -p "Is this correct? (y/n): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo -e "\033[32mInformation saved successfully!\033[0m"
    else
        echo -e "\033[31mInformation not saved.\033[0m"
    fi
}

# Main function
main() {
    display_header
    collect_user_info
    
    # Display current system info
    echo
    echo "System Information:"
    echo "Current user: $(whoami)"
    echo "Current directory: $(pwd)"
    echo "Current date: $(date)"
}

# Execute main function with all arguments
main "$@"
