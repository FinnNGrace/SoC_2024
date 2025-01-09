module W_reg (
   input  wire          clk,
                        rst_n,
                                           
   input  wire          rd_wr_enM,
   input  wire [1:0]    wb_selM,
   input  wire [31:0]   alu_dataM,
                        lsu_dataM,
                        pc4M,
   input  wire [4:0]    rd_addrM,

   output reg           rd_wr_enW,
   output reg  [1:0]    wb_selW,
   output reg  [31:0]   alu_dataW,
                        lsu_dataW,
                        pc4W,
   output reg  [4:0]    rd_addrW                      
);
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         rd_wr_enW <= 0;
         wb_selW <= 0;
         alu_dataW <= 0;
         lsu_dataW <= 0;
         pc4W <= 0;
         rd_addrW <= 0;
      end
      else begin
         rd_wr_enW <= rd_wr_enM;
         wb_selW <= wb_selM;
         alu_dataW <= alu_dataM;
         lsu_dataW <= lsu_dataM;
         pc4W <= pc4M;
         rd_addrW <= rd_addrM;
      end
   end


endmodule