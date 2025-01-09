module concat_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;
   
   reg        clk;
   reg  [1:0] WLS;
   reg  [7:0] data_in;
   wire [7:0] data_out;

   concat u_concat(
      .WLS        (WLS     ),
      .data_in    (data_in ),
      .data_out   (data_out)
   );

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      while (1) begin
         @(posedge clk);
         WLS = $urandom_range(0, 3);
         data_in = $urandom_range(0, 255);
         #1;
         $display("WLS = %s | data_in = %b | data_out = %b", get_WLS(WLS), data_in, data_out); 
      end
   end
   
   initial #(1000*PERIOD) $finish;

   initial begin
      $dumpfile("concat.vcd");
      $dumpvars(0, concat_tb);
   end

   function [8*6:1] get_WLS;
      input [1:0] WLS;  
      case (WLS)
         2'b00: get_WLS = "5-bit";
         2'b01: get_WLS = "6-bit";
         2'b10: get_WLS = "7-bit";
         2'b11: get_WLS = "8-bit";
         default: get_WLS = "UNKOWN";  
      endcase
   endfunction
   
endmodule
