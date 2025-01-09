import os
import re

def compare_files(file1, file2):
    # Compare the content of two files
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        return f1.read() == f2.read()

def main():
    files = os.listdir('.')  # Get the list of all files in the current directory
    pairs = []
    for file in sorted(files):  # Sort the files alphabetically
        match = re.match(r'tx_data_(\d+)\.txt', file)  # Match files with pattern 'tx_data_<number>.txt'
        if match:
            n = match.group(1)  # Extract the number from the file name
            extracted_file = 'extracted_data_{}.txt'.format(n)  # Create the corresponding extracted file name
            if extracted_file in files:  # Check if the corresponding extracted file exists
                pairs.append((file, extracted_file))  # Add the pair to the list

    # Sort the file pairs numerically based on the number in the file name
    pairs.sort(key=lambda x: int(re.search(r'(\d+)', x[0]).group(1)))

    for tx_file, extracted_file in pairs:
        n = re.search(r'(\d+)', tx_file).group(1)  # Extract the number for reporting
        if compare_files(tx_file, extracted_file):  # Compare the two files
            print('Test package {}: PASSED'.format(n))  # Report success
        else:
            print('Test package {}: FAILED'.format(n))  # Report failure

if __name__ == '__main__':
    main()
