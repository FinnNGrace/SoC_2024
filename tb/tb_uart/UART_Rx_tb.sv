`timescale 1ns/1ns

module UART_Rx_tb ();
   localparam FILE_PATH = "./../c_model/serial_frame_rx.txt";
   localparam OUT_PATH  = "./../c_model/hdl_data_extracted_rx.txt";
   
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;
  
   localparam        divisor = 16'd5;
   localparam        OSM_SEL = 1'b0,
                     BGE     = 1'b1,
                     PEN     = 1'b1,
                     STB     = 1'b1;
   localparam        WLS     = 2'b00;

   localparam        BAUD_PERIOD = divisor * PERIOD;
   localparam        RX_TICK_PERIOD = OSM_SEL ? 13*BAUD_PERIOD : 16*BAUD_PERIOD;

   integer file, outfile;

   reg               clk,
                     rst_n,
                     UART_RX_I;
   wire              rx_done,
                     baud_clk;
   wire  [7:0]       rx_data;

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

   UART_Rx u_UART_Rx (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .baud_clk   (baud_clk   ),
      .UART_RX_I  (UART_RX_I  ),
      .PEN        (PEN        ),
      .STB        (STB        ),
      .BGE        (BGE        ),
      .OSM_SEL    (OSM_SEL    ),
      .WLS        (WLS        ),
      .rx_done    (rx_done    ),
      .rx_data    (rx_data    )
   );

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      rst_n = 0;
      #(200*PERIOD);
      rst_n = 1;
      #(10000*PERIOD);
      $fclose(outfile);
      $finish;
   end


   initial begin
      UART_RX_I = 1'b1;
      
      file     = $fopen(FILE_PATH, "r");
      outfile  = $fopen(OUT_PATH, "w");
      if (file == 0)    $error("Input file was NOT opened successfully");
      if (outfile == 0) $error("Output file was NOT opened successfully");
      #(5*RX_TICK_PERIOD);

      while (!$feof(file)) begin
         #RX_TICK_PERIOD;
         $fscanf(file, "%b", UART_RX_I);
      end
   end

   initial begin
      while (1) begin
         @(posedge rx_done);
         $fdisplay(outfile, "%b", rx_data);
      end
   end

   initial begin
      $dumpfile("UART_Rx.vcd");
      $dumpvars(0, UART_Rx_tb);
   end

endmodule
