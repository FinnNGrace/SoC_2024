import os
import glob

# Function to delete files based on the extension
def delete_files(extension):
    # Get all files with the given extension in the current directory
    files = glob.glob("*.{}".format(extension))

    # Delete each file
    for file in files:
        try:
            os.remove(file)
            print("Deleted: {}".format(file))
        except OSError as e:
            print("Error deleting {}: {}".format(file, e))

# Delete all .txt, .exe, and .run files
delete_files("txt")
delete_files("exe")
delete_files("run")
