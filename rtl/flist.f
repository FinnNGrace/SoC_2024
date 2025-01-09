// Directory that contains verilog header file
+incdir+/root/Desktop/03_thesis/rtl/rtl_risc

// UART
./../rtl/rtl_uart/PISO_reg.v
./../rtl/rtl_uart/edge_detector.v
./../rtl/rtl_uart/dual_port_RAM.v
./../rtl/rtl_uart/syn_fifo.v
./../rtl/rtl_uart/parity_gen.v
./../rtl/rtl_uart/baud_generator.v
./../rtl/rtl_uart/tx_tick_gen.v
./../rtl/rtl_uart/Tx_FSM.v
./../rtl/rtl_uart/SIPO_reg.v
./../rtl/rtl_uart/parity_store.v
./../rtl/rtl_uart/concat.v
./../rtl/rtl_uart/rx_tick_gen.v
./../rtl/rtl_uart/Rx_FSM.v
./../rtl/rtl_uart/UART_Tx.v
./../rtl/rtl_uart/UART_Rx.v
./../rtl/rtl_uart/UART_IP.v

// RISC-core: common modules
./../rtl/rtl_risc/add_sub_comp.v
./../rtl/rtl_risc/alu.v
./../rtl/rtl_risc/branch_cmp.v
./../rtl/rtl_risc/control_unit.v
./../rtl/rtl_risc/imem.v
./../rtl/rtl_risc/imm_gen.v
./../rtl/rtl_risc/lsu.v
./../rtl/rtl_risc/reg_file.v

// RISC-core: Single Cycle (debug only)
./../rtl/rtl_risc/single_cycle/program_counter.v
./../rtl/rtl_risc/single_cycle/register.v
./../rtl/rtl_risc/single_cycle/single_cycle.v

// RISC-core: 5-Staged Pipelined - Forwarding only
./../rtl/rtl_risc/pipelined/branch_sel.v
./../rtl/rtl_risc/pipelined/D_reg.v
./../rtl/rtl_risc/pipelined/E_reg.v
./../rtl/rtl_risc/pipelined/F_reg.v
./../rtl/rtl_risc/pipelined/M_reg.v
./../rtl/rtl_risc/pipelined/W_reg.v
./../rtl/rtl_risc/pipelined/hazard_unit.v
./../rtl/rtl_risc/pipelined/pipelined_ver1.v

// RISC-core: 5-Staged Pipelined - Branch Prediction
./../rtl/rtl_risc/pipelined/branch_prediction/one_bit_predictor.v
./../rtl/rtl_risc/pipelined/branch_prediction/two_bit_predictor.v
./../rtl/rtl_risc/pipelined/branch_prediction/btb.v
./../rtl/rtl_risc/pipelined/branch_prediction/branch_predictor.v
./../rtl/rtl_risc/pipelined/branch_prediction/pipelined_ver2.v

// APB-UART
./../rtl/reg_bank.v
./../rtl/apb_slave.v
./../rtl/apb_uart.v
./../rtl/soc.v
