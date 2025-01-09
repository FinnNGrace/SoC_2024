#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to find parity bit
char find_parity(char* data, int length, char parity_type) {
    int parity = 0;
    for (int i = 0; i < length; i++) {
        parity ^= (data[i] - '0');
    }
    if (parity_type == 'E') return parity ? '1' : '0'; // Even parity
    if (parity_type == 'O') return parity ? '0' : '1'; // Odd parity
    return '\0';
}

// Function to simulate UART transmission and create output files
void uart_tx(int test_num) {
    // Generate random configurations
    int word_length = (rand() % 4) + 5; // 5, 6, 7, or 8 bits
    char parity = "EON"[rand() % 3];    // Even (E), Odd (O), or No (N) parity
    int stop_bits = (rand() % 2) + 1;   // 1 or 2 stop bits
    int num_data = (rand() % 100) + 1;  // Number of data points (1 to 100)

    // Generate filenames based on the test number
    char config_filename[20], data_filename[20], frame_filename[20];
    sprintf(config_filename, "tx_config_%d.txt", test_num);
    sprintf(data_filename, "tx_data_%d.txt", test_num);
    sprintf(frame_filename, "tx_frame_%d.txt", test_num);

    // Create config file
    FILE* config_file = fopen(config_filename, "w");
    if (config_file == NULL) {
        printf("Error creating config file for test %d\n", test_num);
        return;
    }

    // Encode word length (00 = 5, 01 = 6, 10 = 7, 11 = 8)
    switch (word_length) {
        case 5: fprintf(config_file, "00\n"); break;
        case 6: fprintf(config_file, "01\n"); break;
        case 7: fprintf(config_file, "10\n"); break;
        case 8: fprintf(config_file, "11\n"); break;
    }

    // Parity configuration
    if (parity == 'N') {
        fprintf(config_file, "0\n"); // No parity
        fprintf(config_file, "0\n"); // Parity bit = 0 if no parity
    } else {
        fprintf(config_file, "1\n"); // Parity enabled
        fprintf(config_file, "%c\n", (parity == 'E') ? '1' : '0'); // Even = 1, Odd = 0
    }

    // Stop bit configuration (0 for 1 stop bit, 1 for 2 stop bits)
    fprintf(config_file, "%d\n", stop_bits - 1);
    fclose(config_file);

    // Create data and frame files
    FILE* data_file = fopen(data_filename, "w");
    FILE* frame_file = fopen(frame_filename, "w");

    if (data_file == NULL || frame_file == NULL) {
        printf("Error creating data or frame file for test %d\n", test_num);
        return;
    }

    char data[9]; // Max data length is 8 bits + null terminator

    for (int i = 0; i < num_data; i++) {
        // Generate random data of given word length
        for (int j = 0; j < word_length; j++) {
            data[j] = (rand() % 2) ? '1' : '0';
        }
        data[word_length] = '\0';

        // Pad data to 8 bits and write to tx_data.txt
        for (int j = 0; j < 8 - word_length; j++) {
            fprintf(data_file, "0"); // Add 0 bits at the start
        }
        fprintf(data_file, "%s\n", data);

        // Write UART frame format to tx_frame.txt
        fprintf(frame_file, "0\n"); // Start bit
        for (int j = word_length - 1; j >= 0; j--) {
            fprintf(frame_file, "%c\n", data[j]); // LSB transmitted first
        }
        if (parity != 'N') {
            fprintf(frame_file, "%c\n", find_parity(data, word_length, parity)); // Parity bit
        }
        for (int j = 0; j < stop_bits; j++) {
            fprintf(frame_file, "1\n"); // Stop bits
        }
    }

    fclose(data_file);
    fclose(frame_file);

    printf("UART_Tx input data saved to '%s'.\n", data_filename);
    printf("UART_Tx output frames saved to '%s'.\n", frame_filename);
    printf("UART configuration saved to '%s'.\n", config_filename);
}

int main() {
    int num_tests;

    // Ask user how many test files to create
    printf("How many random UART IP tests do you want? ");
    scanf("%d", &num_tests);

    srand((unsigned int)time(0));

    // Generate each test set
    for (int i = 1; i <= num_tests; i++) {
        uart_tx(i);
    }

    return 0;
}
