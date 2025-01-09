def remove_unwanted_lines(file_path):
    # Đọc tất cả các dòng trong file
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Lọc các dòng không chứa "PASSED" và không chứa "result = 000000000000000, expected = zzzzzzzzzzzzzzz"
    filtered_lines = [
        line for line in lines
        if "PASSED" not in line and "result = 000000000000000, expected = zzzzzzzzzzzzzzz" not in line
    ]

    # Ghi đè file với các dòng đã được lọc
    with open(file_path, 'w') as file:
        file.writelines(filtered_lines)

# Sử dụng hàm
file_path = 'D:/Verilog_archived/02_CPU/03_FinnRISCV/0_questa/control_unit_log.txt'  # Đường dẫn tới file cần chỉnh sửa
remove_unwanted_lines(file_path)
