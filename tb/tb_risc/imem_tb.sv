`timescale 1ns/1ns

module imem_tb ();
   localparam addr_W_IMEM = 13;

   reg  [addr_W_IMEM-1:0]  r_addr;
   wire [31:0]             r_data  ;
   
   integer i;

   imem # (
      .ADDR_WIDTH(addr_W_IMEM)
   ) u_imem (
      .r_addr(r_addr),
      .r_data(r_data)
   );

   initial begin
      for (i = 0; i <= 400; i = i + 4) begin
         r_addr = i;
         #1;
         $display("IMEM[%h] = %h", r_addr, r_data);
      end
   end

   initial begin
      $dumpfile("imem.vcd");
      $dumpvars(0, imem_tb);
   end

endmodule