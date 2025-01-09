// Author: Doan Dinh Nam
// Techniques: Hazard Detector + Forwading Unit + handle lw Hazard

`include "cpu_def.vh"

module pipelined_ver2 (
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
               br_selE, 
               stallF, stallD,
               flushD, flushE,
               br_unsignedD, br_unsignedE,
               mem_wr_enD, mem_wr_enE, mem_wr_enM,
               rd_wr_enD, rd_wr_enE, rd_wr_enM, rd_wr_enW,
               a_selD, a_selE,
               b_selD, b_selE,
               br_lessE, br_equalE;

   wire [1:0]  wb_selD, wb_selE, wb_selM, wb_selW,
               fwa_sel, fwb_sel;

   wire [2:0]  data_modeD, data_modeE, data_modeM;
   
   wire [3:0]  alu_selD, alu_selE;

   wire [4:0]  rs1_addrD, rs1_addrE,
               rs2_addrD, rs2_addrE,
               rd_addrD, rd_addrE, rd_addrM, rd_addrW;

   wire [31:0] nxt_pc,
               pcF, pcD, pcE,
               pc4F, pc4D, pc4E, pc4M, pc4W,
               alu_dataE, alu_dataM, alu_dataW,
               instrF, instrD, instrE,
               rs1_dataD, rs1_dataE,
               rs2_dataD, rs2_dataE,
               immD, immE,
               FW_bM,
               oprand_aE,
               oprand_bE,
               lsu_dataM, lsu_dataW,
               hexh_tmp, hexl_tmp;
	reg [31:0] 	FW_aE, FW_bE,
	            wb_data;
   assign rs1_addrD = instrD[19:15];
   assign rs2_addrD = instrD[24:20];
   assign rd_addrD = instrD[11:7];
   
   always @(posedge clk) begin
      pc_debug <= pcF;
      instr_vld <= instr_vld_tmp;
   end
   
   // assign nxt_pc = br_selE ? alu_dataE : pc4F;
   wire br_flush;
   branch_predictor u_branch_predictor (
      .clk(clk),
      .rst_n(rst_n),
      .pcF(pcF),
      .pc4F(pc4F),
      .pcD(pcD),
      .pcE(pcE),
      .pc4E(pc4E),
      .alu_dataE(alu_dataE),
      .instrF(instrF),
      .instrE(instrE),
      .br_selE(br_selE),
      .nxt_pc(nxt_pc),
      .br_flush(br_flush)
   );

   assign pc4F = pcF + 4;

   F_reg u_F_reg (
      .clk     (clk     ),
      .rst_n   (rst_n   ),
      .stallF  (stallF  ),
      .nxt_pc  (nxt_pc  ),
      .pcF     (pcF     )
   );

   imem u_imem (
      .r_addr  (pcF[12:0]  ),
      .r_data  (instrF     )
   );

   D_reg u_D_reg (
      .clk     (clk     ),
      .rst_n   (rst_n   ),
      .stallD  (stallD  ),
      .flushD  (flushD || br_flush),
      .pcF     (pcF     ),
      .instrF  (instrF  ),
      .pc4F    (pc4F    ),
      .pcD     (pcD     ),
      .instrD  (instrD  ),
      .pc4D    (pc4D    )
   );

   control_unit u_control_unit (
      .instr      (instrD        ),
      .br_less    (1'b0          ),
      .br_equal   (1'b0          ),
      .br_unsigned(br_unsignedD  ),
      .instr_vld  (instr_vld_tmp ),
      .mem_wr_en  (mem_wr_enD    ),
      .rd_wr_en   (rd_wr_enD     ),
      .pc_sel     (              ),
      .a_sel      (a_selD        ),
      .b_sel      (b_selD        ),
      .wb_sel     (wb_selD       ),
      .data_mode  (data_modeD    ),
      .alu_sel    (alu_selD      )
   );

   reg_file u_reg_file (
      .clk     (clk        ),
      .rst_n   (rst_n      ),
      .rd_wr_en(rd_wr_enW  ),
      .rs1_addr(rs1_addrD  ),
      .rs2_addr(rs2_addrD  ),
      .rd_addr (rd_addrW   ),
      .rs1_data(rs1_dataD  ),
      .rs2_data(rs2_dataD  ),
      .rd_data (wb_data    )
   );

   imm_gen u_imm_gen (
      .instr(instrD  ),
      .imm  (immD    )
   );

   E_reg u_E_reg (
      .clk           (clk           ),
      .rst_n         (rst_n         ),
      .flushE        (flushE || br_flush),

      .rd_wr_enD     (rd_wr_enD     ),
      .wb_selD       (wb_selD       ),
      .mem_wr_enD    (mem_wr_enD    ),
      .data_modeD    (data_modeD    ),
      .alu_selD      (alu_selD      ),
      .b_selD        (b_selD        ),
      .a_selD        (a_selD        ),
      .br_unsignedD  (br_unsignedD  ),
      .instrD        (instrD        ),
      .pcD           (pcD           ),
      .rs1_dataD     (rs1_dataD     ),
      .rs2_dataD     (rs2_dataD     ),
      .immD          (immD          ),
      .pc4D          (pc4D          ),
      .rs1_addrD     (rs1_addrD     ),
      .rs2_addrD     (rs2_addrD     ),
      .rd_addrD      (rd_addrD      ),

      .rd_wr_enE     (rd_wr_enE     ),
      .wb_selE       (wb_selE       ),
      .mem_wr_enE    (mem_wr_enE    ),
      .data_modeE    (data_modeE    ),
      .alu_selE      (alu_selE      ),
      .b_selE        (b_selE        ),
      .a_selE        (a_selE        ),
      .br_unsignedE  (br_unsignedE  ),
      .instrE        (instrE        ),
      .pcE           (pcE           ),
      .rs1_dataE     (rs1_dataE     ),
      .rs2_dataE     (rs2_dataE     ),
      .immE          (immE          ),
      .pc4E          (pc4E          ),
      .rs1_addrE     (rs1_addrE     ),
      .rs2_addrE     (rs2_addrE     ),
      .rd_addrE      (rd_addrE      )
   );

   always @(*) begin
      case (fwa_sel)
         0: FW_aE = rs1_dataE;
         1: FW_aE = alu_dataM;
         2: FW_aE = wb_data;
         default: FW_aE = 0;
      endcase
   end

   always @(*) begin
      case (fwb_sel)
         0: FW_bE = rs2_dataE;
         1: FW_bE = alu_dataM;
         2: FW_bE = wb_data;
         default: FW_bE = 0;
      endcase
   end

   assign oprand_aE = a_selE ? pcE : FW_aE;
   assign oprand_bE = b_selE ? immE : FW_bE;

   alu u_alu (
      .oprand_a(oprand_aE  ),
      .oprand_b(oprand_bE  ),
      .alu_sel (alu_selE   ),
      .alu_data(alu_dataE  )
   );

   branch_cmp u_branch_cmp (
      .a          (FW_aE         ),
      .b          (FW_bE         ),
      .br_unsigned(br_unsignedE  ),
      .br_less    (br_lessE      ),
      .br_equal   (br_equalE     )
   );

   branch_sel u_branch_sel (
      .br_lessE   (br_lessE   ),
      .br_equalE  (br_equalE  ),
      .instrE     (instrE     ),
      .br_selE    (br_selE    )
   );

   M_reg u_M_reg (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .rd_wr_enE  (rd_wr_enE  ),
      .wb_selE    (wb_selE    ),
      .mem_wr_enE (mem_wr_enE ),
      .data_modeE (data_modeE ),
      .alu_dataE  (alu_dataE  ),
      .FW_bE      (FW_bE      ),
      .pc4E       (pc4E       ),
      .rd_addrE   (rd_addrE   ),
      .rd_wr_enM  (rd_wr_enM  ),
      .wb_selM    (wb_selM    ),
      .mem_wr_enM (mem_wr_enM ),
      .data_modeM (data_modeM ),
      .alu_dataM  (alu_dataM  ),
      .FW_bM      (FW_bM      ),
      .pc4M       (pc4M       ),
      .rd_addrM   (rd_addrM   )
   );

   lsu u_lsu (
      .clk        (clk              ),
      .rst_n      (rst_n            ),
      .w_en       (mem_wr_enM       ),
      .w_data     (FW_bM            ),
      .r_data     (lsu_dataM        ),
      .addr       (alu_dataM[15:0]  ),
      .data_mode  (data_modeM       ),
      .SW         (sw               ),
      .KEY        ({{28{1'b0}}, btn}),
      .LEDR       (ledr             ),
      .LEDG       (ledg             ),
      .LCD        (lcd              ),
      .HEX_H      (hexh_tmp         ),
      .HEX_L      (hexl_tmp         ),
      .PREADY     (PREADY           ),
      .PSLVERR    (PSLVERR          ),
      .PRDATA     (PRDATA           ),
      .PSEL       (PSEL             ),
      .PENABLE    (PENABLE          ),
      .PADDR      (PADDR            ),
      .PWDATA     (PWDATA           ),
      .PWRITE     (PWRITE           )
   );
   
   assign hex7 = hexh_tmp[30:24];
   assign hex6 = hexh_tmp[22:16];
   assign hex5 = hexh_tmp[14:8];
   assign hex4 = hexh_tmp[6:0];
   assign hex3 = hexl_tmp[30:24];
   assign hex2 = hexl_tmp[22:16];
   assign hex1 = hexl_tmp[14:8];
   assign hex0 = hexl_tmp[6:0];

   W_reg u_W_reg (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .rd_wr_enM  (rd_wr_enM  ),
      .wb_selM    (wb_selM    ),
      .alu_dataM  (alu_dataM  ),
      .lsu_dataM  (lsu_dataM  ),
      .pc4M       (pc4M       ),
      .rd_addrM   (rd_addrM   ),
      .rd_wr_enW  (rd_wr_enW  ),
      .wb_selW    (wb_selW    ),
      .alu_dataW  (alu_dataW  ),
      .lsu_dataW   (lsu_dataW  ),
      .pc4W       (pc4W       ),
      .rd_addrW   (rd_addrW   )
   );

   always @(*) begin
      case (wb_selW)
         `WB_SEL_ALU: wb_data = alu_dataW;
         `WB_SEL_LSU: wb_data = lsu_dataW;
         `WB_SEL_PC4: wb_data = pc4W;
         default: wb_data = 0;
      endcase
   end

   hazard_unit u_hazard_unit (
      .rs1_addrD  (rs1_addrD  ),
      .rs2_addrD  (rs2_addrD  ),
      .rs1_addrE  (rs1_addrE  ),
      .rs2_addrE  (rs2_addrE  ),
      .rd_addrE   (rd_addrE   ),
      .rd_addrM   (rd_addrM   ),
      .rd_addrW   (rd_addrW   ),
      .rd_wr_enM  (rd_wr_enM  ),
      .rd_wr_enW  (rd_wr_enW  ),
      .br_selE    (br_selE    ),
      .wb_selE    (wb_selE    ),
      .stallF     (stallF     ),
      .stallD     (stallD     ),
      .flushD     (flushD     ),
      .flushE     (flushE     ),
      .fwa_sel    (fwa_sel    ),
      .fwb_sel    (fwb_sel    )
   );

endmodule