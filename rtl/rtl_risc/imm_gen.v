`include "cpu_def.vh"

module imm_gen (
   input  wire [31:0]   instr,
   output reg  [31:0]   imm
);

   always @(*) begin
      case(instr[6:0])
         `I_TYPE_ARITH, `I_TYPE_LOAD, `I_TYPE_JALR: 
            imm = {{20{instr[31]}}, instr[31:20]};
         `S_TYPE: 
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
         `B_TYPE: 
            imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
         `U_TYPE_LUI, `U_TYPE_AUIPC:
            imm = {{instr[31:12]}, 12'b0};
         `J_TYPE:
            imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
         default: 
            imm = 32'b0;
      endcase
   end

endmodule