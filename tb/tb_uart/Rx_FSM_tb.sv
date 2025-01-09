`timescale 1ns/1ns

module Rx_FSM_tb();
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;

   localparam [15:0] divisor = 5;
   localparam [0:0]  OSM_SEL = 0;
   localparam [0:0]  BGE     = 1;

   localparam BAUD_PERIOD = divisor * PERIOD;
   localparam RX_TICK_PERIOD = OSM_SEL ? 13*BAUD_PERIOD : 16*BAUD_PERIOD;

   reg         clk,
               rst_n,
               data_done,
               PEN, STB,
               UART_RX_I;
   wire        syn_clr,
               tick_clr,
               par_en,
               SIPO_en,
               rx_done;
   
   wire        baud_clk,
               rx_tick;

   wire [7:0]  DLH, DLL;

   assign {DLH, DLL} = divisor;

   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (BGE     ),
      .DLL        (DLL     ),
      .DLH        (DLH     ),
      .baud_clk   (baud_clk)
   );   
   rx_tick_gen u_rx_tick_gen (
      .clk        (clk           ),
      .rst_n      (rst_n         ),
      .en         (baud_clk & BGE),
      .OSM_SEL    (OSM_SEL       ),
      .syn_clr    (tick_clr      ),
      .rx_tick    (rx_tick       )
   );

   Rx_FSM u_Rx_FSM (
      .clk        (clk        ),
      .rst_n      (rst_n      ),
      .rx_tick    (rx_tick    ),
      .data_done  (data_done  ),
      .PEN        (PEN        ),
      .STB        (STB        ),
      .UART_RX_I  (UART_RX_I  ),
      .syn_clr    (syn_clr    ),
      .tick_clr   (tick_clr   ),
      .par_en     (par_en     ),
      .SIPO_en    (SIPO_en    ),
      .rx_done    (rx_done    )
   ); 
   
   always #HALF_PERIOD clk = ~clk;

   initial begin
      {data_done,PEN,STB,UART_RX_I} = 4'b0000;
      while (1) begin
         #RX_TICK_PERIOD;
         {data_done,PEN,STB,UART_RX_I} = $urandom_range(0, 15);
         // $display("Time = %7t | UART_RX_I=%b, data_done=%b, PEN=%b, STB=%b | state=%10s | next_state=%10s | rx_done=%b, syn_clr=%b, tick_clr=%b, par_en=%b, SIPO_en=%b",
         //         $time, UART_RX_I, data_done, PEN, STB, get_state_name(u_Rx_FSM.state), get_state_name(u_Rx_FSM.next_state), rx_done, syn_clr, tick_clr, par_en, SIPO_en);
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

   initial begin
      $dumpfile("Rx_FSM.vcd");
      $dumpvars(0, Rx_FSM_tb);
   end

   // get state name function
   function [8*10:1] get_state_name;
         input  [2:0] state;
         begin
            case (state)
               3'b000:  get_state_name = "GET_IDLE"; 
               3'b001:  get_state_name = "GET_START";
               3'b010:  get_state_name = "GET_DATA";
               3'b011:  get_state_name = "GET_PARITY";
               3'b100:  get_state_name = "GET_STOP1";
               3'b101:  get_state_name = "GET_STOP2";
               default: get_state_name = "UNKNOWN";
            endcase
         end
   endfunction

endmodule

