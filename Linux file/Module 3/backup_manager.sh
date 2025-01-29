#!/bin/bash

# To check the number of arguments
if [ "$#" -ne 3 ]; then
    echo "Provide the parameters : Source_dir , Destination_dir , File_extension"
    exit 1
fi

# Assign arguments to variables
SOURCE_DIR="$1"
BACKUP_DIR="$2"
FILE_EXT="$3"

# Validate source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Create backup directory if it does not exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || { echo "Error: Failed to create backup directory '$BACKUP_DIR'."; exit 1; }
fi

# Find files matching the given extension
FILES=("$SOURCE_DIR"/*"$FILE_EXT")

# Check if any files match
if [ ! -e "${FILES[0]}" ]; then
    echo "No files with extension '$FILE_EXT' found in '$SOURCE_DIR'."
    exit 0
fi

# Initialize counters
TOTAL_FILES=0
TOTAL_SIZE=0
# Print file details before backup
echo "Files to be backed up:"
for FILE in "${FILES[@]}"; do
    FILE_NAME=$(basename "$FILE")
    FILE_SIZE=$(stat -c%s "$FILE")
    echo "- $FILE_NAME ($FILE_SIZE bytes)"
    TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))

    # Perform backup with conditional overwriting
    DEST_FILE="$BACKUP_DIR/$FILE_NAME"
    if [ -e "$DEST_FILE" ]; then
        if [ "$FILE" -nt "$DEST_FILE" ]; then
            cp "$FILE" "$DEST_FILE"
            echo "Updated: $FILE_NAME"
            ((TOTAL_FILES++))
        fi
    else
        cp "$FILE" "$DEST_FILE"
        echo "Copied: $FILE_NAME"
        ((TOTAL_FILES++))
    fi
done

# Export backup count
export BACKUP_COUNT=$TOTAL_FILES

# Generate report
REPORT_FILE="$BACKUP_DIR/backup_report.log"
echo "Backup Summary:" > "$REPORT_FILE"
echo "Total files processed: $TOTAL_FILES" >> "$REPORT_FILE"
echo "Total size of files backed up: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup location: $BACKUP_DIR" >> "$REPORT_FILE"

echo "Backup complete. Report saved to $REPORT_FILE"

