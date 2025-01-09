`include "cpu_def.vh"

module alu (
   input  wire [31:0] oprand_a,
   input  wire [31:0] oprand_b,
   input  wire [3:0]  alu_sel,
   output reg  [31:0] alu_data
);
   
   wire [31:0] result;
   wire        sub_sel, 
               unsigned_sel,
               less;

   assign sub_sel       = (alu_sel == `SUB) | (alu_sel == `SLT) | (alu_sel == `SLTU);
   assign unsigned_sel  = (alu_sel == `SLTU);

   add_sub_comp #(
      .DATA_W (32)
   ) u_add_sub_comp (
      .oprand_A      (oprand_a      ),
      .oprand_B      (oprand_b      ),
      .sub_sel       (sub_sel       ),
      .unsigned_sel  (unsigned_sel  ),
      .result        (result        ),
      .less          (less          ),
      .equal         (              )
   );

   always @(*) begin
      case(alu_sel)
         `ADD  : alu_data = result;
         `SUB  : alu_data = result;
         `SLT  : alu_data = {31'b0, less};
         `SLTU : alu_data = {31'b0, less};
         `XOR  : alu_data = oprand_a ^ oprand_b;
         `OR   : alu_data = oprand_a | oprand_b;
         `AND  : alu_data = oprand_a & oprand_b;
         `SLL  : alu_data = oprand_a << oprand_b[4:0];
         `SRL  : alu_data = oprand_a >> oprand_b[4:0];
         //`SRA  : alu_data = (oprand_a >> oprand_b[4:0]) | ~(32'sd-1 >> (oprand_a[31] ? oprand_b[4:0] : 0));
         `SRA  : alu_data = oprand_a[31] ? ((oprand_a >> oprand_b[4:0]) | ~(32'hFFFF_FFFF >> oprand_b[4:0])) : (oprand_a >> oprand_b[4:0]);
         `LUI  : alu_data = oprand_b;
         default : alu_data = 32'b0;
      endcase
   end  
endmodule
