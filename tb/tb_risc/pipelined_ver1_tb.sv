`timescale 1ns/1ns

module pipelined_ver1_tb ();
   reg         clk,
               rst_n;
   reg  [31:0] sw;
   reg  [3:0]  btn;
   wire [31:0] pc_debug,
               ledr,
               ledg,
               lcd;
   wire  [6:0] hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7;
   wire        instr_vld;

   pipelined_ver1 u_pipelined_ver1 (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .sw         (sw         ),
      .btn        (btn        ),
      .pc_debug   (pc_debug   ),
      .instr_vld  (instr_vld  ),
      .ledr       (ledr       ),
      .ledg       (ledg       ),
      .lcd        (lcd        ),
      .hex0       (hex0       ),
      .hex1       (hex1       ),
      .hex2       (hex2       ),
      .hex3       (hex3       ),
      .hex4       (hex4       ),
      .hex5       (hex5       ),
      .hex6       (hex6       ),
      .hex7       (hex7       )
   );
   // period = 2ns
   always #1 clk = ~clk;

   initial begin
      clk = 0;
      rst_n = 0;
      #10
      rst_n = 1;
      sw = 32'd123456;
      sw = 32'd2;   
      
      #1000;
      //$finish;
   end

   // initial begin
   //    $dumpfile("pipelined_ver1.vcd");
   //    $dumpvars(0, pipelined_ver1_tb);
   // end

endmodule