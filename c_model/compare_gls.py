import os
import re

def compare_files(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        return f1.read() == f2.read()

def main():
    files = os.listdir('.')
    pairs = []
    for file in files:
        match = re.match(r'tx_data_(\d+)\.txt', file)
        if match:
            n = match.group(1)
            extracted_file = 'gls_extracted_data_{}.txt'.format(n)
            if extracted_file in files:
                pairs.append((file, extracted_file))

    for tx_file, extracted_file in pairs:
        n = re.search(r'(\d+)', tx_file).group(1)
        if compare_files(tx_file, extracted_file):
            print('Test package {}: PASSED'.format(n))
        else:
            print('Test package {}: FAILED'.format(n))

if __name__ == '__main__':
    main()
