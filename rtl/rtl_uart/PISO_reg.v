module PISO_reg (
   input  wire       clk,
                     en,
                     shift_load,
   input  wire [7:0] parallel_in,
   output wire       serial_out     // LSB go first
);
   
   reg [7:0] shift_reg;
   assign serial_out = shift_reg[0]; 

   always @(posedge clk) begin
      if (en) begin
         if (~shift_load) begin
            shift_reg <= parallel_in;
         end
         else begin
            shift_reg  <= {1'b0,shift_reg[7:1]};
         end
      end
      else begin
         shift_reg  <= shift_reg;
      end
   end

endmodule
