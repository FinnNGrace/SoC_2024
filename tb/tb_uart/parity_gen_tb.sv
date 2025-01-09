module parity_gen_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;

   reg [7:0]   tx_data;
   reg [1:0]   WLS;
   reg         EPS;
   wire        parity;

   parity_gen u_parity_gen (
      .tx_data (tx_data ),
      .WLS     (WLS     ),
      .EPS     (EPS     ),
      .parity  (parity  )
   );

   initial begin
      while (1) begin
         tx_data = $urandom_range(255, 0);
         WLS     = $urandom_range(3,0);
         EPS     = $urandom_range(1,0);
         #PERIOD;
      end
   end


   initial begin
      #(10*PERIOD);
      $finish;
   end

   initial begin
      $monitor("tx_data = %b, WLS = %b, EPS = %b, parity_out = %b", tx_data, WLS, EPS, parity);
   end

   initial begin
      $dumpfile("parity_gen.vcd");
      $dumpvars(0, parity_gen_tb);
   end

endmodule
