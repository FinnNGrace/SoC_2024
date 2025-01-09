module program_counter (
   input  wire          clk,
                        rst_n,
   input  wire [31:0]   nxt_pc,
   output wire [31:0]   pc
);

   register #(
      .DATA_W (32)
   ) u_register (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (1'b1    ),
      .syn_clr    (1'b0    ),
      .data_in    (nxt_pc  ),
      .data_out   (pc      )
   );

endmodule