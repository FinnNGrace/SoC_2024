#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to find parity bit using XOR
char find_parity(char* data, int length, char parity_type) {
    int parity = 0;
    for (int i = 0; i < length; i++) {
        parity ^= (data[i] - '0');
    }
    if (parity_type == 'E') return parity ? '1' : '0'; // Even parity
    if (parity_type == 'O') return parity ? '0' : '1'; // Odd parity
    return '\0'; // No parity
}

// Function to configure and simulate UART transmission
void uart_tx() {
    int word_length, stop_bits, num_data;
    char parity, data[9];

    printf("=== Configure UART frame ===\n");
    printf("Word Length Select (bits): 5/6/7/8 ? ");
    scanf("%d", &word_length);
    printf("Even Parity or Odd Parity or No Parity: E/O/N ? ");
    scanf(" %c", &parity);
    printf("Stop Bits: 1/2 ? ");
    scanf("%d", &stop_bits);
    
    FILE* config_file = fopen("tx_config.txt", "w");

    switch (word_length) {
        case 5: fprintf(config_file, "00\n"); break;
        case 6: fprintf(config_file, "01\n"); break;
        case 7: fprintf(config_file, "10\n"); break;
        case 8: fprintf(config_file, "11\n"); break;
        default: fprintf(config_file, "Invalid word length\n"); break;
    }

    if (parity == 'N') {
        fprintf(config_file, "0\n");
        fprintf(config_file, "0\n");
    } else {
        fprintf(config_file, "1\n");
        fprintf(config_file, "%c\n", (parity == 'E') ? '1' : '0');
    }

    fprintf(config_file, "%d\n", stop_bits - 1);
    fclose(config_file);

    FILE* file = fopen("tx_frame.txt", "w");

    printf("How many data you want to auto-generate ? ");
    scanf("%d", &num_data);
    srand((unsigned int)time(0));

    FILE* random_file = fopen("tx_data.txt", "w");
    for (int i = 0; i < num_data; i++) {
        for (int j = 0; j < word_length; j++) {
            data[j] = (rand() % 2) ? '1' : '0';
        }
        data[word_length] = '\0';

        for (int j = 0; j < 8 - word_length; j++) {
            fprintf(random_file, "0");
        }
        fprintf(random_file, "%s\n", data);

        fprintf(file, "0\n");
        for (int j = word_length - 1; j >= 0; j--) {
            fprintf(file, "%c\n", data[j]);
        }
        if (parity != 'N') fprintf(file, "%c\n", find_parity(data, word_length, parity));
        for (int j = 0; j < stop_bits; j++) {
            fprintf(file, "1\n");
        }
    }
    fclose(random_file);
    fclose(file);

    printf("UART_Tx input datas saved to 'tx_data.txt'.\n");
    printf("UART_Tx output frames saved to 'tx_frame.txt'.\n");
    printf("UART configuration saved to 'tx_config.txt'.\n");
}

int main() {
    uart_tx();
    return 0;
}
