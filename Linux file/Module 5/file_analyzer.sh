#!/bin/bash

ERROR_LOG="errors.log"  # File to store errors
exec 2>>"$ERROR_LOG"    # Redirect all errors to errors.log

# Function to search for a keyword in a directory (recursive)
search_directory() {
    local dir="$1"
    local keyword="$2"

    if [[ ! -d "$dir" ]]; then
        echo "Error: Directory '$dir' not found!" | tee -a "$ERROR_LOG"
        return 1
    fi

    grep -rHn "$keyword" "$dir" || echo "No matches found in $dir"
}

# Function to search for a keyword in a file using a here string
search_file() {
    local file="$1"
    local keyword="$2"

    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found!" | tee -a "$ERROR_LOG"
        return 1
    fi

    grep -Hn "$keyword" <<< "$(cat "$file")" || echo "Keyword '$keyword' not found in: $file"
}

# Function to display the help menu using a here document
display_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Search for a keyword in a directory (recursive search)
  -k <keyword>     Specify the keyword to search for
  -f <file>        Search for a keyword in a specific file
  --help           Display this help menu

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}

# Ensure at least one argument is provided
if [[ $# -eq 0 ]]; then
    echo "Error: No arguments provided!" | tee -a "$ERROR_LOG"
    display_help
    exit 1
fi

# Parse command-line arguments using getopts
while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -) case "$OPTARG" in
               help) display_help; exit 0 ;;
               *) echo "Error: Invalid option '--$OPTARG'" | tee -a "$ERROR_LOG"; exit 1 ;;
           esac ;;
        ?) echo "Error: Invalid option '-$OPTARG'" | tee -a "$ERROR_LOG"; exit 1 ;;
    esac
done

# Validate inputs
if [[ -z "$keyword" ]]; then
    echo "Error: Keyword must not be empty!" | tee -a "$ERROR_LOG"
    exit 1
fi

if [[ -n "$directory" && -n "$file" ]]; then
    echo "Error: Please specify either a file (-f) or a directory (-d), not both!" | tee -a "$ERROR_LOG"
    exit 1
fi

# Execute appropriate search
if [[ -n "$directory" ]]; then
    search_directory "$directory" "$keyword"
elif [[ -n "$file" ]]; then
    search_file "$file" "$keyword"
else
    echo "Error: Missing required arguments!" | tee -a "$ERROR_LOG"
    display_help
    exit 1
fi
