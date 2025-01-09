`include "D:/Verilog_archived/02_CPU/03_FinnRISCV/rtl/cpu_def.vh"
`timescale 1ns/1ps

module imm_gen_tb ();

   reg  [31:0] instr;
   wire [31:0] imm;
   reg  [31:0] expected_imm;

   imm_gen u_imm_gen (
      .instr(instr),
      .imm  (imm  )
   );

   initial begin
      $display("================= MANUAL test =================");
         imm_gen_manual_check("1. lui x5, 4           ", 32'b00000000000000000100001010110111, 32'h4000);
         imm_gen_manual_check("2. auipc x6, 11        ", 32'b00000000000000001011001100010111, 32'hb000);
         imm_gen_manual_check("3. jal x10, 8          ", 32'b00000000100000000000010101101111, 32'd8);
         imm_gen_manual_check("4. jalr x3, 12(x6)     ", 32'b00000000110000110000000111100111, 32'd12);
         imm_gen_manual_check("5. beq x20, x19, 12    ", 32'b00000001001110100000011001100011, 32'd12);
         imm_gen_manual_check("6. bne x20, x19, 10    ", 32'b00000001001110100001010101100011, 32'd10);
         imm_gen_manual_check("7. blt x20, x19, 4     ", 32'b00000001001110100100001001100011, 32'd4);
         imm_gen_manual_check("8. bge x15, x19, 6     ", 32'b00000001001101111101001101100011, 32'd6);
         imm_gen_manual_check("9. bltu x3, x5, 8      ", 32'b00000000010100011110010001100011, 32'd8);
         imm_gen_manual_check("10. bgeu x15, x16, 1   ", 32'b00000001000001111111100001100011, 32'd16);
         imm_gen_manual_check("11. lb x5, 3(x2)       ", 32'b00000000001100010000001010000011, 32'd3);
         imm_gen_manual_check("12. lbu x6, 1(x15)     ", 32'b00000000000101111100001100000011, 32'd1);
         imm_gen_manual_check("13. lhu x6, 8(x15)     ", 32'b00000000100001111101001100000011, 32'd8);
         imm_gen_manual_check("14. sb x6, 36(x15)     ", 32'b00000010011001111000001000100011, 32'd36);
         imm_gen_manual_check("15. sh x6, 20(x15)     ", 32'b00000000011001111001101000100011, 32'd20);
         imm_gen_manual_check("16. lw x20, 0(x6)      ", 32'b00000000000000110010101000000011, 32'd0);
         imm_gen_manual_check("17. lh x6, 2(x15)      ", 32'b00000000001001111001001100000011, 32'd2);
         imm_gen_manual_check("18. sw x9, 4(x2)       ", 32'b00000000100100010010001000100011, 32'd4);
         imm_gen_manual_check("19. addi x26, x17, -5  ", 32'b11111111101110001000110100010011, 32'b11111111111111111111111111111011);
         imm_gen_manual_check("20. slti x26, x17, -5  ", 32'b11111111101110001010110100010011, 32'b11111111111111111111111111111011);
         imm_gen_manual_check("21. sltiu x26, x17, 5  ", 32'b00000000010110001011110100010011, 32'd5);
         imm_gen_manual_check("22. xori x5, x18, 9    ", 32'b00000000100110010100001010010011, 32'd9);
         imm_gen_manual_check("23. ori x5, x12, 11    ", 32'b00000000101101100110001010010011, 32'd11);
         imm_gen_manual_check("24. andi x5, x9, -3    ", 32'b11111111110101001111001010010011, 32'b11111111111111111111111111111101);
         imm_gen_manual_check("25. slli x5, x9, 6     ", 32'b000000000110_01001001001010010011, 32'd6);
         imm_gen_manual_check("26. srai x11, x10, 12  ", 32'b000000001100_01010_101_01011_0010011, 32'd12);
         imm_gen_manual_check("27. add x11, x10, x5   ", 32'b000000000101_01010000010110110011, 32'd0);
      
         $display("================= RANDOM test =================");
         imm_gen_random_test(100);

      $finish;
   end

   // first define your test case, then call this task
   task imm_gen_manual_check(
      input string case_name,
      input [31:0] test_instr,
      input [31:0] expected_imm
   );
      instr = test_instr;
      #1;
      if (imm === expected_imm) begin
         $display("[%s] | PASSED | instr = %b, imm = %b, expected_imm = %b", case_name, instr, imm, expected_imm);
      end else begin
         $display("[%s] | FAILED | instr = %b, imm = %b, expected_imm = %b", case_name, instr, imm, expected_imm);
      end
   endtask

   // random test, auto-compare test => but it's look weird
   task imm_gen_random_test (
      input integer tests_num
   );
      integer i;
      for (i = 0; i < tests_num; i = i + 1) begin
         instr = $random;
         case (instr[6:0])
            `I_TYPE_ARITH, `I_TYPE_LOAD, `I_TYPE_JALR:
               expected_imm = {{20{instr[31]}}, instr[31:20]};
            `S_TYPE:
               expected_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            `B_TYPE:
               expected_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            `U_TYPE_LUI, `U_TYPE_AUIPC:
               expected_imm = {instr[31:12], 12'b0};
            `J_TYPE:
               expected_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default:
               expected_imm = 32'b0; 
         endcase
         #1;
         if (imm === expected_imm) begin
            $display("random_case[%0d] | PASSED | instr = %b, imm = %b, expected_imm = %b", i, instr, imm, expected_imm);
         end 
         else begin
            $display("random_case[%0d] | FAILED | instr = %b, imm = %b, expected_imm = %b", i, instr, imm, expected_imm);
         end
      end
   endtask

   initial begin
      $dumpfile("imm_gen.vcd");
      $dumpvars(0, imm_gen_tb);
   end

endmodule