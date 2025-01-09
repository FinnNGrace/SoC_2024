module SIPO_reg (
   input  wire       clk,
                     en,
   input  wire       serial_in,
   output reg  [7:0] parallel_out     
);
   
   always @(posedge clk) begin
      if (en) begin
         parallel_out <= {serial_in, parallel_out[7:1]}; 
      end
      else begin
         parallel_out  <= parallel_out;
      end
   end

endmodule
