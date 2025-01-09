module UART_Tx(
   input  wire       clk,
                     rst_n,
                     tx_empty_status,
                     baud_clk,
                     PEN, EPS, STB, BGE,
                     OSM_SEL,
   input  wire [1:0] WLS,
   input  wire [7:0] tx_data,
   output wire       tx_done,
   output reg        UART_TX_O
);
   reg   [3:0] counter,
               counter_compare;
   wire        tx_tick,
               data_done,
               syn_clr,
               tx_done_tmp,
               shift_load,
               serial_out,
               parity;
   wire  [1:0] tx_control;

   tx_tick_gen u_tx_tick_gen (
      .clk              (clk           ),
      .rst_n            (rst_n         ),
      .en               (baud_clk & BGE),
      .OSM_SEL          (OSM_SEL       ),
      .tx_tick          (tx_tick       )
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
      .tx_done          (tx_done_tmp      ),
      .tx_control       (tx_control       )
   );

   edge_detector u_edge_detector (
      .clk        (clk        ),
      .data_in    (tx_done_tmp),
      .pulse_out  (tx_done    )
   );
   /*
   // DATA COUNTER
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n || ~syn_clr) begin
         counter <= 0;
      end
      else begin
         if (tx_tick) begin
            counter <= counter + 1;
         end
         else begin
            counter <= counter;
         end
      end
   end
   */
   
   // DATA COUNTER NEW
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         counter <= 0;
      end
      else begin
         if (~syn_clr) begin
            counter <= 0;
         end
         else begin
            if (tx_tick) begin
               counter <= counter + 1;
            end
            else begin
               counter <= counter;
            end
         end
      end
   end
   
   always @(*) begin
      case (WLS)
         2'b00: counter_compare = 5 - 1;    
         2'b01: counter_compare = 6 - 1;     
         2'b10: counter_compare = 7 - 1;    
         2'b11: counter_compare = 8 - 1; 
         default: counter_compare = 5 - 1;
      endcase
   end
   assign data_done = (counter == counter_compare);

   PISO_reg u_PISO_reg (
      .clk        (clk        ),
      .en         (tx_tick    ),
      .shift_load (shift_load ),
      .parallel_in(tx_data    ),
      .serial_out (serial_out )
   );

   parity_gen u_parity_gen (
      .tx_data (tx_data ),
      .WLS     (WLS     ),
      .EPS     (EPS     ),
      .parity  (parity  )
   );

   // MUX
   always @(*) begin
      case (tx_control)
         2'b00: UART_TX_O = 1'b0;
         2'b01: UART_TX_O = serial_out;
         2'b10: UART_TX_O = parity;
         2'b11: UART_TX_O = 1'b1;
      endcase
   end

endmodule
