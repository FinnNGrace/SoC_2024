`timescale 1ns/1ps

module add_sub_comb_tb ();
   localparam DATA_W = 4;

   // reg signed  [3:0] test;
   // reg         [3:0] unsigned_test;

   // initial begin
   //    test = 4'b1111;
   //    unsigned_test = test;
   //    $display("test[%b] = %d", test, test);
   //    $display("unsigned_test[%b] = %d", unsigned_test, unsigned_test);
   // end

   reg   [DATA_W-1:0]   oprand_A,
                        oprand_B;
   reg                  sub_sel,
                        unsigned_sel;
   wire  [DATA_W-1:0]   result;
   wire                 less,
                        equal; 

   integer i, j;

   add_sub_comp # (
      .DATA_W        (DATA_W     )
   ) u_add_sub_comp (
      .oprand_A      (oprand_A      ),
      .oprand_B      (oprand_B      ),
      .sub_sel       (sub_sel       ),
      .unsigned_sel  (unsigned_sel  ),
      .result        (result        ),
      .less          (less          ),
      .equal         (equal         )
   );
    
   initial begin
      for (i = 0; i < (1 << DATA_W); i = i + 1) begin
         for (j = 0; j < (1 << DATA_W); j = j + 1) begin
            $display("%0t", $time);
            unsigned_sel = 0;
            sub_sel = 0;
            oprand_A  = i;
            oprand_B  = j;
            #1;
            check_add();
            sub_sel = 1;
            #1;
            check_sub();
            check_equal();
            check_less();
            unsigned_sel = 1;
            #1;
            check_less_unsigned();
            $display("------------------------------------------------------------------------------");
         end
      end
      $finish;
   end

   task check_add ();
      reg [DATA_W-1:0] result_expected;   
      result_expected = oprand_A + oprand_B;  
      if (result == result_expected) begin
         $display("ADD: a = %b, b = %b, result = %b, expected_result = %b \t\t\t | PASSED", 
         oprand_A, oprand_B, result, result_expected);
      end
      else begin
         $display("ADD: a = %b, b = %b, result = %b, expected_result = %b \t\t\t | FAILED", 
         oprand_A, oprand_B, result, result_expected);      
      end    
   endtask

   task check_sub ();
      reg [DATA_W-1:0] result_expected; 
      result_expected = oprand_A - oprand_B; 
      if (result == result_expected) begin
         $display("SUB: a = %b, b = %b, result = %b, expected_result = %b \t\t\t | PASSED", 
         oprand_A, oprand_B, result, result_expected);
      end
      else begin
         $display("SUB: a = %b, b = %b, result = %b, expected_result = %b \t\t\t | FAILED", 
         oprand_A, oprand_B, result, result_expected);      
      end    
   endtask

   task check_equal ();
      reg equal_expected;  
      equal_expected = (oprand_A == oprand_B) ? 1 : 0; 
      if (equal == equal_expected) begin
         $display("CHECK_EQUAL : a = %b, b = %b, equal = %b, equal_expected = %b \t\t\t | PASSED",
         oprand_A, oprand_B, equal, equal_expected);
      end
      else begin
         $display("CHECK_EQUAL : a = %b, b = %b, equal = %b, equal_expected = %b \t\t\t | FAILED",
         oprand_A, oprand_B, equal, equal_expected);    
      end
   endtask   

   task check_less ();
      reg less_expected; 
      less_expected = ($signed(oprand_A) < $signed(oprand_B)) ? 1 : 0;
      if (less == less_expected) begin
         $display("CHECK_LESS  : a = %d, b = %d, less = %b, less_expected = %b \t\t\t | PASSED",
         $signed(oprand_A), $signed(oprand_B), less, less_expected);
      end
      else begin
         $display("CHECK_LESS  : a = %d, b = %d, less = %b, less_expected = %b \t\t\t | FAILED",
         $signed(oprand_A), $signed(oprand_B), less, less_expected);      
      end
   endtask

   task check_less_unsigned ();
      reg less_expected;    
      less_expected = (oprand_A < oprand_B) ? 1 : 0; 
      if (less == less_expected) begin
         $display("CHECK_LESS_U: a = %d, b = %d, less = %b, less_expected = %b \t\t\t | PASSED",
         oprand_A, oprand_B, less, less_expected);
      end
      else begin
         $display("CHECK_LESS_U: a = %d, b = %d, less = %b, less_expected = %b \t\t\t | FAILED",
         oprand_A, oprand_B, less, less_expected);      
      end
   endtask
   
   initial begin
      $dumpfile("add_sub_comb.vcd");
      $dumpvars(0, add_sub_comb_tb);
   end
endmodule