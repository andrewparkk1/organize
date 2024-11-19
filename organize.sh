#!/bin/bash

# Configuration
API_KEY=""
ORGANIZED_DIR="./ORGANIZED"

# Function to get file info for multiple files
get_files_info() {
    local files=("$@")
    local info=""
    
    for file in "${files[@]}"; do
        if [ -f "$file" ] && [[ ! "$file" =~ ^\. ]]; then
            local filename=$(basename "$file")
            local extension="${filename##*.}"
            local size=$(ls -lh "$file" | awk '{print $5}')
            local type=$(file -b "$file")
            
            info+="File: $filename"$'\n'
            info+="Extension: $extension"$'\n'
            info+="Size: $size"$'\n'
            info+="Type: $type"$'\n'
            info+="---"$'\n'
        fi
    done
    
    echo "$info"
}

# Function to suggest folders using OpenAI
suggest_folders() {
    local files_info="$1"
    
    local response=$(curl --silent \
        --header "Authorization: Bearer $API_KEY" \
        --header "Content-Type: application/json" \
        --data @- https://api.openai.com/v1/chat/completions <<EOF
{
    "model": "gpt-3.5-turbo",
    "messages": [
        {
            "role": "system",
            "content": "You are a file organization expert. Analyze files and suggest a logical folder structure, grouping similar files together. Return your suggestion as a JSON object where the keys are folder names and values are arrays of filenames. Example input files:\nFile: report_q1_2024.pdf\nExtension: pdf\nSize: 2.1M\nType: PDF document\n---\nFile: report_q2_2024.pdf\nExtension: pdf\nSize: 1.8M\nType: PDF document\n---\nFile: meeting_notes.docx\nExtension: docx\nSize: 156K\nType: Microsoft Word document\n\nExample JSON response:\n{\n  \"Financial_Reports\": [\"report_q1_2024.pdf\", \"report_q2_2024.pdf\"],\n  \"Documents\": [\"meeting_notes.docx\"]\n}"
        },
        {
            "role": "user",
            "content": "Please analyze and organize these files:\n$files_info"
        }
    ],
    "response_format": { "type": "json_object" },
    "temperature": 0.2
}
EOF
)
    
    echo "$response"
}

# Function to organize files
organize_files() {
    local current_dir=$(pwd)
    echo "🔍 Starting smart file organization in: $current_dir"
    
    # Create ORGANIZED directory if it doesn't exist
    mkdir -p "$ORGANIZED_DIR"
    
    # Get list of non-hidden files (fixed file finding)
    files=()
    for file in *; do
        # Skip if it's a directory, hidden file, or not a file
        if [ -f "$file" ] && [[ ! "$file" =~ ^\. ]]; then
            files+=("$file")
        fi
    done
    
    # Check if we found any files
    if [ ${#files[@]} -eq 0 ]; then
        echo "No files to organize"
        echo "Current directory contents:"
        ls -la
        return
    fi
    
    echo "Found ${#files[@]} files to organize..."
    
    # Get file info for all files at once
    files_info=$(get_files_info "${files[@]}")
    
    # Get folder suggestions from OpenAI
    echo "Analyzing files..."
    response=$(suggest_folders "$files_info")
    
    # Extract the actual folder structure from the response
    folder_structure=$(echo "$response" | jq -r '.choices[0].message.content')
    
    # Process the JSON response and move files
    echo "$folder_structure" | jq -r 'to_entries[] | "\(.key)|\(.value[])"' | while IFS='|' read -r folder file; do
        if [ -n "$folder" ] && [ -n "$file" ]; then
            target_dir="$ORGANIZED_DIR/$folder"
            mkdir -p "$target_dir"
            
            # Check if file exists
            if [ -f "./$file" ]; then
                target_path="$target_dir/$file"
                
                # Handle duplicates
                if [ -f "$target_path" ]; then
                    counter=1
                    while [ -f "${target_path%.*}_${counter}.${target_path##*.}" ]; do
                        counter=$((counter+1))
                    done
                    target_path="${target_path%.*}_${counter}.${target_path##*.}"
                fi
                
                mv "./$file" "$target_path"
                echo "📦 Moved to: $folder/$(basename "$target_path")"
            fi
        fi
    done
    
    echo "✨ Organization complete!"
    
    # Display final structure
    if command -v tree &> /dev/null; then
        echo -e "\n📁 Final ORGANIZED folder structure:"
        tree "$ORGANIZED_DIR" -L 2 --dirsfirst
    else
        echo -e "\n📁 ORGANIZED folder contents:"
        ls -R "$ORGANIZED_DIR"
    fi
}

# Parse command line arguments
case "$1" in
    -h|--help)
        show_help
        ;;
    -o|--organize)
        organize_files
        ;;
    *)
        organize_files
        ;;
esac
