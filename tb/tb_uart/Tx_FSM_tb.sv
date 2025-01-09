`timescale 1ns/1ns

module Tx_FSM_tb ();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;

   localparam [15:0] divisor = 5;
   localparam [0:0]  OSM_SEL = 0;
   localparam [0:0]  BGE     = 1;
 

   reg         clk,
               rst_n,
               data_done,
               PEN, STB,
               tx_empty_status;
   wire        syn_clr,
               shift_load,
               tx_done;
   wire [1:0]  tx_control;

   wire        baud_clk,
               tx_tick;

   integer     random;
   
   wire [7:0]  DLL, DLH;

   assign {DLH, DLL} = divisor;

   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (BGE     ),
      .DLL        (DLL     ),
      .DLH        (DLH     ),
      .baud_clk   (baud_clk)
   );

   tx_tick_gen u_tx_tick_gen (
      .clk        (clk           ),
      .rst_n      (rst_n         ),
      .en         (baud_clk & BGE),
      .OSM_SEL    (OSM_SEL       ),
      .tx_tick    (tx_tick       )
   );

   Tx_FSM u_Tx_FSM (
      .clk              (clk              ),
      .rst_n            (rst_n            ),
      .tx_tick          (tx_tick          ),
      .data_done        (data_done        ),
      .PEN              (PEN              ),
      .STB              (STB              ),
      .tx_empty_status  (tx_empty_status  ),
      .syn_clr          (syn_clr          ),
      .shift_load       (shift_load       ),
      .tx_done          (tx_done          ),
      .tx_control       (tx_control       )
   );

   always #HALF_PERIOD clk = ~clk;
   
   initial begin
      {data_done,PEN,STB,tx_empty_status} = 4'b0000;
      random = 0;
      while (1) begin
         @(posedge tx_tick);
         random = $urandom_range(0, 15);
         {data_done,PEN,STB,tx_empty_status} = random;
      end
   end

   initial begin
      clk = 0;
      rst_n = 0;
      #(2*PERIOD);
      rst_n = 1;
      #(10000*PERIOD);
      $finish;
   end

   // display to debug
   initial begin
      while (1) begin
         @(posedge tx_tick);
         $display("Time = %7t | tx_empty_status=%b, data_done=%b, PEN=%b, STB=%b | state=%s | next_state=%s | tx_done=%b, tx_control=%b, syn_clr=%b, shift_load=%b",
                  $time, tx_empty_status, data_done, PEN, STB, get_state_name(u_Tx_FSM.state), get_state_name(u_Tx_FSM.next_state), tx_done, tx_control, syn_clr, shift_load);
      end
   end

   initial begin
      $dumpfile("Tx_FSM.vcd");
      $dumpvars(0, Tx_FSM_tb);
   end
   
   // get state name function
   function [8*6:1] get_state_name;
         input  [2:0] state;
         begin
            case (state)
               3'b000:  get_state_name = "IDLE"; 
               3'b001:  get_state_name = "START";
               3'b010:  get_state_name = "DATA";
               3'b011:  get_state_name = "PARITY";
               3'b100:  get_state_name = "STOP1";
               3'b101:  get_state_name = "STOP2";
               default: get_state_name = "UNKNOWN";
            endcase
         end
   endfunction


endmodule

