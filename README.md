# Smart File Organizer

An intelligent file organization script that uses OpenAI's API to automatically categorize and organize files into meaningful folders.

## Features

- Automatically analyzes files in the current directory
- Groups similar files together based on content, type, and context
- Creates an organized folder structure
- Handles duplicate files automatically
- Skips hidden files
- Maintains original file names
- Uses AI to determine the most logical organization structure

## Prerequisites

Before running the script, ensure you have the following installed:

```bash
# Install Homebrew if you haven't already
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required dependencies
brew install jq
```

## Installation

1. Download the script:
```bash
curl -o ~/organize.sh https://[your-host]/organize.sh
```

2. Make it executable:
```bash
chmod +x ~/organize.sh
```

3. Add the alias to your .zshrc:
```bash
echo 'alias organize="~/organize.sh"' >> ~/.zshrc
source ~/.zshrc
```

## Usage

Basic usage:
```bash
# Go to any directory you want to organize
cd ~/Downloads

# Run the organizer
organize
```

The script will:
1. Scan all non-hidden files in the current directory
2. Analyze their content and relationships
3. Create an `ORGANIZED` folder with appropriate subfolders
4. Move files into their respective categories

## Example Structure

Input directory:
```
Downloads/
├── report_q1_2024.pdf
├── report_q2_2024.pdf
├── meeting_notes.docx
├── profile_pic.jpg
└── screenshot_2024.png
```

After organization:
```
Downloads/
└── ORGANIZED/
    ├── Financial_Reports/
    │   ├── report_q1_2024.pdf
    │   └── report_q2_2024.pdf
    ├── Documents/
    │   └── meeting_notes.docx
    └── Images/
        ├── profile_pic.jpg
        └── screenshot_2024.png
```

## Configuration

The script uses OpenAI's API for file analysis. The API key is already included in the script.

## Notes

- The script never deletes files, only moves them
- Original filenames are preserved
- Duplicate files are handled by adding a number suffix
- Hidden files (starting with '.') are ignored
- The script creates an 'ORGANIZED' folder in the current directory

## Troubleshooting

If you get errors about missing commands:
```bash
# Install jq if missing
brew install jq

# Make sure the script is executable
chmod +x ~/organize.sh

# Verify the alias is set up
echo 'alias organize="~/organize.sh"' >> ~/.zshrc
source ~/.zshrc
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.
