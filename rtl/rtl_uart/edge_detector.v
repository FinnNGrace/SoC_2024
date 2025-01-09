module edge_detector (
   input    wire  clk,
                  data_in,
   output   wire  pulse_out
);

   // the high-cycle of the pulse_out will <= clk cycle (smaller or equal)
   reg  q;
   always @(posedge clk) begin
      q <= data_in;
   end

   assign pulse_out = data_in & ~q;

endmodule