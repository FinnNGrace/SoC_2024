module parity_store (
   input  wire    clk,
                  en,
                  data_in,
   output reg     parity
);

   always @(posedge clk) begin
      if (en) begin
         parity <= data_in;
      end
      else begin
         parity <= parity;
      end
   end

endmodule