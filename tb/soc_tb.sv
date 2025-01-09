`timescale 1ns/1ns

module soc_tb ();
   localparam FREQ         = 50_000_000;
   localparam PERIOD       = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD  = PERIOD / 2;

   reg         clk,
               rst_n;
   reg  [31:0] sw;
   reg  [3:0]  btn;
   wire [31:0] pc_debug,
               ledr,
               ledg,
               lcd;
   wire  [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
   wire        instr_vld;

   reg         UART_RX_I;
   wire        UART_TX_O,
               tx_fifo_empty,
               tx_fifo_full,
               rx_fifo_empty,
               rx_fifo_full;

   soc u_soc (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .sw         (sw         ),
      .btn        (btn        ),
      .pc_debug   (pc_debug   ),
      .instr_vld  (instr_vld  ),
      .ledr       (ledr       ),
      .ledg       (ledg       ),
      .lcd        (lcd        ),
      .hex0       (hex0       ),
      .hex1       (hex1       ),
      .hex2       (hex2       ),
      .hex3       (hex3       ),
      .hex4       (hex4       ),
      .hex5       (hex5       ),
      .hex6       (hex6       ),
      .hex7       (hex7       ),
      .UART_RX_I  (UART_RX_I  ),
      .UART_TX_O  (UART_TX_O  ),
      .tx_fifo_empty (tx_fifo_empty ),
      .tx_fifo_full  (tx_fifo_full  ),
      .rx_fifo_empty (rx_fifo_empty ),
      .rx_fifo_full  (rx_fifo_full  )
   );

   always #HALF_PERIOD clk = ~clk;
   // back to back testing, evil testing
   assign UART_RX_I = UART_TX_O;

   initial begin
      clk = 0;
      rst_n = 0;
      #(PERIOD)
      rst_n = 1;
      // sw = 32'hDD123456;
      sw = 32'd2;   
      // #(10000*PERIOD);
      // sw = 32'h010111AB;
      // #1000;
      // sw = 123456;


      //$finish;
   end

   // initial begin
   //    $dumpfile("soc.vcd");
   //    $dumpvars(0, soc_tb);
   // end

endmodule
