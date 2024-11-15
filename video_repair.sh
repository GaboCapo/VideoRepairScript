#!/bin/bash

echo "_  _ _ ___  ____ ____ ____ ____ ___  ____ _ ____ ____ ____ ____ _ ___  ___ "
echo "|  | | |  \ |___ |  | |__/ |___ |__] |__| | |__/ [__  |    |__/ | |__]  |  "
echo " \/  | |__/ |___ |__| |  \ |___ |    |  | | |  \ ___] |___ |  \ | |     |  "
        
echo "Welcome to the video file repair script."
echo "This script checks video files for errors and attempts to repair them."
echo "It will test files using the command 'ffmpeg -v error -i VID_reencoded.mp4 -f null -'. If no error is found, the file is considered repaired."
echo "The script will try several repair methods until the file is fixed or all options are exhausted."

# Dependencies
echo "Checking dependencies..."
command -v ffmpeg > /dev/null 2>&1 || { echo "ffmpeg is not installed. Please install ffmpeg before running this script."; exit 1; }

# Question about directory option
echo "Do you want to process only files in the current directory or also files in subdirectories?"
echo "1 = Only files in the current directory"
echo "2 = Files in subdirectories too"
read -p "Please select an option (1 or 2): " directory_option

# Question about creating a log file
echo "Do you want to create a log file?"
echo "1 = Yes"
echo "2 = No"
read -p "Please select an option (1 or 2): " create_log

# Set log file
if [ "$create_log" -eq 1 ]; then
    log_file="repair_log_$(date +%Y%m%d%H%M%S).txt"
    echo "Creating log file: $log_file"
    touch "$log_file"
fi

# Question about deleting damaged files
echo "Should the original corrupted files be deleted after repair?"
echo "1 = Yes"
echo "2 = No"
read -p "Please select an option (1 or 2): " delete_original

# Directory search (depending on choice)
if [ "$directory_option" -eq 1 ]; then
    files=$(find . -maxdepth 1 -type f -iname "*.mp4")
elif [ "$directory_option" -eq 2 ]; then
    files=$(find . -type f -iname "*.mp4")
else
    echo "Invalid option selected, exiting script."
    exit 1
fi

# Repair functions
repair_file() {
    input_file="$1"
    filename=$(basename "$input_file" .mp4)
    repaired_file="${filename}_repaired.mp4"
    repaired=false
    repair_modes=("ffmpeg -y -err_detect ignore_err -i $input_file -c:v copy -c:a copy $repaired_file"
                  "ffmpeg -y -i $input_file -c:v libx264 -c:a aac $repaired_file"
                  "ffmpeg -y -err_detect ignore_err -i $input_file -c:v copy -c:a copy $repaired_file"
                  "ffmpeg -y -i $input_file -c:v copy -c:a aac -b:a 192k $repaired_file"
                  "ffmpeg -y -fflags +genpts -i $input_file -c:v copy -c:a copy $repaired_file")

    # Test for errors
    test_file_error() {
        ffmpeg -v error -i "$1" -f null - 2>&1 | grep -i "error"
    }

    # If no faults, no repair necessary
    if ! test_file_error "$input_file"; then
        echo "File '$input_file' is already error-free."
        if [ "$create_log" -eq 1 ]; then
            echo "$(date) - $input_file - No repair needed" >> "$log_file"
        fi
        return
    fi

    # Attempts to repair using various methods
    for mode in "${repair_modes[@]}"; do
        echo "Attempting repair with mode: $mode"
        eval $mode

        # Test auf Fehler nach Reparatur
        if ! test_file_error "$repaired_file"; then
            echo "File '$input_file' repaired successfully using '$mode'."
            repaired=true
            if [ "$create_log" -eq 1 ]; then
                echo "$(date) - $repaired_file - Repaired with mode: $mode" >> "$log_file"
            fi
            break
        else
            echo "Repair attempt with '$mode' failed."
            if [ "$create_log" -eq 1 ]; then
                echo "$(date) - $input_file - Repair failed with mode: $mode" >> "$log_file"
            fi
        fi
    done

    # If repaired, delete file (optional)
    if [ "$repaired" = true ]; then
        if [ "$delete_original" -eq 1 ]; then
            rm "$input_file"
            echo "Deleted original corrupted file: $input_file"
            if [ "$create_log" -eq 1 ]; then
                echo "$(date) - $input_file - Original file deleted" >> "$log_file"
            fi
        fi
    else
        echo "File '$input_file' could not be repaired."
        if [ "$create_log" -eq 1 ]; then
            echo "$(date) - $input_file - Could not be repaired. Tried modes: ${repair_modes[@]}" >> "$log_file"
        fi
    fi
}

# If repaired, delete file (optional)
for file in $files; do
    repair_file "$file"
done

echo "Script execution completed."
