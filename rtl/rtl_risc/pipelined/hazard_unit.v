`include "cpu_def.vh"

module hazard_unit (
   input  wire [4:0] rs1_addrD, rs1_addrE,
                     rs2_addrD, rs2_addrE,
                     rd_addrE, rd_addrM, rd_addrW,
   input  wire       rd_wr_enM, rd_wr_enW,
                     br_selE, 
   input  wire [1:0] wb_selE,
   output reg        stallF, stallD,
                     flushD, flushE,
   output reg  [1:0] fwa_sel, fwb_sel
);

   wire lw_detect;

   // Pipeline hazards/Data hazard/RAW hazard
   // M stage have higher priority than W stage
   always @(*) begin
      if (rs1_addrE != 5'b0) begin
         if ((rs1_addrE == rd_addrM) && rd_wr_enM) begin
            fwa_sel = 1;
         end
         else begin
            if ((rs1_addrE == rd_addrW) && rd_wr_enW) begin
               fwa_sel = 2;
            end
            else begin
               fwa_sel = 0;
            end
         end
      end
      else begin
         fwa_sel = 0;
      end   
   end
   always @(*) begin
      if (rs2_addrE != 5'b0) begin
         if ((rs2_addrE == rd_addrM) && rd_wr_enM) begin
            fwb_sel = 1;
         end
         else begin
            if ((rs2_addrE == rd_addrW) && rd_wr_enW) begin
               fwb_sel = 2;
            end
            else begin
               fwb_sel = 0;
            end
         end
      end
      else begin
         fwb_sel = 0;
      end   
   end

   // Pipeline hazards/Data hazard/RAW hazard - lw hazard
   // lw detector
   assign lw_detect = (wb_selE == `WB_SEL_LSU) && ((rd_addrE == rs1_addrD)||(rd_addrE == rs2_addrD));

   // Stall to solve lw hazard
   always @(*) begin
      stallF = lw_detect;
      stallD = lw_detect; 
   end

   // Flush when a branch is taken or a load introduces a bubble
   always @(*) begin
      flushD = br_selE;
      flushE = br_selE || lw_detect;
   end

endmodule   