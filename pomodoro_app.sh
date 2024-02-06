#!/bin/bash

# Check if Zenity and at are installed
if ! command -v zenity &> /dev/null || ! command -v at &> /dev/null; then
    echo "Zenity and at are required but not installed. Please install them and try again."
    exit 1
fi

# Initialize variables
music_file="/path/to/your/music/file.mp3"  # Replace with the path to your music file

# Function to remove all scheduled tasks
remove_tasks() {
    for job in $(atq | awk '{print $1}'); do
        atrm "$job"
    done
}

# Function to show a countdown timer
show_countdown() {
    local duration=$1
    local text=$2
    (
    for ((i=duration; i>0; i--)); do
        echo $((100*(duration-i)/duration))
        echo "# $text: $(printf "%02d:%02d" $((i/60)) $((i%60)))"
        sleep 1
    done
    echo 100
    ) | zenity --progress --auto-close
}

# Main loop
while true; do
    # Show main dialog
    action=$(zenity --list --title="Pomodoro Timer" --column="Actions" "Start" "Stop/Pause" "Reset" "Skip Break" "Exit")



    case $action in
        "Start")
            # Schedule tasks
            echo "play -q $music_file" | at now + 25 minutes
            show_countdown 1500 "Time remaining"
            ;;
        "Stop/Pause"|"Reset")
            # Remove all scheduled tasks
            remove_tasks
            ;;
        "Skip Break")
            # Remove all scheduled tasks and show the main dialog again
            remove_tasks
            zenity --info --text="Break skipped. Ready for another Pomodoro?"
            ;;
        "Exit")
            # Exit the application
            exit 0
            ;;
    esac

    # If a break was scheduled, show the break dialog
    if [[ $action == "Start" ]]; then
        zenity --info --text="Break time! Take a 5-minute break."
        echo "play -q $music_file" | at now + 5 minutes
        show_countdown 300 "Break time remaining"
    fi
done