`timescale 1ns/1ps
`include "D:/Verilog_archived/02_CPU/03_FinnRISCV/rtl/cpu_def.vh"

module alu_tb;
	reg  signed [31:0] oprand_a, oprand_b;
	reg         [3:0]  alu_sel;
	wire        [31:0] alu_data;
	
	alu u_alu (
      .oprand_a   (oprand_a),
	   .oprand_b   (oprand_b),
	   .alu_sel     (alu_sel  ),
	   .alu_data   (alu_data)
	);
			
	initial begin
      alu_test(`ADD, "ADD", 20);
      alu_test(`SUB, "SUB", 20);
      alu_test(`SLT, "SLT", 100);
      alu_test(`SLTU, "SLTU", 100);
      alu_test(`XOR, "XOR", 20);
      alu_test(`OR, "OR", 20);
      alu_test(`AND, "AND", 20);
      alu_test(`SLL, "SLL", 5);
      alu_test(`SRL, "SRL", 5);
      alu_test(`SRA, "SRA", 5);
      alu_test(`LUI, "LUI", 5);
	end

   task alu_test (
      input [3:0] op_code,
      input string op_name,
      input integer tests_num
   ); 
      integer i;
      reg [31:0] expected_result;

      alu_sel = op_code;

      for (i = 0; i < tests_num; i = i + 1) begin
         oprand_a = $random;
         oprand_b = $random;
         case (alu_sel)
            `ADD: expected_result = oprand_a + oprand_b;
            `SUB: expected_result = oprand_a - oprand_b;
            `SLT: expected_result = (oprand_a < oprand_b) ? 1 : 0;
            `SLTU: expected_result = ($unsigned(oprand_a) < $unsigned(oprand_b)) ? 1 : 0;
            `XOR: expected_result = oprand_a ^ oprand_b;
            `OR: expected_result = oprand_a | oprand_b;
            `AND: expected_result = oprand_a & oprand_b;
            `SLL: expected_result = oprand_a << oprand_b[4:0];
            `SRL: expected_result = oprand_a >> oprand_b[4:0];
            `SRA: expected_result = oprand_a >>> oprand_b[4:0];
            `LUI: expected_result = oprand_b;
         endcase
         #1;
         if (alu_data == expected_result) begin
            $display("%s: a = %h, b = %h, alu_data = %h, expected_result = %h \t\t\t | PASSED",
                     op_name, oprand_a, oprand_b, alu_data, expected_result);
         end
         else begin
            $display("%s: a = %h, b = %h, alu_data = %h, expected_result = %h \t\t\t | FAILED",
                     op_name, oprand_a, oprand_b, alu_data, expected_result);
         end
      end
   endtask

   initial begin
      $dumpfile("alu.vcd");
      $dumpvars(0, alu_tb);
   end
	
endmodule