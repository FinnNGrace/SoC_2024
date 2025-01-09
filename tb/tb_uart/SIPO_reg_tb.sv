`timescale 1ns/1ns

module SIPO_reg_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   reg            clk,
                  en;
   reg            serial_in;
   wire [7:0]     parallel_out;

   SIPO_reg u_SIPO_reg (
      .clk           (clk           ),
      .en            (en            ),
      .serial_in     (serial_in     ),
      .parallel_out  (parallel_out  )
   );

   always #HALF_PERIOD clk = ~clk;
   
   initial begin
      clk = 0;
      en = 0;
      #(1000*PERIOD);
      $finish;
   end

   // random value & display to see the difference
   initial begin
      while (1) begin
         @(posedge clk);
         en = $urandom_range(0, 1);
         serial_in = $urandom_range(0, 1);
         #1;
         $display("Time =%7t | en = %b | serial_in = %b | parallel_out = %b", $time, en, serial_in, parallel_out);
      end
   end

   initial begin
      $dumpfile("SIPO_reg.vcd");
      $dumpvars(0, SIPO_reg_tb);
   end

endmodule
