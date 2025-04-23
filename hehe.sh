#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies and guide installation if missing
check_dependencies() {
  local missing_deps=()
  
  # Check for yt-dlp
  if ! command_exists yt-dlp; then
    missing_deps+=("yt-dlp")
  fi
  
  # Check for ffmpeg
  if ! command_exists ffmpeg; then
    missing_deps+=("ffmpeg")
  fi
  
  # Check for python3
  if ! command_exists python3; then
    missing_deps+=("python3")
  fi
  
  # If any dependencies are missing, show installation instructions
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "==== Missing Dependencies ===="
    echo "The following required programs are not installed:"
    for dep in "${missing_deps[@]}"; do
      echo "- $dep"
    done
    
    echo ""
    echo "Please install the missing dependencies using your system's package manager:"
    
    # Detect OS and provide appropriate installation instructions
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS instructions
      echo ""
      echo "=== macOS Installation Instructions ==="
      echo "1. Install Homebrew (if not already installed):"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      echo ""
      echo "2. Then install the missing dependencies:"
      if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
        echo "   brew install yt-dlp"
      fi
      if [[ " ${missing_deps[*]} " =~ " ffmpeg " ]]; then
        echo "   brew install ffmpeg"
      fi
      if [[ " ${missing_deps[*]} " =~ " python3 " ]]; then
        echo "   brew install python"
      fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
      # Windows instructions
      echo ""
      echo "=== Windows Installation Instructions ==="
      echo "1. Install Chocolatey (if not already installed):"
      echo "   Run PowerShell as Administrator and execute:"
      echo "   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
      echo ""
      echo "2. Then install the missing dependencies (in PowerShell as Administrator):"
      if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
        echo "   choco install yt-dlp"
      fi
      if [[ " ${missing_deps[*]} " =~ " ffmpeg " ]]; then
        echo "   choco install ffmpeg"
      fi
      if [[ " ${missing_deps[*]} " =~ " python3 " ]]; then
        echo "   choco install python"
      fi
      echo ""
      echo "Alternatively, you can download and install these programs manually:"
      echo "- yt-dlp: https://github.com/yt-dlp/yt-dlp/releases"
      echo "- ffmpeg: https://ffmpeg.org/download.html"
      echo "- Python: https://www.python.org/downloads/"
    else
      # Linux instructions
      echo ""
      echo "=== Linux Installation Instructions ==="
      echo "For Debian/Ubuntu-based systems:"
      if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
        echo "   sudo apt update && sudo apt install python3-pip"
        echo "   sudo pip3 install yt-dlp"
      fi
      if [[ " ${missing_deps[*]} " =~ " ffmpeg " ]]; then
        echo "   sudo apt update && sudo apt install ffmpeg"
      fi
      if [[ " ${missing_deps[*]} " =~ " python3 " ]]; then
        echo "   sudo apt update && sudo apt install python3"
      fi
      
      echo ""
      echo "For Fedora/RHEL-based systems:"
      if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
        echo "   sudo dnf install python3-pip"
        echo "   sudo pip3 install yt-dlp"
      fi
      if [[ " ${missing_deps[*]} " =~ " ffmpeg " ]]; then
        echo "   sudo dnf install ffmpeg"
      fi
      if [[ " ${missing_deps[*]} " =~ " python3 " ]]; then
        echo "   sudo dnf install python3"
      fi
      
      echo ""
      echo "For Arch-based systems:"
      if [[ " ${missing_deps[*]} " =~ " yt-dlp " ]]; then
        echo "   sudo pacman -S yt-dlp"
      fi
      if [[ " ${missing_deps[*]} " =~ " ffmpeg " ]]; then
        echo "   sudo pacman -S ffmpeg"
      fi
      if [[ " ${missing_deps[*]} " =~ " python3 " ]]; then
        echo "   sudo pacman -S python"
      fi
    fi
    
    echo ""
    echo "Please install the missing dependencies and run this script again."
    exit 1
  fi
}

# Function to check if subtitle_cleaner.py exists
check_subtitle_cleaner() {
  if [ ! -f "subtitle_cleaner.py" ]; then
    echo "Error: subtitle_cleaner.py not found in the current directory"
    exit 1
  fi
}

# Function to get user input with validation and navigation options
get_input() {
  local prompt="$1"
  local valid_range="$2"
  local step_name="$3"
  local add_navigation="${4:-true}"
  
  while true; do
    echo "$prompt"
    
    # Add quit option to all menus
    echo "q) Quit"
    
    # Add navigation options if requested (except for first step)
    if [ "$add_navigation" = "true" ] && [ "$step_name" != "download_type" ]; then
      echo "b) Go back to previous step"
      echo "r) Restart from beginning"
    fi
    
    echo -n "Your choice: "
    read USER_INPUT
    
    # Check for quit command (available in all menus)
    if [ "$USER_INPUT" = "q" ] || [ "$USER_INPUT" = "Q" ]; then
      echo "Exiting script. Goodbye!"
      exit 0
    fi
    
    # Check for navigation commands
    if [ "$add_navigation" = "true" ] && [ "$step_name" != "download_type" ]; then
      if [ "$USER_INPUT" = "b" ] || [ "$USER_INPUT" = "B" ]; then
        return 255  # Special code for "go back"
      elif [ "$USER_INPUT" = "r" ] || [ "$USER_INPUT" = "R" ]; then
        echo "Restarting script from beginning..."
        exec "$0"  # Restart the script
        exit 0
      fi
    fi
    
    # For text input (empty valid_range)
    if [ -z "$valid_range" ]; then
      if [ -n "$USER_INPUT" ]; then
        return 0
      else
        echo "Error: Input cannot be empty. Please try again."
      fi
    # For numeric input with range validation
    elif [[ "$USER_INPUT" =~ ^[0-9]+$ ]] && \
         [ "$USER_INPUT" -ge "${valid_range%-*}" ] && \
         [ "$USER_INPUT" -le "${valid_range#*-}" ]; then
      return 0
    else
      echo "Error: Please enter a number between ${valid_range%-*} and ${valid_range#*-}, or use navigation options."
    fi
  done
}

# Main function to control the download type selection
get_download_type() {
  while true; do
    if get_input "What would you like to download?
1. Single video
2. Playlist" "1-2" "download_type"; then
      DOWNLOAD_TYPE=$USER_INPUT
      return 0
    fi
  done
}

# Function to validate YouTube URL
validate_youtube_url() {
  local url="$1"
  local expected_type="$2"  # "video" or "playlist"
  
  # First check if it's a YouTube URL at all
  if [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be) ]]; then
    echo "Error: This doesn't appear to be a valid YouTube URL."
    return 1
  fi
  
  # Check if it's a playlist URL when expecting a video
  if [ "$expected_type" = "video" ]; then
    if [[ "$url" == *"list="* ]]; then
      echo "Error: This appears to be a playlist URL, but you selected 'Single video'."
      echo "Tip: If you want to download just one video from a playlist, remove the 'list=' part from the URL."
      return 1
    fi
    
    # Check for common video URL patterns
    if [[ "$url" == *"youtube.com/watch"* ]] || [[ "$url" == *"youtu.be/"* ]]; then
      return 0
    else
      echo "Error: This doesn't appear to be a standard YouTube video URL."
      echo "Valid formats are: youtube.com/watch?v=VIDEO_ID or youtu.be/VIDEO_ID"
      return 1
    fi
  fi
  
  # Check if it's a video URL when expecting a playlist
  if [ "$expected_type" = "playlist" ]; then
    if [[ ! "$url" == *"list="* ]]; then
      echo "Error: This appears to be a single video URL, but you selected 'Playlist'."
      echo "For playlists, the URL should contain 'list=' followed by the playlist ID."
      return 1
    fi
    
    # Good enough validation for playlist
    return 0
  fi
  
  # Default fallback (shouldn't reach here)
  return 0
}

# Function to get URL based on download type
get_url() {
  local type="$1"
  
  while true; do
    if [ "$type" = "1" ]; then
      prompt="Enter YouTube video URL:"
      expected_type="video"
    else
      prompt="Enter YouTube playlist URL:"
      expected_type="playlist"
    fi
    
    # Change "false" to "true" to enable navigation options
    if get_input "$prompt" "" "url" "true"; then
      URL=$USER_INPUT
      
      # Validate URL for the selected content type
      if validate_youtube_url "$URL" "$expected_type"; then
        return 0
      else
        # Error message is displayed by the validation function
        continue
      fi
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get playlist items if applicable
get_playlist_items() {
  while true; do
    if get_input "Select download option:
1. Download entire playlist
2. Download part of playlist" "1-2" "playlist_option"; then
      PLAYLIST_OPTION=$USER_INPUT
      
      if [ "$PLAYLIST_OPTION" = "1" ]; then
        PLAYLIST_ITEMS=""
        echo "Selected: Download entire playlist"
        return 0
      elif [ "$PLAYLIST_OPTION" = "2" ]; then
        # Get start video
        while true; do
          if get_input "Enter start video number:" "" "start_video" "false"; then
            START_VIDEO=$USER_INPUT
            if ! [[ "$START_VIDEO" =~ ^[0-9]+$ ]]; then
              echo "Error: Please enter a valid number."
              continue
            fi
            break
          fi
        done
        
        # Get end video
        while true; do
          if get_input "Enter end video number:" "" "end_video" "false"; then
            END_VIDEO=$USER_INPUT
            if ! [[ "$END_VIDEO" =~ ^[0-9]+$ ]]; then
              echo "Error: Please enter a valid number."
              continue
            fi
            
            if [ "$START_VIDEO" -gt "$END_VIDEO" ]; then
              echo "Error: Start video cannot be greater than end video."
              continue
            fi
            break
          fi
        done
        
        PLAYLIST_ITEMS="$START_VIDEO-$END_VIDEO"
        echo "Selected: Download videos $START_VIDEO through $END_VIDEO"
        return 0
      fi
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get content type
get_content_type() {
  while true; do
    if get_input "What type of content would you like to download?
1. Video only (no audio)
2. Audio only (no video)
3. Video & audio (default)" "1-3" "content_type"; then
      CONTENT_TYPE=$USER_INPUT
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get video quality
get_video_quality() {
  while true; do
    if get_input "Select video quality:
1. Best available quality
2. 1080p (Full HD)
3. 720p (HD)
4. 480p (SD)
5. 360p (Low)
6. 240p (Very Low)
7. Lowest available quality" "1-7" "video_quality"; then
      case $USER_INPUT in
        1) VIDEO_QUALITY="bestvideo" ;;
        2) VIDEO_QUALITY="bestvideo[height<=1080]" ;;
        3) VIDEO_QUALITY="bestvideo[height<=720]" ;;
        4) VIDEO_QUALITY="bestvideo[height<=480]" ;;
        5) VIDEO_QUALITY="bestvideo[height<=360]" ;;
        6) VIDEO_QUALITY="bestvideo[height<=240]" ;;
        7) VIDEO_QUALITY="worstvideo" ;;
      esac
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get audio quality for video downloads
get_audio_quality() {
  while true; do
    if get_input "Select audio quality for your video:
1. Best available audio
2. Medium quality audio
3. Lowest quality audio" "1-3" "audio_quality"; then
      case $USER_INPUT in
        1) AUDIO_QUALITY="bestaudio" ;;
        2) AUDIO_QUALITY="bestaudio[abr>=128]" ;;
        3) AUDIO_QUALITY="worstaudio" ;;
      esac
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get audio format
get_audio_format() {
  while true; do
    if get_input "Choose output format for audio:
1. mp3 (most compatible)
2. m4a (better quality for same size)
3. opus (best quality/size ratio)
4. aac (good compatibility)
5. flac (lossless, larger size)
6. wav (lossless, largest size)" "1-6" "audio_format"; then
      case $USER_INPUT in
        1) AUDIO_FORMAT="mp3" ;;
        2) AUDIO_FORMAT="m4a" ;;
        3) AUDIO_FORMAT="opus" ;;
        4) AUDIO_FORMAT="aac" ;;
        5) AUDIO_FORMAT="flac" ;;
        6) AUDIO_FORMAT="wav" ;;
      esac
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get subtitles preference
get_subtitles_preference() {
  while true; do
    if get_input "Would you like to download and embed subtitles?
Note: If you choose subtitles, the output format will be .mkv
1. Yes, include subtitles
2. No, skip subtitles" "1-2" "subtitles"; then
      if [ "$USER_INPUT" = "1" ]; then
        USE_SUBTITLES="true"
        OUTPUT_EXT="mkv"
      else
        USE_SUBTITLES="false"
        get_video_format
      fi
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to get video format when not using subtitles
get_video_format() {
  while true; do
    if get_input "Choose output format for video:
1. mp4 (most compatible)
2. webm (better quality for same size)
3. mkv (best container, supports more codecs)" "1-3" "video_format"; then
      case $USER_INPUT in
        1) VIDEO_FORMAT="mp4" ;;
        2) VIDEO_FORMAT="webm" ;;
        3) VIDEO_FORMAT="mkv" ;;
      esac
      OUTPUT_EXT="$VIDEO_FORMAT"
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back to subtitles preference
    fi
  done
}

# Function to get download location
get_download_location() {
  local menu_options="Where would you like to save the downloaded content?
1. Current directory (no new folder)
2. New folder in current directory
3. Existing folder in current directory
4. Custom path location"

  # Add playlist option if this is a playlist
  if [ "$IS_PLAYLIST" = true ]; then
    menu_options="$menu_options
5. Use playlist name as folder (in current directory)"
    valid_range="1-5"
  else
    valid_range="1-4"
  fi

  while true; do
    if get_input "$menu_options" "$valid_range" "location"; then
      LOCATION_CHOICE=$USER_INPUT
      
      case $LOCATION_CHOICE in
        1) # Current directory
          echo "Saving to current directory"
          if [ "$IS_PLAYLIST" = true ]; then
            OUTPUT_FORMAT="%(playlist_index)s-%(title)s"
          else
            OUTPUT_FORMAT="%(title)s"
          fi
          FOLDER="./"
          ;;
          
        2) # New folder in current directory
          while true; do
            # Change "false" to "true" to enable navigation options
            if get_input "Enter name for new folder:" "" "folder_name" "true"; then
              FOLDER_NAME=$USER_INPUT
              if [ -z "$FOLDER_NAME" ]; then
                echo "No folder name provided. Using 'downloads'"
                FOLDER_NAME="downloads"
              fi
              break
            elif [ $? -eq 255 ]; then
              return 255  # Go back to location options
            fi
          done
          
          echo "Saving to new folder: $FOLDER_NAME"
          mkdir -p "$FOLDER_NAME"
          if [ "$IS_PLAYLIST" = true ]; then
            OUTPUT_FORMAT="$FOLDER_NAME/%(playlist_index)s-%(title)s"
          else
            OUTPUT_FORMAT="$FOLDER_NAME/%(title)s"
          fi
          FOLDER="$FOLDER_NAME/"
          ;;
          
        3) # Existing folder in current directory
          echo "Available folders in current directory:"
          # List all directories, excluding hidden ones
          ls -d */ 2>/dev/null | grep -v "^\." | nl -w2 -s") "
          
          while true; do
            if get_input "Choose folder number (or enter folder name directly):" "" "folder_choice" "false"; then
              FOLDER_CHOICE=$USER_INPUT
              break
            fi
          done
          
          # Check if input is a number
          if [[ "$FOLDER_CHOICE" =~ ^[0-9]+$ ]]; then
            # Get folder by number
            FOLDER_NAME=$(ls -d */ 2>/dev/null | grep -v "^\." | sed -n "${FOLDER_CHOICE}p" | sed 's/\/$//')
            if [ -z "$FOLDER_NAME" ]; then
              echo "Invalid selection. Using current directory."
              FOLDER_NAME="."
              FOLDER="./"
            else
              FOLDER="$FOLDER_NAME/"
            fi
          else
            # Direct folder name input
            FOLDER_NAME="$FOLDER_CHOICE"
            # Remove trailing slash if present
            FOLDER_NAME=${FOLDER_NAME%/}
            
            # Check if folder exists
            if [ ! -d "$FOLDER_NAME" ]; then
              echo "Folder doesn't exist. Creating it."
              mkdir -p "$FOLDER_NAME"
            fi
            FOLDER="$FOLDER_NAME/"
          fi
          
          echo "Saving to: $FOLDER"
          if [ "$IS_PLAYLIST" = true ]; then
            OUTPUT_FORMAT="$FOLDER_NAME/%(playlist_index)s-%(title)s"
          else
            OUTPUT_FORMAT="$FOLDER_NAME/%(title)s"
          fi
          ;;
          
        4) # Custom path
          # Detect OS for path format instructions
          if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            path_example="Example for macOS: /Users/username/Downloads/"
          elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
            # Windows
            path_example="Example for Windows: C:/Users/username/Downloads/ or C:\\Users\\username\\Downloads\\"
          else
            # Linux or other
            path_example="Example for Linux: /home/username/Downloads/"
          fi
          
          while true; do
            # Change "false" to "true" to enable navigation options
            if get_input "Enter full path ($path_example):" "" "custom_path" "true"; then
              CUSTOM_PATH=$USER_INPUT
              break
            elif [ $? -eq 255 ]; then
              return 255  # Go back to location options
            fi
          done
          
          # Remove trailing slash if present
          CUSTOM_PATH=${CUSTOM_PATH%/}
          
          # Replace backslashes with forward slashes (for Windows compatibility)
          CUSTOM_PATH=${CUSTOM_PATH//\\//}
          
          # Check if path exists
          if [ ! -d "$CUSTOM_PATH" ]; then
            echo "Path doesn't exist. Creating it."
            mkdir -p "$CUSTOM_PATH"
          fi
          
          echo "Saving to: $CUSTOM_PATH"
          if [ "$IS_PLAYLIST" = true ]; then
            OUTPUT_FORMAT="$CUSTOM_PATH/%(playlist_index)s-%(title)s"
          else
            OUTPUT_FORMAT="$CUSTOM_PATH/%(title)s"
          fi
          FOLDER="$CUSTOM_PATH/"
          ;;
          
        5) # Use playlist name (only for playlists)
          if [ "$IS_PLAYLIST" = true ]; then
            echo "Using playlist name as folder"
            OUTPUT_FORMAT="%(playlist_title)s/%(playlist_index)s-%(title)s"
            # Folder will be determined after download
            FOLDER=""
          else
            echo "Invalid choice for single video. Using current directory."
            OUTPUT_FORMAT="%(title)s"
            FOLDER="./"
          fi
          ;;
      esac
      
      return 0
    elif [ $? -eq 255 ]; then
      return 255  # Go back
    fi
  done
}

# Function to process subtitles
process_subtitles() {
  echo "===== Processing videos and embedding clean subtitles ====="
  
  # Process downloaded videos
  for VIDEO in "${FOLDER}"*.${OUTPUT_EXT}; do
    # Skip if no matches found
    [ -e "$VIDEO" ] || continue
    
    echo "Processing $VIDEO"
    
    # Get the base name without extension
    BASENAME="${VIDEO%.${OUTPUT_EXT}}"
    
    # Check if corresponding subtitle exists
    if [ -f "${BASENAME}.en.srt" ]; then
      echo "  Found subtitle: ${BASENAME}.en.srt"
      
      # Clean subtitles using the existing script
      echo "  Cleaning subtitles..."
      python3 subtitle_cleaner.py "${BASENAME}.en.srt" "${BASENAME}.clean.srt"
      
      # Create temporary filename for the output
      TEMP_OUTPUT="${BASENAME}.temp.mkv"
      
      # Embed clean subtitles
      echo "  Embedding subtitles..."
      ffmpeg -i "$VIDEO" -i "${BASENAME}.clean.srt" -c:v copy -c:a copy -c:s srt "$TEMP_OUTPUT" -loglevel warning
      
      # If successful, replace original with the new version
      if [ $? -eq 0 ]; then
        mv "$TEMP_OUTPUT" "$VIDEO"
        echo "  ✓ Successfully processed: $VIDEO"
        
        # Clean up subtitle files
        rm "${BASENAME}.en.srt" "${BASENAME}.clean.srt"
        echo "  ✓ Removed temporary subtitle files"
      else
        echo "  ✗ Failed to embed subtitles for $VIDEO"
        # Keep the clean subtitle file for manual processing
        echo "  Clean subtitle file saved as ${BASENAME}.clean.srt"
      fi
    else
      echo "  ✗ No subtitle found for $VIDEO"
    fi
    
    echo ""
  done
  
  # Clean up any remaining .srt files
  find "$FOLDER" -name "*.srt" -type f -delete
}

# Main script starts here

# Check for dependencies first
check_dependencies

# Check for subtitle_cleaner.py
check_subtitle_cleaner

# Print welcome message
echo "====== YouTube Downloader Script ======"
echo "This script helps you download videos or playlists from YouTube"
echo "with options for quality, format, and subtitles."
echo ""

# Step 1: Get download type
get_download_type
if [ "$DOWNLOAD_TYPE" = "1" ]; then
  IS_PLAYLIST=false
elif [ "$DOWNLOAD_TYPE" = "2" ]; then
  IS_PLAYLIST=true
fi

# Step 2: Get URL
get_url "$DOWNLOAD_TYPE"

# Step 3: Get playlist items if applicable
if [ "$IS_PLAYLIST" = true ]; then
  if ! get_playlist_items; then
    # Go back to Step 2
    get_url "$DOWNLOAD_TYPE"
    get_playlist_items
  fi
fi

# Step 4: Get content type
if ! get_content_type; then
  # Go back to Step 3 or 2
  if [ "$IS_PLAYLIST" = true ]; then
    get_playlist_items
  else
    get_url "$DOWNLOAD_TYPE"
  fi
  get_content_type
fi

# Step 5: Setup based on content type
if [ "$CONTENT_TYPE" = "2" ]; then
  # Audio only
  if ! get_audio_format; then
    get_content_type
    get_audio_format
  fi
  
  # Audio-only variables
  USE_SUBTITLES="false"
  
elif [ "$CONTENT_TYPE" = "1" ]; then
  # Video only (no audio)
  if ! get_video_quality; then
    get_content_type
    get_video_quality
  fi
  
  # Video only variables
  NO_AUDIO="--no-audio"
  
  # Get subtitles preference
  if ! get_subtitles_preference; then
    get_video_quality
    get_subtitles_preference
  fi
  
else
  # Video & Audio
  if ! get_video_quality; then
    get_content_type
    get_video_quality
  fi
  
  if ! get_audio_quality; then
    get_video_quality
    get_audio_quality
  fi
  
  # Combined format string
  FORMAT_STRING="$VIDEO_QUALITY+$AUDIO_QUALITY/best"
  
  # Get subtitles preference
  if ! get_subtitles_preference; then
    get_audio_quality
    get_subtitles_preference
  fi
fi

# Step 6: Get download location
if ! get_download_location; then
  # Go back to previous options
  if [ "$CONTENT_TYPE" = "2" ]; then
    get_audio_format
  else
    get_subtitles_preference
  fi
  get_download_location
fi

# Step 7: Download content
echo "===== Downloading content ====="

# Construct the download command based on content type
if [ "$CONTENT_TYPE" = "2" ]; then
  # === AUDIO ONLY ===
  # Use -x and --audio-format for audio-only downloads
  if [ "$IS_PLAYLIST" = true ]; then
    if [ -z "$PLAYLIST_ITEMS" ]; then
      DOWNLOAD_CMD="yt-dlp -f 'bestaudio' -x --audio-format $AUDIO_FORMAT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
    else
      DOWNLOAD_CMD="yt-dlp -f 'bestaudio' -x --audio-format $AUDIO_FORMAT -o \"${OUTPUT_FORMAT}.%(ext)s\" --playlist-items $PLAYLIST_ITEMS \"$URL\""
    fi
  else
    DOWNLOAD_CMD="yt-dlp -f 'bestaudio' -x --audio-format $AUDIO_FORMAT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
  fi
  
elif [ "$CONTENT_TYPE" = "1" ]; then
  # === VIDEO ONLY (NO AUDIO) ===
  # Use --no-audio flag and merge-output-format
  if [ "$IS_PLAYLIST" = true ]; then
    if [ -z "$PLAYLIST_ITEMS" ]; then
      DOWNLOAD_CMD="yt-dlp -f \"$VIDEO_QUALITY\" $NO_AUDIO --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
    else
      DOWNLOAD_CMD="yt-dlp -f \"$VIDEO_QUALITY\" $NO_AUDIO --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" --playlist-items $PLAYLIST_ITEMS \"$URL\""
    fi
  else
    DOWNLOAD_CMD="yt-dlp -f \"$VIDEO_QUALITY\" $NO_AUDIO --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
  fi
  
else
  # === VIDEO & AUDIO ===
  # Use format string with both video and audio, with merge-output-format
  if [ "$IS_PLAYLIST" = true ]; then
    if [ -z "$PLAYLIST_ITEMS" ]; then
      DOWNLOAD_CMD="yt-dlp -f \"$FORMAT_STRING\" --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
    else
      DOWNLOAD_CMD="yt-dlp -f \"$FORMAT_STRING\" --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" --playlist-items $PLAYLIST_ITEMS \"$URL\""
    fi
  else
    DOWNLOAD_CMD="yt-dlp -f \"$FORMAT_STRING\" --merge-output-format $OUTPUT_EXT -o \"${OUTPUT_FORMAT}.%(ext)s\" \"$URL\""
  fi
fi

echo "Executing: $DOWNLOAD_CMD"
eval $DOWNLOAD_CMD

# Step 8: Download subtitles if requested
if [ "$USE_SUBTITLES" = "true" ]; then
  echo "===== Downloading subtitles ====="
  if [ "$IS_PLAYLIST" = true ]; then
    if [ -z "$PLAYLIST_ITEMS" ]; then
      yt-dlp --skip-download --write-auto-sub --sub-lang en --convert-subs srt -o "$OUTPUT_FORMAT" "$URL"
    else
      yt-dlp --skip-download --write-auto-sub --sub-lang en --convert-subs srt -o "$OUTPUT_FORMAT" --playlist-items "$PLAYLIST_ITEMS" "$URL"
    fi
  else
    yt-dlp --skip-download --write-auto-sub --sub-lang en --convert-subs srt -o "$OUTPUT_FORMAT" "$URL"
  fi
fi

# If folder is empty, it means we used playlist name and need to find it
if [ -z "$FOLDER" ]; then
  # Get the folder name created by yt-dlp (playlist name)
  FOLDER=$(ls -d */ | grep -v "__pycache__" | head -1)
  
  if [ -z "$FOLDER" ]; then
    echo "No folder found. Using current directory."
    FOLDER="./"
  else
    echo "Found folder: $FOLDER"
  fi
fi

# Step 9: Process subtitles if needed
if [ "$USE_SUBTITLES" = "true" ] && [ "$CONTENT_TYPE" != "2" ]; then
  process_subtitles
fi

echo "===== Processing complete! ====="
echo "All content has been saved in: $FOLDER"
