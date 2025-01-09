module branch_cmp (
   input  wire [31:0]   a,
                        b,
   input  wire          br_unsigned,
   output wire          br_less,
                        br_equal
);
   
   add_sub_comp #(
      .DATA_W (32)
   ) u_add_sub_comp (
      .oprand_A      (a          ),
      .oprand_B      (b          ),
      .sub_sel       (1'b1       ),
      .unsigned_sel  (br_unsigned),
      .result        (           ),
      .less          (br_less    ),
      .equal         (br_equal   )
   );

endmodule