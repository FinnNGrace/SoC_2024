module rx_tick_gen_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   localparam divisor = 16'd5;
   localparam OSM_SEL = 1'b0;

   reg  [7:0] DLL,
              DLH;
   reg        clk,
              rst_n,
              en,
              syn_clr;
   wire       baud_clk,
              rx_tick;

   assign {DLH, DLL} = divisor;

   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (en      ),
      .DLL        (DLL     ),
      .DLH        (DLH     ),
      .baud_clk   (baud_clk)
   );
   
   // NOTE: FOCUS on the enable, if only baud_clk, when the en = 0 in baud_gen
   // there is a possibility that baud_clk latched at 1, and rx_tick_gen still enabled
   rx_tick_gen u_rx_tick_gen (
      .clk        (clk           ),
      .rst_n      (rst_n         ),
      .syn_clr    (syn_clr       ),
      .en         (baud_clk & en ),
      .OSM_SEL    (OSM_SEL       ),
      .rx_tick    (rx_tick       )
   );


   always #HALF_PERIOD clk = ~clk;
   
   initial begin
      clk = 0;
      en = 1;
      rst_n = 0;
      syn_clr = 0;
      #(2*PERIOD);
      rst_n = 1;
      #(1000*PERIOD);
      syn_clr = 1;
      #(100*PERIOD);
      syn_clr = 0;
      #(100*PERIOD);
      en = 0;
      #(50*PERIOD);
      $finish;
   end

   initial begin
      $dumpfile("rx_tick_gen.vcd");
      $dumpvars(0, rx_tick_gen_tb);
   end

endmodule
