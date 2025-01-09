`include "cpu_def.vh"

module control_unit (
   input  wire [31:0]   instr,
   input  wire          br_less,
                        br_equal,
   output reg           br_unsigned,
                        instr_vld,
                        mem_wr_en,
                        rd_wr_en,
                        pc_sel,
                        a_sel,
                        b_sel,
   output reg  [1:0]    wb_sel,
   output reg  [2:0]    data_mode,
   output reg  [3:0]    alu_sel
);
   wire [6:0] opcode;
   wire [2:0] funct3;
   wire [6:0] funct7;

   assign opcode = instr[6:0];
   assign funct3 = instr[14:12];
   assign funct7 = instr[31:25];

   always @(*) begin
      case (opcode)
         `I_TYPE_ARITH: begin
            instr_vld = 1;
            pc_sel = 0;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 1;
            mem_wr_en = 0;
            data_mode = `W;
            wb_sel = `WB_SEL_ALU;
            case (funct3)
               0: alu_sel = `ADD;
               1: alu_sel = `SLL;
               2: alu_sel = `SLT;
               3: alu_sel = `SLTU;
               4: alu_sel = `XOR;
               5: alu_sel = ((funct7 == 7'h20) ? `SRA : `SRL);
               6: alu_sel = `OR;
               7: alu_sel = `AND;
               default: alu_sel = 0; 
            endcase
         end
         `I_TYPE_LOAD: begin
            instr_vld = 1;
            pc_sel = 0;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_LSU;
            case (funct3)
               0: data_mode = `B;
               1: data_mode = `H;
               2: data_mode = `W;
               4: data_mode = `BU;
               5: data_mode = `HU;
               default: data_mode = 0;
            endcase
         end
         `I_TYPE_JALR: begin
            instr_vld = 1;
            pc_sel = 1;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_PC4;
            data_mode = 0;
         end
         `R_TYPE: begin
            instr_vld = 1;
            pc_sel = 0;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 0;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_ALU;
            data_mode = 0;
            case (funct3)
               0: alu_sel = ((funct7 == 7'h20) ? `SUB : `ADD);
               1: alu_sel = `SLL;
               2: alu_sel = `SLT;
               3: alu_sel = `SLTU;
               4: alu_sel = `XOR;
               5: alu_sel = ((funct7 == 7'h20) ? `SRA : `SRL); 
               6: alu_sel = `OR;
               7: alu_sel = `AND;
               default: alu_sel = 0;
            endcase
         end
         `S_TYPE: begin
            instr_vld = 1;
            pc_sel = 0;
            rd_wr_en = 0;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 1;
            wb_sel = 0;
            case (funct3)
               0: data_mode = `B;
               1: data_mode = `H;
               2: data_mode = `W;
               default: data_mode = 0;
            endcase
         end
         `B_TYPE: begin
            instr_vld = 1;
            rd_wr_en = 0;
            a_sel = 1;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 0;
            wb_sel = 0;
            data_mode = 0;
            // pc_sel, br_unsigned
            case (funct3)
               0: begin
                  br_unsigned = 0;
                  pc_sel = br_equal;
               end
               1: begin
                  br_unsigned = 0;
                  pc_sel = ~br_equal;
               end
               4: begin
                  br_unsigned = 0;
                  pc_sel = br_less;
               end
               5: begin
                  br_unsigned = 0;
                  pc_sel = ~br_less;
               end
               6: begin
                  br_unsigned = 1;
                  pc_sel = br_less;
               end
               7: begin
                  br_unsigned = 1;
                  pc_sel = ~br_less;
               end
               default: begin
                  pc_sel = 0;
                  br_unsigned = 0;
               end
            endcase
         end
         `J_TYPE: begin
            instr_vld = 1;
            pc_sel = 1;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 1;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_PC4;
            data_mode = 0;
         end
         `U_TYPE_LUI: begin
            instr_vld = 1; 
            pc_sel = 0;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 1;
            alu_sel = `LUI;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_ALU;
            data_mode = 0;
         end
         `U_TYPE_AUIPC: begin
            instr_vld = 1;
            pc_sel = 0;
            rd_wr_en = 1;
            br_unsigned = 0;
            a_sel = 1;
            b_sel = 1;
            alu_sel = `ADD;
            mem_wr_en = 0;
            wb_sel = `WB_SEL_ALU;
            data_mode = 0;
         end
         default: begin
            instr_vld = 0;
            pc_sel = 0;
            rd_wr_en = 0;
            br_unsigned = 0;
            a_sel = 0;
            b_sel = 0;
            alu_sel = 0;
            mem_wr_en = 0;
            wb_sel = 0;
            data_mode = 0;
         end
      endcase
   end

endmodule