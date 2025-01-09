module M_reg (
   input  wire          clk,
                        rst_n,

   input  wire          rd_wr_enE,
   input  wire [1:0]    wb_selE,
   input  wire          mem_wr_enE,
   input  wire [2:0]    data_modeE,
   input  wire [31:0]   alu_dataE,
                        FW_bE,
                        pc4E,
   input  wire [4:0]    rd_addrE,  

   output reg           rd_wr_enM,
   output reg  [1:0]    wb_selM,
   output reg           mem_wr_enM,
   output reg  [2:0]    data_modeM,
   output reg  [31:0]   alu_dataM,
                        FW_bM,
                        pc4M,
   output reg  [4:0]    rd_addrM
);

   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         rd_wr_enM <= 0;
         wb_selM <= 0;
         mem_wr_enM <= 0;
         data_modeM <= 0;
         alu_dataM <= 0;
         FW_bM <= 0;
         pc4M <= 0;
         rd_addrM <= 0;
      end
      else begin
         rd_wr_enM <= rd_wr_enE;
         wb_selM <= wb_selE;
         mem_wr_enM <= mem_wr_enE;
         data_modeM <= data_modeE;
         alu_dataM <= alu_dataE;
         FW_bM <= FW_bE;
         pc4M <= pc4E;
         rd_addrM <= rd_addrE;       
      end
   end

endmodule