module add_sub_comp #(
   parameter DATA_W = 4
)(
   input  wire [DATA_W-1:0]   oprand_A,
   input  wire [DATA_W-1:0]   oprand_B,
   input  wire                sub_sel,      // sub_sel = 1, then result = A - B
   input  wire                unsigned_sel,
   output wire [DATA_W-1:0]   result,
   output wire                less,         // less = 1 when A < B
   output wire                equal       
);

   wire  [DATA_W:0]  extended_A, 
                     extended_B, 
                     new_extended_B;

   // treat signed number or unsigned number as SIGNED NUMBER               
   assign extended_A     = unsigned_sel ? {1'b0, oprand_A} : {oprand_A[DATA_W-1], oprand_A};
   assign extended_B     = unsigned_sel ? {1'b0, oprand_B} : {oprand_B[DATA_W-1], oprand_B};
   assign new_extended_B = sub_sel      ? (~extended_B + 1'b1) : (extended_B);
  
   // less is sign_bit of a 2's complement number
   assign {less, result} = extended_A + new_extended_B;
   assign equal          = ~(less|(|result));

endmodule
