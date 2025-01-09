`timescale 1ns / 1ns

module UART_Tx_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;
   
   localparam        divisor = 16'd5;
   localparam        OSM_SEL = 1'b0,
                     BGE     = 1'b1,
                     PEN     = 1'b1,
                     EPS     = 1'b1,
                     STB     = 1'b1;
   localparam        WLS     = 2'b10;
   
   reg               clk,
                     rst_n,
                     tx_empty_status;
   reg  [7:0]        tx_data;
   wire              baud_clk;
   wire              tx_done,
                     UART_TX_O;
  
   wire [7:0]        DLL, DLH;
   assign {DLH, DLL} = divisor;
   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (BGE     ),
      .DLL        (DLL     ),
      .DLH        (DLH     ),
      .baud_clk   (baud_clk)
   );

   UART_Tx u_UART_Tx (
      .clk              (clk              ),
      .rst_n            (rst_n            ),
      .baud_clk         (baud_clk         ),
      .tx_empty_status  (tx_empty_status  ),
      .PEN              (PEN              ),
      .EPS              (EPS              ),
      .STB              (STB              ),
      .BGE              (BGE              ),
      .OSM_SEL          (OSM_SEL          ),
      .WLS              (WLS              ),
      .tx_data          (tx_data          ),
      .tx_done          (tx_done          ),
      .UART_TX_O        (UART_TX_O        )
   );

   always #HALF_PERIOD clk = ~clk;
   
   // we aim to control the tx_empty_status to see
   // whether the UART_TX_O can keep IDLE while FIFO_Tx empty
   // whether the UART_TX_O can transmitt data of tx_data
   initial begin
      clk = 0;
      rst_n = 0;
      tx_empty_status = 1;
      #(200*PERIOD);
      rst_n = 1;
      #(500*PERIOD);
      tx_empty_status = 0;
      #(3000*PERIOD);
      tx_empty_status = 1;
      #(500*PERIOD);
      $finish;
   end

   // random new data when a tranmission completed
   initial begin
      while (1) begin
         @(posedge tx_done);
         tx_data = $urandom_range(0, 127);
      end
   end

   initial begin
      $dumpfile("UART_Tx.vcd");
      $dumpvars(0, UART_Tx_tb);
   end

   
endmodule
