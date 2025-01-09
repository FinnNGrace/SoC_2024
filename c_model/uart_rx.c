#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

// Function prototype for extract_data
void extract_data(int word_length);

// Function to find the actual parity bit using XOR
char find_parity(char* data, int length, char parity_type) {
    int i, parity = 0;
    for (i = 0; i < length; i++) {
        parity ^= (data[i] - '0');
    }
    if (parity_type == 'E') return parity ? '1' : '0'; // Even parity
    if (parity_type == 'O') return parity ? '0' : '1'; // Odd parity
    return '\0'; // No parity
}

// Function to simulate UART Rx and write received frames to file
void uart_rx() {
    int word_length, stop_bits, num_data, idle_bits;
    char parity, data[9];

    printf("=== Configure UART Rx ===\n");
    printf("Word Length Select (bits): 5/6/7/8 ? ");
    scanf("%d", &word_length);
    printf("Even Parity or Odd Parity or No Parity: E/O/N ? ");
    scanf(" %c", &parity);
    printf("Stop Bits: 1/2 ? ");
    scanf("%d", &stop_bits);

    FILE *frame_file = fopen("serial_frame_rx.txt", "w");

    printf("How many frames to auto-generate ? ");
    scanf("%d", &num_data);
    srand((unsigned int)time(0));

    for (int i = 0; i < num_data; i++) {
        for (int j = 0; j < word_length; j++) {
            data[j] = (rand() % 2) ? '1' : '0';
        }
        data[word_length] = '\0'; // Null-terminate the data string

        // Write the frame to the file
        fprintf(frame_file, "0\n");  // Start bit

        for (int j = 0; j < word_length; j++) {
            fprintf(frame_file, "%c\n", data[j]);  // Data bits
        }

        // Write parity bit if parity is used
        if (parity != 'N') {
            fprintf(frame_file, "%c\n", find_parity(data, word_length, parity));  // Parity bit
        }

        // Write stop bits
        for (int j = 0; j < stop_bits; j++) {
            fprintf(frame_file, "1\n");  // Stop bits
        }

        // Add idle bits (0 to 5)
        idle_bits = rand() % 6;
        for (int j = 0; j < idle_bits; j++) {
            fprintf(frame_file, "1\n");  // Idle bits (bit '1')
        }
    }

    fclose(frame_file);
    printf("UART reception saved to 'serial_frame_rx.txt'.\n");

    // Extract data without asking for word length again
    extract_data(word_length);
}

// Function to extract only data bits from serial_frame_rx.txt
void extract_data(int word_length) {
    FILE *frame_file = fopen("serial_frame_rx.txt", "r");
    FILE *data_file = fopen("data_extracted_rx.txt", "w");
    char buffer[16];
    int bit_counter = 0;
    int data_bit_counter = 0;
    char extracted_data[9];
    int start_detected = 0;
    int stop_detected = 0;

    if (frame_file == NULL || data_file == NULL) {
        printf("Error opening files.\n");
        return;
    }

    while (fgets(buffer, sizeof(buffer), frame_file)) {
        // Trim any potential newlines from the buffer
        buffer[strcspn(buffer, "\n")] = 0;

        // Detect start bit (0)
        if (buffer[0] == '0' && !start_detected) {
            start_detected = 1;  // Start bit detected
            data_bit_counter = 0; // Reset data bit counter
            stop_detected = 0;    // Reset stop flag
        } 
        else if (start_detected && data_bit_counter < word_length) {
            // Collect data bits in reverse order for LSB-first
            extracted_data[word_length - data_bit_counter - 1] = buffer[0];
            data_bit_counter++;

            // Once enough data bits are collected, null-terminate and proceed with padding
            if (data_bit_counter == word_length) {
                extracted_data[word_length] = '\0';  // Null-terminate the string

                // Pad with leading 0's to make it 8 bits
                char padded_data[9] = "00000000";
                int padding_offset = 8 - word_length;
                for (int i = 0; i < word_length; i++) {
                    padded_data[padding_offset + i] = extracted_data[i];
                }
                padded_data[8] = '\0';  // Ensure null-termination

                // Write padded data to the file
                fprintf(data_file, "%s\n", padded_data);
                stop_detected = 1;  // Expect stop or idle bits next
            }
        } 
        else if (stop_detected && buffer[0] == '1') {
            // Stop or idle detected, reset for next frame
            start_detected = 0;
        }
    }

    fclose(frame_file);
    fclose(data_file);
    printf("Data extracted and saved to 'data_extracted_rx.txt'.\n");
}

int main() {
    uart_rx();  // Simulate UART reception and extract data
    return 0;
}
