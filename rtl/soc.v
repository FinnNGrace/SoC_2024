`include "cpu_def.vh"

module soc (
   input  wire          clk,
                        rst_n,
   // RISC
   input  wire [31:0]   sw,
   input  wire [3:0]    btn,
   output wire [31:0]   pc_debug,
   output wire          instr_vld,
   output wire [31:0]   ledr,
                        ledg,
                        lcd,
   output wire [6:0]    hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7,
   // APB-UART
   input  wire          UART_RX_I,
   output wire          UART_TX_O,
                        tx_fifo_empty,
                        tx_fifo_full,
                        rx_fifo_empty,
                        rx_fifo_full
);

   wire          PENABLE,
                 PSEL,
                 PWRITE;
   wire [31:0]   PWDATA;
   wire [31:0]   PADDR;
   wire          PREADY;
   wire          PSLVERR;
   wire [31:0]   PRDATA;

   wire [31:0]   PSEL_tmp, PENABLE_tmp, PWRITE_tmp;

   assign PSEL    = PSEL_tmp[0];
   assign PENABLE = PENABLE_tmp[0];
   assign PWRITE  = PWRITE_tmp[0];

   `ifdef USE_SINGLE_CYCLE
      single_cycle u_single_cycle (
         .clk        (clk),
         .rst_n      (rst_n),
         .sw         (sw),
         .btn        (btn),
         .pc_debug   (pc_debug),
         .instr_vld  (instr_vld),
         .ledr       (ledr),
         .ledg       (ledg),
         .lcd        (lcd),
         .hex0       (hex0),
         .hex1       (hex1),
         .hex2       (hex2),
         .hex3       (hex3),
         .hex4       (hex4),
         .hex5       (hex5),
         .hex6       (hex6),
         .hex7       (hex7),
         .PREADY     ({31'b0, PREADY}),
         .PSLVERR    ({31'b0, PSLVERR}),
         .PRDATA     (PRDATA),
         .PSEL       (PSEL_tmp),
         .PENABLE    (PENABLE_tmp),
         .PADDR      (PADDR),
         .PWDATA     (PWDATA),
         .PWRITE     (PWRITE_tmp)
      );
   `elsif USE_PIPELINED_VER1
      pipelined_ver1 u_pipelined_ver1 (
         .clk        (clk),
         .rst_n      (rst_n),
         .sw         (sw),
         .btn        (btn),
         .pc_debug   (pc_debug),
         .instr_vld  (instr_vld),
         .ledr       (ledr),
         .ledg       (ledg),
         .lcd        (lcd),
         .hex0       (hex0),
         .hex1       (hex1),
         .hex2       (hex2),
         .hex3       (hex3),
         .hex4       (hex4),
         .hex5       (hex5),
         .hex6       (hex6),
         .hex7       (hex7),
         .PREADY     ({31'b0, PREADY}),
         .PSLVERR    ({31'b0, PSLVERR}),
         .PRDATA     (PRDATA),
         .PSEL       (PSEL_tmp),
         .PENABLE    (PENABLE_tmp),
         .PADDR      (PADDR),
         .PWDATA     (PWDATA),
         .PWRITE     (PWRITE_tmp)
      );
   `elsif USE_PIPELINED_VER2
      pipelined_ver2 u_pipelined_ver2 (
         .clk        (clk),
         .rst_n      (rst_n),
         .sw         (sw),
         .btn        (btn),
         .pc_debug   (pc_debug),
         .instr_vld  (instr_vld),
         .ledr       (ledr),
         .ledg       (ledg),
         .lcd        (lcd),
         .hex0       (hex0),
         .hex1       (hex1),
         .hex2       (hex2),
         .hex3       (hex3),
         .hex4       (hex4),
         .hex5       (hex5),
         .hex6       (hex6),
         .hex7       (hex7),
         .PREADY     ({31'b0, PREADY}),
         .PSLVERR    ({31'b0, PSLVERR}),
         .PRDATA     (PRDATA),
         .PSEL       (PSEL_tmp),
         .PENABLE    (PENABLE_tmp),
         .PADDR      (PADDR),
         .PWDATA     (PWDATA),
         .PWRITE     (PWRITE_tmp)
      );      
   `elsif
      single_cycle u_single_cycle (
         .clk        (clk),
         .rst_n      (rst_n),
         .sw         (sw),
         .btn        (btn),
         .pc_debug   (pc_debug),
         .instr_vld  (instr_vld),
         .ledr       (ledr),
         .ledg       (ledg),
         .lcd        (lcd),
         .hex0       (hex0),
         .hex1       (hex1),
         .hex2       (hex2),
         .hex3       (hex3),
         .hex4       (hex4),
         .hex5       (hex5),
         .hex6       (hex6),
         .hex7       (hex7),
         .PREADY     ({31'b0, PREADY}),
         .PSLVERR    ({31'b0, PSLVERR}),
         .PRDATA     (PRDATA),
         .PSEL       (PSEL_tmp),
         .PENABLE    (PENABLE_tmp),
         .PADDR      (PADDR),
         .PWDATA     (PWDATA),
         .PWRITE     (PWRITE_tmp)
      );
   `endif

   apb_uart u_apb_uart (
      .clk           (clk           ),
      .rst_n         (rst_n         ),
      .UART_RX_I     (UART_RX_I     ),
      .UART_TX_O     (UART_TX_O     ),
      .tx_fifo_empty (tx_fifo_empty ),
      .tx_fifo_full  (tx_fifo_full  ),
      .rx_fifo_empty (rx_fifo_empty ),
      .rx_fifo_full  (rx_fifo_full  ),
      .PENABLE       (PENABLE       ),
      .PSEL          (PSEL          ),
      .PWRITE        (PWRITE        ),
      .PWDATA        (PWDATA        ),
      .PADDR         (PADDR         ),
      .PREADY        (PREADY        ),
      .PSLVERR       (PSLVERR       ),
      .PRDATA        (PRDATA        )
   );



endmodule