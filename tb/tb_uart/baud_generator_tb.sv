module baud_generator_tb ();
   localparam FREQ = 100_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   localparam divisor = 2604;
   localparam BAUD_CLK_PERIOD = PERIOD * divisor;
   
   reg  [7:0] DLL,
              DLH;
   reg        clk,
              rst_n,
              en;
   wire       baud_clk;

   assign {DLH, DLL} = divisor;
   
   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (en      ),
      .DLL        (DLL     ),
      .DLH        (DLH     ),
      .baud_clk   (baud_clk)
   );

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      en = 1;
      rst_n = 0;
      #(2*PERIOD);
      rst_n = 1;
      #(2*BAUD_CLK_PERIOD);
      en = 0;
      #(5*PERIOD);
      $finish;
   end

   initial begin
      $dumpfile("baud_generator.vcd");
      $dumpvars(0, baud_generator_tb);
   end

endmodule
