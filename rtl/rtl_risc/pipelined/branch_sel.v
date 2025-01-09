`include "cpu_def.vh"

module branch_sel (
   input  wire          br_lessE,
                        br_equalE,
   input  wire [31:0]   instrE,
   output reg           br_selE
);
   wire [6:0] opcode;
   wire [2:0] funct3;
   wire [6:0] funct7;

   assign opcode = instrE[6:0];
   assign funct3 = instrE[14:12];
   assign funct7 = instrE[31:25];

   always @(*) begin
      case (opcode)
         `I_TYPE_JALR: begin
            br_selE = 1;
         end
         `J_TYPE: begin
            br_selE = 1;
         end
         `B_TYPE: begin
            case (funct3) 
               0: br_selE = br_equalE;
               1: br_selE = ~br_equalE;
               4: br_selE = br_lessE;
               5: br_selE = ~br_lessE;
               6: br_selE = br_lessE;
               7: br_selE = ~br_lessE;
               default: br_selE = 0;
            endcase
         end
         default: br_selE = 0;
      endcase
   end

endmodule