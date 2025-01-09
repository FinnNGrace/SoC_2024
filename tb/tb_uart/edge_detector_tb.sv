module edge_detector_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   reg   clk;
   reg   data_in;
   wire  pulse_out;

   edge_detector u_edge_detector (
      .clk        (clk        ),
      .data_in    (data_in    ),
      .pulse_out  (pulse_out  )
   );

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      data_in = 0;
      forever begin
         #($urandom_range(40, 25));
         data_in = ~data_in;
      end
   end

   initial begin
      #(20*PERIOD);
      $finish;
   end


   initial begin
      $dumpfile("edge_detector.vcd");
      $dumpvars(0, edge_detector_tb);
   end


endmodule