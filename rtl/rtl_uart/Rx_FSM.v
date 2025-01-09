module Rx_FSM (
   input  wire       clk,
                     rst_n,
                     rx_tick,
                     data_done,
                     PEN, STB,
                     UART_RX_I,
   output reg        syn_clr,
                     tick_clr,
                     par_en,
                     SIPO_en,
                     rx_done
);

   reg  [2:0] state, next_state;

   // state assignment
   localparam GET_IDLE     = 3'b000;
   localparam GET_START    = 3'b001;
   localparam GET_DATA     = 3'b010;
   localparam GET_PARITY   = 3'b011;
   localparam GET_STOP1    = 3'b100;
   localparam GET_STOP2    = 3'b101;

   // input equation
   always @(*) begin
      case (state)
         GET_IDLE:   next_state = UART_RX_I ? GET_IDLE : GET_START;
         GET_START:
            begin
               if (!rx_tick) begin
                  next_state = state;
               end
               else begin
                  next_state = GET_DATA;
               end
            end
         GET_DATA:
            begin
               if (!rx_tick || !data_done) begin
                  next_state = state;
               end
               else begin
                  if (PEN) begin
                     next_state = GET_PARITY;
                  end
                  else begin
                     if (STB) begin
                        next_state = GET_STOP1;
                     end
                     else begin
                        next_state = GET_STOP2;
                     end
                  end
               end
            end
         GET_PARITY:
            begin
               if (!rx_tick) begin
                  next_state = state;
               end
               else begin
                  if (STB) begin
                     next_state = GET_STOP1;
                  end
                  else begin
                     next_state = GET_STOP2;
                  end
               end
            end
         GET_STOP1:
            begin
               if (!rx_tick) begin
                  next_state = state;
               end
               else begin
                  next_state = GET_STOP2;
               end
            end
         GET_STOP2:
            begin
               if (!rx_tick) begin
                  next_state = state;
               end
               else begin
                  if (UART_RX_I) begin
                     next_state =  GET_IDLE;
                  end
                  else begin
                     next_state = GET_START;
                  end
               end
            end
         default: next_state = GET_IDLE;
      endcase
   end

   // sequential logic
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         state <= GET_IDLE;
      end
      else begin
         state <= next_state;
      end
   end

   // output equation
   always @(*) begin
      case (state)
         GET_IDLE:   {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b00001;
         GET_START:  {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b00000;
         GET_DATA:   {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b01100;
         GET_PARITY: {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b00010;
         GET_STOP1:  {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b00000;
         GET_STOP2:  {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b10000;
         default:    {rx_done, syn_clr, SIPO_en, par_en, tick_clr} = 5'b00001;
      endcase
   end

endmodule
