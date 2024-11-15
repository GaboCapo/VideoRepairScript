![ChatGPT](https://img.shields.io/badge/chatGPT-74aa9c?style=for-the-badge&logo=openai&logoColor=white)
![Markdown](https://img.shields.io/badge/markdown-%23000000.svg?style=for-the-badge&logo=markdown&logoColor=white)

# Video Repair Script

This project provides a Bash script for scanning and repairing video files in a folder. It attempts to fix corrupted video files by applying various FFmpeg-based repair modes until the file is confirmed error-free. The script is useful for fixing files that may have been corrupted during encoding or transfer. ⚠️ **Please test this script thoroughly before using it in production, as it may alter files permanently.** ⚠️ 

## Features
- **🤹 Multi-mode Repair**: The script tries up to five different repair modes to correct errors in video files.
- **⚙️ Customizable Options**: Users can choose to process files in the current folder or include subdirectories.
- **👀 Logging**: Creates a log file with details about each file’s repair status.
- **🗑️ Original File Management**: Option to delete the original file after a successful repair.

## Prerequisites
- **FFmpeg**: The script requires FFmpeg to be installed on your system. You can install it on Ubuntu using:

Ubuntu,Debian based Systems
  ```
  sudo apt-get install ffmpeg
  ```

  Fedora,RHEL :
  
  ```
  sudo dnf install ffmpeg
  ```

## Usage
1. Clone or download this repository and navigate to the folder containing the corrupted video files.
2. Place the `video_repair.sh` script in the target folder.
3. Run the script by executing:
   `bash
   ./video_repair.sh
   `
4. The script will prompt for options to specify processing folders, logging, and whether to delete original files.

## Options
- **Process scope**: Choose between processing only files in the current directory or including all subdirectories.
- **Logging**: Enable or disable logging of repair actions. Logs include timestamp, filename, repair mode used, and status.
- **Original File Deletion**: After successful repair, the script can delete the original corrupted file if this option is enabled.

## Repair Modes
The script will attempt the following repair modes sequentially:
1. `ffmpeg -err_detect ignore_err -i VID.mp4 -c:v copy -c:a copy VID_neu.mp4`
2. `ffmpeg -i VID.mp4 -c:v libx264 -c:a aac VID_reencoded.mp4`
3. `ffmpeg -err_detect ignore_err -i VID.mp4 -c:v copy -c:a copy VID_repaired.mp4`
4. `ffmpeg -i VID.mp4 -c:v copy -c:a aac -b:a 192k VID_audiofixed.mp4`
5. `ffmpeg -fflags genpts -i VID.mp4 -c:v copy -c:a copy VID_fixed.mp4`



## FAQ

### 1. **What does this script do?**
This script checks video files for errors and attempts to repair them using multiple `ffmpeg` methods. It tests the files using the command `ffmpeg -v error -i VID_reencoded.mp4 -f null -` to check for errors, and if no errors are found, the file is considered repaired.

### 2. **What happens if the file is already error-free?**
If the script detects that the file is already error-free (no errors found by the `ffmpeg` test), it will not attempt any repairs and will log that the file was already in good condition.

### 3. **What repair methods are used?**
The script tries several `ffmpeg` repair methods, including:
   - Copying the video and audio streams without modification.
   - Re-encoding the video with `libx264` and audio with `aac`.
   - Adding additional flags like `+genpts` to regenerate timestamps.

### 4. **Can I choose whether to delete the original corrupted file after repair?**
Yes, the script will ask if you want to delete the original corrupted files after they have been successfully repaired. You can choose not to delete them if preferred.

### 5. **What if the file cannot be repaired?**
If the file cannot be repaired after trying all the available methods, the script will log the failure and list the methods that were attempted. It will not delete the original file in this case.

### 6. **Can this script process files in subdirectories?**
Yes, the script can process files in subdirectories if you select that option. It allows you to scan and repair videos in the current directory or include all subdirectories.

### 7. **Does the script generate a log file?**
Yes, the script can generate a log file where all actions, including successful repairs and failures, are logged with timestamps. You can choose whether you want the log file to be created when running the script.

### 8. Supported File Formats

This script uses **`ffmpeg`** to repair video files. **`ffmpeg`** supports a wide range of video and audio formats, including:

- **MP4** (.mp4)
- **AVI** (.avi)
- **MOV** (.mov)
- **MKV** (.mkv)
- **FLV** (.flv)
- **WMV** (.wmv)
- **WebM** (.webm)
- **MPG** (.mpg, .mpeg)
- **3GP** (.3gp)
- **OGG** (.ogg)
- **FLAC** (.flac) and many more.

The script has been **primarily tested with .mp4 files**. While it should work with other formats supported by **`ffmpeg`**, the repair methods and results have been specifically verified with **MP4 files**.

If you are using other formats and encounter issues or have feedback, I would appreciate any information on whether the script works with those formats as well.

---


**⚠️ Disclaimer ⚠️**: Use this script at your own risk. Be sure to create backups of your files before attempting repairs, as the process may irreversibly modify or delete files.
