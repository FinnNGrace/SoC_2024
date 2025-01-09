import os

def remove_hex_prefix_in_all_files():
    # Get the current working directory
    current_directory = os.getcwd()

    # Loop through all files in the directory
    for filename in os.listdir(current_directory):
        # Process only .hex files
        if filename.endswith('.hex'):
            file_path = os.path.join(current_directory, filename)

            # Read the file and remove '0x' prefix if present
            with open(file_path, 'r') as infile:
                lines = infile.readlines()

            cleaned_lines = []
            for line in lines:
                # Strip the line of any leading/trailing spaces and check for '0x'
                cleaned_line = line.strip()
                if cleaned_line.startswith("0x"):
                    cleaned_line = cleaned_line[2:]  # Remove the '0x' prefix
                cleaned_lines.append(cleaned_line + "\n")

            # Overwrite the file with cleaned lines
            with open(file_path, 'w') as outfile:
                outfile.writelines(cleaned_lines)

# Call the function to process all .hex files in the current directory
remove_hex_prefix_in_all_files()
