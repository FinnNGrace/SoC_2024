module F_reg (
   input  wire          clk,
                        rst_n,
                        stallF,
   input  wire [31:0]   nxt_pc,
   output reg  [31:0]   pcF
);

   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         pcF <= 0;
      end
      else begin
         if (~stallF) begin
            pcF <= nxt_pc;
         end
         else begin
            pcF <= pcF;
         end
      end
   end


endmodule