`timescale 1ns/1ps
`include "D:/Verilog_archived/02_CPU/03_FinnRISCV/rtl/cpu_def.vh"

module lsu_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   reg            clk,
                  rst_n,
                  w_en;
   reg   [31:0]   w_data,
                  r_data;
   reg   [15:0]   addr;
   reg   [2:0]    data_mode;
   reg   [31:0]   SW,
                  KEY;
   wire  [31:0]   LEDR,
                  LEDG,
                  HEX_H,
                  HEX_L,
                  LCD;

   lsu u_lsu (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .w_en       (w_en       ),
      .w_data     (w_data     ),
      .r_data     (r_data     ),
      .addr       (addr       ),
      .data_mode  (data_mode  ),
      .SW         (SW         ),
      .KEY        (KEY        ),
      .LEDR       (LEDR       ),
      .LEDG       (LEDG       ),
      .HEX_H      (HEX_H      ),
      .HEX_L      (HEX_L      ),
      .LCD        (LCD        )
   );

   always #HALF_PERIOD clk = ~clk;

   initial begin
      clk = 0;
      data_mode = `W;

      $display("================= INPUT PERI test =================");
         @(negedge clk);
         SW = $urandom_range(0, 2**32-1);
         KEY = $urandom_range(0, 2**32-1);
         @(negedge clk);
         check_write(`SW_addr, SW);
         check_write(`KEY_addr, KEY);
      
      $display("================= OUTPUT PERI test =================");
         write_random(`LEDG_addr);
         check_write(`LEDG_addr, w_data);
         $display("Output port LEDG = %h", r_data);

         write_random(`LEDR_addr);
         check_write(`LEDR_addr, w_data);
         $display("Output port LEDR = %h", r_data);
            
         write_random(`HEX_H_addr);
         check_write(`HEX_H_addr, w_data);
         $display("Output port HEX_H = %h", r_data);
            
         write_random(`HEX_L_addr);
         check_write(`HEX_L_addr, w_data);
         $display("Output port HEX_L = %h", r_data);
            
         write_random(`LCD_addr);
         check_write(`LCD_addr, w_data);
         $display("Output port LCD = %h", r_data);

      $display("================= DMEM test =================");
      for (integer i = 0; i < 2**11-1; i = i + 4) begin
         write_random(i);
         check_write(i, w_data);
      end

      $finish;
   end   

   task write_random (
      input  [15:0] addr_i
   );
      @(negedge clk);
      addr = addr_i;
      w_data = $urandom_range(0, 2**32-1);
      w_en = 1;
      @(negedge clk);
      w_en = 0;
      $display("Write to LSU[%h] = %h", addr, w_data);
   endtask

   task check_write (
      input  [15:0] addr_i,
      input  [31:0] data_check
   );
      @(negedge clk);
      addr = addr_i;
      @(negedge clk);
      if (data_check == r_data) begin
         $display("Read out LSU[%h] = %h \t >> \t PASSED", addr_i, r_data);      
      end
      else begin
         $display("Read out LSU[%h] = %h \t >> \t FAILED", addr_i, r_data);
      end
   endtask

   initial begin
      $dumpfile("lsu.vcd");
      $dumpvars(0, lsu_tb);
   end

endmodule