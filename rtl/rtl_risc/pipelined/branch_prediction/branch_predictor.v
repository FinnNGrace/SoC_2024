`include "cpu_def.vh"

module branch_predictor (
   input  wire          clk,
                        rst_n,
   input  wire [31:0]   pcF, pc4F, pcD, pcE, pc4E,
                        alu_dataE,
   input  wire [31:0]   instrF, instrE,
   input  wire          br_selE,
   output wire [31:0]   nxt_pc,
   output               br_flush
);
   wire [6:0]  opcodeE, opcodeF;
   wire [2:0]  funct3E, funct3F;
   wire [6:0]  funct7E, funct7F;

   wire        is_branchF, is_branchE,
               predict_taken,
               vld_o;
   wire [31:0] pc_target_o,
               expected_pc,
               nxt_pc_tmp;
   wire [19:0] tag_o;

   assign opcodeE = instrE[6:0];
   assign funct3E = instrE[14:12];
   assign funct7E = instrE[31:25];

   assign opcodeF = instrF[6:0];
   assign funct3F = instrF[14:12];
   assign funct7F = instrF[31:25];

   assign is_branchE = (opcodeE == `I_TYPE_JALR) || (opcodeE == `J_TYPE) || (opcodeE == `B_TYPE);
   assign is_branchF = (opcodeF == `I_TYPE_JALR) || (opcodeF == `J_TYPE) || (opcodeF == `B_TYPE);
   
   assign expected_pc = br_selE ? alu_dataE : pc4E;
   assign br_flush = is_branchE && (pcD != expected_pc);
   assign nxt_pc_tmp = ((pcF[31:12] == tag_o) && vld_o && predict_taken && is_branchF) ? pc_target_o : pc4F;
   assign nxt_pc   = br_flush ? expected_pc : nxt_pc_tmp;

   `ifdef ONE_BIT_PREDICTOR
      one_bit_predictor u_one_bit_predictor (
         .clk           (clk  ),
         .rst_n         (rst_n),
         .is_branch     (is_branchE),
         .prev_taken    (br_selE),
         .predict_taken (predict_taken)
      );
   `elsif TWO_BIT_PREDICTOR
      two_bit_predictor u_two_bit_predictor (
         .clk           (clk),
         .rst_n         (rst_n),
         .is_branch     (is_branchE),
         .prev_taken    (br_selE),
         .predict_taken (predict_taken)
      );
   `elsif STATIC_PREDICTOR
      assign predict_taken = is_branchE ? 1 : 0;
   `endif

   btb u_btb (
      .clk        (clk),
      .rst_n      (rst_n),
      .r_addr     (pcF[11:2]),
      .w_addr     (pcE[11:2]),
      .w_en       (is_branchE),
      .pc_target_i(alu_dataE),
      .tag_i      (pcE[31:12]),
      .pc_target_o(pc_target_o),
      .tag_o      (tag_o),
      .vld_o      (vld_o)
   );

endmodule
