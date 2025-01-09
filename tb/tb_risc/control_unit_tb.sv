`include "D:/Verilog_archived/02_CPU/03_FinnRISCV/rtl/cpu_def.vh"
`timescale 1ns/1ps

module control_unit_tb ();
   reg  [31:0] instr;
   reg         br_less,
               br_equal;
   wire        br_unsigned,
               mem_wr_en,
               rd_wr_en,
               pc_sel,
               a_sel,
               b_sel;
   wire [1:0]  wb_sel;
   wire [2:0]  data_mode;
   wire [3:0]  alu_sel;

   control_unit u_control_unit (
      // Input
      .instr      (instr   ),
      .br_less    (br_less ),
      .br_equal   (br_equal),
      // Output
      .br_unsigned(br_unsigned),
      .mem_wr_en  (mem_wr_en  ),
      .rd_wr_en   (rd_wr_en   ),
      .pc_sel     (pc_sel     ),
      .a_sel      (a_sel      ),
      .b_sel      (b_sel      ),
      .wb_sel     (wb_sel     ),
      .data_mode  (data_mode  ),
      .alu_sel    (alu_sel    ),
      .instr_vld  (           )
   );
   
   integer i;
   integer pass_nums = 0;
   integer log_file;

   wire [14:0] output_concat;
   reg  [14:0] output_exp;
   reg  [18:0] rand_input;

   assign output_concat = {pc_sel, rd_wr_en, br_unsigned, a_sel, b_sel, alu_sel, mem_wr_en, wb_sel, data_mode};
   assign instr[6:0]    = rand_input[18:12];    // op_code
   // assign instr[31:25]  = rand_input[11:5];     // funct7
   // assign instr[14:12]  = rand_input[4:2];      // funct3
   assign instr[14:12] = rand_input[11:9];      // funct3
   assign instr[31:25] = rand_input[8:2];       // funct7
   assign br_less       = rand_input[1];        // br_less
   assign br_equal      = rand_input[0];        // br_equal
   
   // DO NOT CHANGE cpu_def.vh
   always @(rand_input) begin
      casez (rand_input)
         19'b0110111_???_???????_?_?: begin output_exp = 15'b0_1_?_?_1_1011_0_01_???; $fwrite(log_file, "1. LUI:    "); end
         19'b0010111_???_???????_?_?: begin output_exp = 15'b0_1_?_1_1_0001_0_01_???; $fwrite(log_file, "2. AUIPC:  "); end
         19'b1101111_???_???????_?_?: begin output_exp = 15'b1_1_?_1_1_0001_0_11_???; $fwrite(log_file, "3. JAL:    "); end
         19'b1100111_000_???????_?_?: begin output_exp = 15'b1_1_?_0_1_0001_0_11_???; $fwrite(log_file, "4. JALR:   "); end
         19'b1100011_000_???????_?_1: begin output_exp = 15'b1_0_0_1_1_0001_0_??_???; $fwrite(log_file, "5. BEQ:    "); end
         19'b1100011_000_???????_?_0: begin output_exp = 15'b0_0_0_?_?_0001_0_??_???; $fwrite(log_file, "5. BEQ:    "); end
         19'b1100011_001_???????_?_0: begin output_exp = 15'b1_0_0_1_1_0001_0_??_???; $fwrite(log_file, "6. BNE:    "); end
         19'b1100011_001_???????_?_1: begin output_exp = 15'b0_0_0_?_?_0001_0_??_???; $fwrite(log_file, "6. BNE:    "); end
         19'b1100011_100_???????_1_?: begin output_exp = 15'b1_0_0_1_1_0001_0_??_???; $fwrite(log_file, "7. BLT:    "); end
         19'b1100011_100_???????_0_?: begin output_exp = 15'b0_0_0_?_?_0001_0_??_???; $fwrite(log_file, "7. BLT:    "); end
         19'b1100011_101_???????_0_1: begin output_exp = 15'b1_0_0_1_1_0001_0_??_???; $fwrite(log_file, "8. BGE:    "); end
         19'b1100011_101_???????_0_0: begin output_exp = 15'b1_0_0_1_1_0001_0_??_???; $fwrite(log_file, "8. BGE:    "); end
         19'b1100011_101_???????_1_?: begin output_exp = 15'b0_0_0_?_?_0001_0_??_???; $fwrite(log_file, "8. BGE:    "); end
         19'b1100011_110_???????_1_?: begin output_exp = 15'b1_0_1_1_1_0001_0_??_???; $fwrite(log_file, "9. BLTU:   "); end
         19'b1100011_110_???????_0_?: begin output_exp = 15'b0_0_1_?_?_0001_0_??_???; $fwrite(log_file, "9. BLTU:   "); end
         19'b1100011_111_???????_0_1: begin output_exp = 15'b1_0_1_1_1_0001_0_??_???; $fwrite(log_file, "10. BGEU:  "); end
         19'b1100011_111_???????_0_1: begin output_exp = 15'b1_0_1_1_1_0001_0_??_???; $fwrite(log_file, "10. BGEU:  "); end
         19'b1100011_111_???????_1_?: begin output_exp = 15'b0_0_1_?_?_0001_0_??_???; $fwrite(log_file, "10. BGEU:  "); end
         19'b0000011_000_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_10_001; $fwrite(log_file, "11. LB:    "); end
         19'b0000011_001_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_10_010; $fwrite(log_file, "12. LH:    "); end
         19'b0000011_100_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_10_100; $fwrite(log_file, "13. LBU:   "); end
         19'b0000011_101_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_10_101; $fwrite(log_file, "14. LHU:   "); end
         19'b0000011_010_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_10_011; $fwrite(log_file, "15. LW:    "); end
         19'b0100011_000_???????_?_?: begin output_exp = 15'b0_0_?_0_1_0001_1_??_001; $fwrite(log_file, "16. SB:    "); end
         19'b0100011_001_???????_?_?: begin output_exp = 15'b0_0_?_0_1_0001_1_??_010; $fwrite(log_file, "17. SH:    "); end
         19'b0100011_010_???????_?_?: begin output_exp = 15'b0_0_?_0_1_0001_1_??_011; $fwrite(log_file, "18. SW:    "); end
         19'b0010011_000_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0001_0_01_???; $fwrite(log_file, "19. ADDI:  "); end
         19'b0010011_010_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0011_0_01_???; $fwrite(log_file, "20. SLTI:  "); end
         19'b0010011_011_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0100_0_01_???; $fwrite(log_file, "21. SLTIU: "); end
         19'b0010011_100_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0101_0_01_???; $fwrite(log_file, "22. XORI:  "); end
         19'b0010011_110_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0110_0_01_???; $fwrite(log_file, "23. ORI:   "); end
         19'b0010011_111_???????_?_?: begin output_exp = 15'b0_1_?_0_1_0111_0_01_???; $fwrite(log_file, "24. ANDI:  "); end
         19'b0010011_001_0000000_?_?: begin output_exp = 15'b0_1_?_0_1_1000_0_01_???; $fwrite(log_file, "25. SLLI:  "); end
         19'b0010011_101_0000000_?_?: begin output_exp = 15'b0_1_?_0_1_1001_0_01_???; $fwrite(log_file, "26. SRLI:  "); end
         19'b0010011_101_0100000_?_?: begin output_exp = 15'b0_1_?_0_1_1010_0_01_???; $fwrite(log_file, "27. SRAI:  "); end
         19'b0110011_000_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0001_0_01_???; $fwrite(log_file, "28. ADD:   "); end
         19'b0110011_000_0100000_?_?: begin output_exp = 15'b0_1_?_0_0_0010_0_01_???; $fwrite(log_file, "29. SUB:   "); end
         19'b0110011_010_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0011_0_01_???; $fwrite(log_file, "30. SLT:   "); end
         19'b0110011_011_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0100_0_01_???; $fwrite(log_file, "31. SLTU:  "); end
         19'b0110011_100_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0101_0_01_???; $fwrite(log_file, "32. XOR:   "); end
         19'b0110011_110_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0110_0_01_???; $fwrite(log_file, "33. OR:    "); end
         19'b0110011_111_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_0111_0_01_???; $fwrite(log_file, "34. AND:   "); end
         19'b0110011_001_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_1000_0_01_???; $fwrite(log_file, "35. SLL:   "); end
         19'b0110011_101_0000000_?_?: begin output_exp = 15'b0_1_?_0_0_1001_0_01_???; $fwrite(log_file, "36. SRL:   "); end
         19'b0110011_101_0100000_?_?: begin output_exp = 15'b0_1_?_0_0_1010_0_01_???; $fwrite(log_file, "37. SRA:   "); end
         default: begin
            output_exp = 16'b?_?_?_?_?_????_?_??_???; 
            $fwrite(log_file, "Unsupported Instr ..."); 
         end
      endcase
   end

   initial begin
      log_file = $fopen("control_unit_log.txt", "w");

      for(i = 0; i < 2**19; i = i + 1) begin
         rand_input = i;
         #1;
         if (output_concat inside {output_exp}) begin
            $fdisplay(log_file, "PASSED");
            $fdisplay(log_file, "result = %b, expected = %b", output_concat, output_exp);
            pass_nums = pass_nums + 1;
         end
         else begin
            $fdisplay(log_file, "FAILED");
            $fdisplay(log_file, "result = %b, expected = %b", output_concat, output_exp);
         end
      end

      $display("Pass rate: %d/%d", pass_nums, 2**19);
      $fclose(log_file);
      $finish;
   end

   initial begin
      $dumpfile("control_unit.vcd");
      $dumpvars(0, control_unit_tb);
   end

endmodule