module baud_generator (
   input  wire       clk,
                     rst_n,
                     en,
   input  wire [7:0] DLL,
                     DLH,
   output reg        baud_clk   
);

   wire  [15:0] divisor;
   reg   [15:0] counter;
   wire  [15:0] counter_compare;

   assign divisor = {DLH, DLL};
   assign counter_compare = divisor - 1;


   always @(posedge clk, negedge rst_n) begin
      if(!rst_n) begin
         baud_clk <= 0;
         counter <= 0;
      end
      else begin
         if (en) begin
            if (counter == counter_compare) begin
               baud_clk <= 1;
               counter <= 0;
            end
            else begin
               baud_clk <= 0;
               counter <= counter + 1;
            end
         end
         else begin
            counter <= counter;
         end
      end
   end




endmodule
