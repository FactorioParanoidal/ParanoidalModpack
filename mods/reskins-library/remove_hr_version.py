import os
import sys

def process_lua_file(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    processed_lines = []
    skip_block = False
    skipped_block_now_delete = False
    base_indentation = None
    spaces_for_indentation = 4

    for i, line in enumerate(lines):
        if "\t" in line:
            print(f"Tab found in {filename}:{i + 1}, please use spaces for indentation")
            return
        stripped_line = line.lstrip()
        
        # Skip empty lines
        if not stripped_line:
            processed_lines.append(line)
            continue

        # Check if the line contains "hr_version"
        if "hr_version" in stripped_line:
            if "--" in stripped_line:
                print(f"Commented out hr_version found in {filename}:{i + 1}. Skipping")
                processed_lines.append(line)
                continue
            if "." in stripped_line:
                print(f"Non-definition reference to hr_version found in {filename}:{i + 1}. Skipping")
                processed_lines.append(line)
                continue
            print(f"Removing hr_version from line {i + 1}")
            # Calculate the indentation level (number of leading spaces)
            current_indent_level = len(line) - len(stripped_line)

            # Delete current line and previous lines with the same indentation level
            skip_block = True
            base_indentation = current_indent_level
            # Roll back to remove lines from this level and any preceding lines
            while processed_lines and (len(processed_lines[-1]) - len(processed_lines[-1].lstrip())) >= base_indentation:
                processed_lines.pop()
        elif skip_block:
            current_indent_level = len(line) - len(stripped_line)
            
            # If the line is at the target higher indentation level
            if current_indent_level >= base_indentation + spaces_for_indentation and not skipped_block_now_delete:
                # Unindent by spaces_for_indentation spaces
                new_line = " " * (current_indent_level - spaces_for_indentation) + stripped_line
                processed_lines.append(new_line)
            elif current_indent_level == base_indentation + 1:
                print(f"Unexpected indentation level in {filename}:{i + 1}")
                return
            elif current_indent_level >= base_indentation:
                # Either:
                # - Definition had `{` on a separate line. Delete and continue
                # - More non-hr_version definition lines after the hr_version block
                if "{" not in stripped_line:
                  skipped_block_now_delete = True
                continue
            elif current_indent_level < base_indentation:
                # Reached the end of the block. Don't append the current line
                # assert "}" in line, f"Expected '}}' in {filename}:{i + 1}"
                skip_block = False
                skipped_block_now_delete = False
                processed_lines.append(line)
            else:
                # Skip lines at the same or greater indent during block removal
                continue
        else:
            processed_lines.append(line)

    # Write the result back to the file
    with open(filename, 'w') as file:
        file.writelines(processed_lines)

def process_folder(folder_path):
    # Walk through the folder and subfolders
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            # Check if the file has a .lua extension
            if file.endswith('.lua'):
                lua_file_path = os.path.join(root, file)
                print(f"Processing file: {lua_file_path}")
                process_lua_file(lua_file_path)

if __name__ == "__main__":
    # Ensure a folder path is provided as a command line argument
    if len(sys.argv) < 2:
        print("Usage: python script.py <folder_path>")
        sys.exit(1)

    # Get the folder path from the command line argument
    folder_path = sys.argv[1]

    # Process all Lua files in the folder recursively
    process_folder(folder_path)
