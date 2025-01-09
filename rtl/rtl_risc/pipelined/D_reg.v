module D_reg (
   input  wire          clk,
                        rst_n,
   input  wire          stallD, flushD,

   input  wire [31:0]   pcF, instrF, pc4F,
   
   output reg  [31:0]   pcD, instrD, pc4D
);
   
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         pcD <= 0;
         instrD <= 0;
         pc4D <= 0;
      end
      else begin
         if (flushD) begin
            pcD <= 0;
            instrD <= 0;
            pc4D <= 0;
         end
         else begin
            if (~stallD) begin
               pcD <= pcF;
               instrD <= instrF;
               pc4D <= pc4F;
            end
            else begin
               pcD <= pcD;
               instrD <= instrD;
               pc4D <= pc4D;               
            end
         end
      end
   end

endmodule