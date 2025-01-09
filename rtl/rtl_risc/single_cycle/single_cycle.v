`include "cpu_def.vh"

module single_cycle (
   input  wire          clk,
                        rst_n,
   input  wire [31:0]   sw,
   input  wire [3:0]    btn,
   output reg  [31:0]   pc_debug,
   output reg           instr_vld,
   output wire [31:0]   ledr,
                        ledg,
                        lcd,
   output wire [6:0]    hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7,
   
   // APB master
   input  wire [31:0]   PREADY,
                        PSLVERR,
                        PRDATA,
   output wire [31:0]   PSEL,
                        PENABLE,
                        PADDR,
                        PWDATA,
                        PWRITE
); 
   wire        instr_vld_tmp,
               pc_sel,
               rd_wr_en,
               br_less,
               br_equal,
               br_unsigned,
               mem_wr_en,
               a_sel, b_sel;
   wire [1:0]  wb_sel;
   wire [2:0]  data_mode;
   wire [3:0]  alu_sel;
   wire [31:0] pc,
               pc4, 
               nxt_pc,
               instr,
               rs1_data, rs2_data,
               imm,
               oprand_a, oprand_b,
               lsu_data,
               hexh_tmp,
               hexl_tmp,
               alu_data;
   reg  [31:0] wb_data;
   // Tutor need this, so I write this
   always @(posedge clk) begin
      pc_debug <= pc;
      instr_vld <= instr_vld_tmp;
   end

   assign pc4 = pc + 4;
   assign nxt_pc = pc_sel ? alu_data : pc4;

   program_counter u_program_counter (
      .clk     (clk     ),
      .rst_n   (rst_n   ),
      .nxt_pc  (nxt_pc  ),
      .pc      (pc      )
   );

   imem u_imem (
      .r_addr  (pc[12:0]  ),
      .r_data  (instr     )
   );

   reg_file u_reg_file (
      .clk     (clk           ),
      .rst_n   (rst_n         ),
      .rd_wr_en(rd_wr_en      ),
      .rs1_addr(instr[19:15]  ),
      .rs2_addr(instr[24:20]  ),
      .rd_addr (instr[11:7]   ),
      .rd_data (wb_data       ),
      .rs1_data(rs1_data      ),
      .rs2_data(rs2_data      )
   );
   
   imm_gen u_imm_gen (
      .instr(instr),
      .imm  (imm  )
   );

   control_unit u_control_unit (
      .instr      (instr         ),
      .br_less    (br_less       ),
      .br_equal   (br_equal      ),
      .br_unsigned(br_unsigned   ),
      .instr_vld  (instr_vld_tmp ),
      .mem_wr_en  (mem_wr_en     ),
      .rd_wr_en   (rd_wr_en      ),
      .pc_sel     (pc_sel        ),
      .a_sel      (a_sel         ),
      .b_sel      (b_sel         ),
      .wb_sel     (wb_sel        ),
      .data_mode  (data_mode     ),
      .alu_sel    (alu_sel       )
   );

   branch_cmp u_branch_cmp (
      .a          (rs1_data   ),
      .b          (rs2_data   ),
      .br_unsigned(br_unsigned),
      .br_less    (br_less    ),
      .br_equal   (br_equal   )
   );

   assign oprand_a = a_sel ? pc : rs1_data;
   assign oprand_b = b_sel ? imm : rs2_data;

   alu u_alu (
      .oprand_a(oprand_a),
      .oprand_b(oprand_b),
      .alu_sel (alu_sel ),
      .alu_data(alu_data)
   );

   lsu u_lsu (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .w_en       (mem_wr_en  ),
      .w_data     (rs2_data   ),
      .r_data     (lsu_data   ),
      .addr       (alu_data[15:0]),
      .data_mode  (data_mode  ),
      .SW         (sw         ),
      .KEY        ({{28{1'b0}}, btn}),
      .LEDR       (ledr       ),
      .LEDG       (ledg       ),
      .LCD        (lcd        ),
      .HEX_H      (hexh_tmp   ),
      .HEX_L      (hexl_tmp   ),
      .PREADY     (PREADY     ),
      .PSLVERR    (PSLVERR    ),
      .PRDATA     (PRDATA     ),
      .PSEL       (PSEL       ),
      .PENABLE    (PENABLE    ),
      .PADDR      (PADDR      ),
      .PWDATA     (PWDATA     ),
      .PWRITE     (PWRITE     )
   );

   assign hex7 = hexh_tmp[30:24];
   assign hex6 = hexh_tmp[22:16];
   assign hex5 = hexh_tmp[14:8];
   assign hex4 = hexh_tmp[6:0];

   assign hex3 = hexl_tmp[30:24];
   assign hex2 = hexl_tmp[22:16];
   assign hex1 = hexl_tmp[14:8];
   assign hex0 = hexl_tmp[6:0];

   always @(*) begin
      case (wb_sel)
         `WB_SEL_ALU: wb_data = alu_data;
         `WB_SEL_LSU: wb_data = lsu_data;
         `WB_SEL_PC4: wb_data = pc4;
         default: wb_data = 0;
      endcase
   end

endmodule