module UART_Rx (
   input  wire       clk,
                     baud_clk,
                     rst_n,
                     UART_RX_I,
                     PEN, STB, BGE,
                     OSM_SEL,
   input  wire [1:0] WLS,
   output wire       rx_done,
   output wire [7:0] rx_data
);
   reg   [3:0] counter,
               counter_compare;
   wire        syn_clr,
               rx_tick,
               rx_done_tmp,
               tick_clr,
               par_en,
               SIPO_en;
   wire  [7:0] rx_data_tmp;


   rx_tick_gen u_rx_tick_gen (
      .clk     (clk           ),
      .rst_n   (rst_n         ),
      .en      (baud_clk & BGE),
      .OSM_SEL (OSM_SEL       ),
      .syn_clr (tick_clr      ),
      .rx_tick (rx_tick       )
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
      .rx_done    (rx_done_tmp)   
   );

   edge_detector u_edge_detector (
      .clk        (clk        ),
      .data_in    (rx_done_tmp),
      .pulse_out  (rx_done    )
   );
   
   /*
   // DATA COUNTER
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n || ~syn_clr) begin
         counter <= 0;
      end
      else begin
         if (rx_tick) begin
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
            if (rx_tick) begin
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

   SIPO_reg u_SIPO_reg (
      .clk           (clk              ),
      .en            (rx_tick & SIPO_en),
      .serial_in     (UART_RX_I        ),
      .parallel_out  (rx_data_tmp      )
   );

   parity_store u_parity_store (
      .clk     (clk              ),
      .en      (rx_tick & par_en ),
      .data_in (UART_RX_I        ),
      .parity  (                 )
   );

   concat u_concat (
      .data_in    (rx_data_tmp),
      .WLS        (WLS        ),
      .data_out   (rx_data    )
   );

endmodule
