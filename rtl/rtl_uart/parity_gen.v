module parity_gen (
   input  wire [7:0] tx_data,
   input  wire [1:0] WLS,
   input  wire       EPS,
   output wire       parity
);
   // EPS = 1 : even
   // EPS = 0 : odd
   
   reg  xor_all;

   always @(*) begin
      case (WLS)
         2'b00: xor_all = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4];
         2'b01: xor_all = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4]^tx_data[5];
         2'b10: xor_all = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4]^tx_data[5]^tx_data[6];
         2'b11: xor_all = tx_data[0]^tx_data[1]^tx_data[2]^tx_data[3]^tx_data[4]^tx_data[5]^tx_data[6]^tx_data[7];
         default: xor_all = 1'b0; 
      endcase
   end
   assign parity = EPS ? xor_all : ~xor_all; 

endmodule
