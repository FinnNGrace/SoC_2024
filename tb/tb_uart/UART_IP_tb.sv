`timescale 1ns/1ns

module UART_IP_tb ();
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
   localparam        en_tx_fifo_empty = 1'b1,
                     en_tx_fifo_full  = 1'b1,
                     en_rx_fifo_empty = 1'b1,
                     en_rx_fifo_full  = 1'b1;
   
   localparam        BAUD_PERIOD = divisor * PERIOD;
   localparam        RX_TICK_PERIOD = OSM_SEL ? 13*BAUD_PERIOD : 16*BAUD_PERIOD;

   reg               clk,
                     rst_n,
                     tx_flag,
                     rx_flag,
                     UART_RX_I;
   reg   [7:0]       TBR_i;
   wire              baud_clk,
                     UART_TX_O,
                     tx_fifo_empty,
                     tx_fifo_full,
                     rx_fifo_empty,
                     rx_fifo_full;
   
   wire  [7:0]       DLL, DLH,
                     RBR_o;
   assign {DLH, DLL} = divisor;

   UART_IP u_UART_IP (
      .clk              (clk              ),
      .rst_n            (rst_n            ),
      .en_tx_fifo_empty (en_tx_fifo_empty ),
      .en_tx_fifo_full  (en_tx_fifo_full  ),
      .en_rx_fifo_empty (en_rx_fifo_empty ),
      .en_rx_fifo_full  (en_rx_fifo_full  ),
      .tx_flag          (tx_flag          ),
      .rx_flag          (rx_flag          ),
      .PEN              (PEN              ),
      .EPS              (EPS              ),
      .STB              (STB              ),
      .BGE              (BGE              ),
      .OSM_SEL          (OSM_SEL          ),
      .WLS              (WLS              ),
      .TBR_i            (TBR_i            ),
      .DLH              (DLH              ),
      .DLL              (DLL              ),
      .UART_RX_I        (UART_RX_I        ),
      .UART_TX_O        (UART_TX_O        ),
      .RBR_o            (RBR_o            ),
      .tx_fifo_empty    (tx_fifo_empty    ),
      .tx_fifo_full     (tx_fifo_full     ),
      .rx_fifo_empty    (rx_fifo_empty    ),
      .rx_fifo_full     (rx_fifo_full     )
   );  

   // evil testing method
   assign UART_RX_I = UART_TX_O;

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      rst_n = 1;
      tx_flag = 0;
      rx_flag = 0;
      #(20*PERIOD);
      rst_n = 0;
      #(200*PERIOD);
      rst_n = 1;
      #(50000*PERIOD);
      $finish;
   end

   // UART Transmission
   initial begin
   #(400*PERIOD);
      while ($time < 25000*PERIOD) begin
         if (!tx_fifo_full) begin
            @(posedge clk);
            TBR_i = $urandom_range(0, 255); 
            tx_flag = 1;
            @(negedge clk);
            tx_flag = 0;
         end
         else begin
            @(negedge clk);
            TBR_i = TBR_i;
            tx_flag = 0;
         end
      end      
   end

   // UART Reception
   initial begin
   #(400*PERIOD);
      while (1) begin
         if (!rx_fifo_empty) begin
            @(posedge clk);
            rx_flag = 1;
            @(negedge clk);
            rx_flag = 0;
         end 
         else begin
            @(negedge clk);
            rx_flag = 0;
         end
      end
   end

   initial begin
      $dumpfile("UART_IP.vcd");
      $dumpvars(0, UART_IP_tb);
   end

endmodule
