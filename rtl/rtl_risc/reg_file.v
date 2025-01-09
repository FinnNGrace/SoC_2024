module reg_file (
   input  wire          clk, 
                        rst_n,
                        rd_wr_en,
   input  wire [4:0]    rs1_addr, 
                        rs2_addr, 
                        rd_addr,
   input  wire [31:0]   rd_data,
   output wire [31:0]   rs1_data, 
                        rs2_data
);

   //x0-x31 32bits
   reg [31:0] REG [0:31];
   
   // seq write with negedge
   always @(negedge clk or negedge rst_n) begin
      if (!rst_n) begin
         REG[0]   <= 32'b0;
         REG[1]   <= 32'b0;
         REG[2]   <= 32'b0;
         REG[3]   <= 32'b0;
         REG[4]   <= 32'b0;
         REG[5]   <= 32'b0;
         REG[6]   <= 32'b0;
         REG[7]   <= 32'b0;
         REG[8]   <= 32'b0;
         REG[9]   <= 32'b0;
         REG[10]  <= 32'b0;
         REG[11]  <= 32'b0;
         REG[12]  <= 32'b0;
         REG[13]  <= 32'b0;
         REG[14]  <= 32'b0;
         REG[15]  <= 32'b0;
         REG[16]  <= 32'b0;
         REG[17]  <= 32'b0;
         REG[18]  <= 32'b0;
         REG[19]  <= 32'b0;
         REG[20]  <= 32'b0;
         REG[21]  <= 32'b0;
         REG[22]  <= 32'b0;
         REG[23]  <= 32'b0;
         REG[24]  <= 32'b0;
         REG[25]  <= 32'b0;
         REG[26]  <= 32'b0;
         REG[27]  <= 32'b0;
         REG[28]  <= 32'b0;
         REG[29]  <= 32'b0;
         REG[30]  <= 32'b0;
         REG[31]  <= 32'b0; 
      end
      else begin 
         if (rd_wr_en && rd_addr != 0) begin
            REG[rd_addr] <= rd_data;
         end
      end
   end

   // comb read
   assign rs1_data = REG[rs1_addr];            
   assign rs2_data = REG[rs2_addr];
   
endmodule