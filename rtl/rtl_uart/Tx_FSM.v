module Tx_FSM (
   input  wire       clk,
                     rst_n,
                     tx_tick,
                     data_done,
                     PEN, STB,
                     tx_empty_status,
   output reg        syn_clr,
                     shift_load,
                     tx_done,
   output reg  [1:0] tx_control
);
   
   reg  [2:0] state, next_state;

   // state assignment
   localparam IDLE   = 3'b000;
   localparam START  = 3'b001;
   localparam DATA   = 3'b010;
   localparam PARITY = 3'b011;
   localparam STOP1  = 3'b100;
   localparam STOP2  = 3'b101;

   // input equation
   always @(*) begin
      case (state) 
         IDLE:
            begin
               if (!tx_tick) begin
                  next_state = state;
               end
               else begin
                  if (!tx_empty_status) begin
                     next_state = START;
                  end
                  else begin
                     next_state = IDLE;
                  end
               end
            end
         START:
            begin
               if (!tx_tick) begin
                  next_state = state;
               end
               else begin
                  next_state = DATA;
               end
            end
         DATA:
            begin
               if (!tx_tick) begin
                  next_state = state;
               end
               else begin
                  if (!data_done) begin
                     next_state = state;
                  end
                  else begin
                     if (PEN) begin
                        next_state = PARITY;
                     end
                     else begin
                        next_state = STOP1;
                     end
                  end
               end
            end
         PARITY:
            begin
               if (!tx_tick) begin
                  next_state = PARITY;
               end
               else begin
                  next_state = STOP1;
               end
            end
         STOP1:
            begin
               if (!tx_tick) begin
                  next_state = STOP1;
               end
               else begin
                  if (STB) begin
                     next_state = STOP2;
                  end
                  else begin
                     if (tx_empty_status) begin
                        next_state = IDLE;
                     end
                     else begin
                        next_state = START;
                     end
                  end
               end
            end
         STOP2:
            begin
               if (!tx_tick) begin
                  next_state = STOP2;
               end 
               else begin
                  if (tx_empty_status) begin
                     next_state = IDLE;
                  end
                  else begin
                     next_state = START;
                  end
               end
            end
         default: next_state = IDLE;
      endcase
   end
   
   // sequential logic
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         state <= IDLE;
      end
      else begin
         state <= next_state;
      end
   end

   // output equation 
   always @(*) begin
      case (state)
         IDLE:   {tx_done, tx_control, syn_clr, shift_load} = 5'b01100;
         START:  {tx_done, tx_control, syn_clr, shift_load} = 5'b10000;
         DATA:   {tx_done, tx_control, syn_clr, shift_load} = 5'b00111;
         PARITY: {tx_done, tx_control, syn_clr, shift_load} = 5'b01000;
         STOP1:  {tx_done, tx_control, syn_clr, shift_load} = 5'b01100;
         STOP2:  {tx_done, tx_control, syn_clr, shift_load} = 5'b01100;
         default: {tx_done, tx_control, syn_clr, shift_load} = 5'b01100;
      endcase
   end

endmodule
