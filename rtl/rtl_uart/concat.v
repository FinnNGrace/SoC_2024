module concat (
   input  wire [7:0] data_in,
   input  wire [1:0] WLS,
   output reg  [7:0] data_out
);

   always @(*) begin
      case (WLS)
         2'b00: data_out = {3'b000, data_in[7:3]};
         2'b01: data_out = {2'b00, data_in[7:2]};
         2'b10: data_out = {1'b0, data_in[7:1]};
         2'b11: data_out = data_in[7:0];
         default: data_out = 8'b0000_0000;
      endcase
   end

endmodule
