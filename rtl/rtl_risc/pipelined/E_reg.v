module E_reg (
   input  wire          clk,
                        rst_n,
   input  wire          flushE,

   input  wire          rd_wr_enD,
   input  wire [1:0]    wb_selD,
   input  wire          mem_wr_enD,
   input  wire [2:0]    data_modeD,
   input  wire [3:0]    alu_selD,
   input  wire          b_selD, a_selD,
                        br_unsignedD,
   input  wire [31:0]   instrD,
                        pcD,
                        rs1_dataD, rs2_dataD,
                        immD,
                        pc4D,
   input  wire [4:0]    rs1_addrD, rs2_addrD, rd_addrD,

   output reg           rd_wr_enE,
   output reg  [1:0]    wb_selE,
   output reg           mem_wr_enE,
   output reg  [2:0]    data_modeE,
   output reg  [3:0]    alu_selE,
   output reg           b_selE, a_selE,
                        br_unsignedE,
   output reg  [31:0]   instrE,
                        pcE,
                        rs1_dataE, rs2_dataE,
                        immE,
                        pc4E,
   output reg  [4:0]    rs1_addrE, rs2_addrE, rd_addrE
);

   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         rd_wr_enE <= 0;
         wb_selE <= 0;
         mem_wr_enE <= 0;
         data_modeE <= 0;
         alu_selE <= 0;
         b_selE <= 0;
         a_selE <= 0;
         br_unsignedE <= 0;
         instrE <= 0;
         pcE <= 0;
         rs1_dataE <= 0; 
         rs2_dataE <= 0;
         immE <= 0;
         pc4E <= 0;
         rs1_addrE <= 0; 
         rs2_addrE <= 0;
         rd_addrE <= 0;
      end
      else begin
         if (flushE) begin
            rd_wr_enE <= 0;
            wb_selE <= 0;
            mem_wr_enE <= 0;
            data_modeE <= 0;
            alu_selE <= 0;
            b_selE <= 0;
            a_selE <= 0;
            br_unsignedE <= 0;
            instrE <= 0;
            pcE <= 0;
            rs1_dataE <= 0; 
            rs2_dataE <= 0;
            immE <= 0;
            pc4E <= 0;
            rs1_addrE <= 0; 
            rs2_addrE <= 0;
            rd_addrE <= 0;            
         end
         else begin
            rd_wr_enE <= rd_wr_enD;
            wb_selE <= wb_selD;
            mem_wr_enE <= mem_wr_enD;
            data_modeE <= data_modeD;
            alu_selE <= alu_selD;
            b_selE <= b_selD;
            a_selE <= a_selD;
            br_unsignedE <= br_unsignedD;
            instrE <= instrD;
            pcE <= pcD;
            rs1_dataE <= rs1_dataD; 
            rs2_dataE <= rs2_dataD;
            immE <= immD;
            pc4E <= pc4D;
            rs1_addrE <= rs1_addrD; 
            rs2_addrE <= rs2_addrD;
            rd_addrE <= rd_addrD;
         end
      end
   end

endmodule