`timescale 1ns/1ps

module PISO_reg_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   reg            clk,
                  en,
                  shift_load;
   reg [7:0]      parallel_in;
   wire           serial_out;



   PISO_reg u_PISO_reg (
      .clk        (clk        ),
      .en         (en         ),
      .shift_load (shift_load ),
      .parallel_in(parallel_in),
      .serial_out (serial_out )
   );

   always #HALF_PERIOD clk = ~clk;
   
   initial begin
      clk = 0;
      en = 1;

      #(10*PERIOD);
      shift_load = 0;
      parallel_in = 8'b11001001;
      #(PERIOD);
      shift_load = 1;
      #(10*PERIOD);
      shift_load = 0;
      parallel_in = 8'b00001111;
      #(PERIOD);
      shift_load = 1;
      #(4*PERIOD);
      en = 0;
      #(5*PERIOD);
      $finish;
   end

   initial begin
      $dumpfile("PISO_reg.vcd");
      $dumpvars(0, PISO_reg_tb);
   end

endmodule
