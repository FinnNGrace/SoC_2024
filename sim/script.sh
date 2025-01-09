# xrun -f ./../rtl/flist.f ./../tb/tb_uart/UART_IP_full_random_tb.sv -timescale 1ns/1ps -access +rwc
# xrun -f ./../rtl/flist.f ./../tb/tb_risc/pipelined_ver1_tb.sv -timescale 1ns/1ps -access +rwc -gui
# xrun -f ./../rtl/flist.f ./../tb/tb_risc/single_cycle_tb.sv -timescale 1ns/1ps -access +rwc -gui
# xrun -f ./../rtl/flist.f ./../tb/apb_slave_tb.sv -timescale 1ns/1ps -access +rwc -gui
# xrun -f ./../rtl/flist.f ./../tb/apb_uart_tb.sv -timescale 1ns/1ps -access +rwc -gui
xrun -f ./../rtl/flist.f ./../tb/soc_tb.sv -timescale 1ns/1ps -access +rwc -gui
