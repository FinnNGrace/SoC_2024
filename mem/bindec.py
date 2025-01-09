import random

# Function to generate n random 17-bit binary numbers and their decimal values
def generate_binary_numbers(n):
    binary_decimal_pairs = []
    for _ in range(n):
        # Generate a random 17-bit binary number
        binary_number = ''.join(random.choice(['0', '1']) for _ in range(17))
        decimal_value = int(binary_number, 2)  # Convert binary to decimal
        binary_decimal_pairs.append((binary_number, decimal_value))
    return binary_decimal_pairs

# Example usage
n = 5  # Generate 5 random 17-bit binary numbers
random_numbers = generate_binary_numbers(n)

# Display the results
for binary, decimal in random_numbers:
    print(f"Binary: {binary}, Decimal: {decimal}")
