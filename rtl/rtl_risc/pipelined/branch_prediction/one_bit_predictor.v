module one_bit_predictor (
   input  wire clk,
               rst_n,
               is_branch,
               prev_taken,
   output reg  predict_taken
);

   localparam TAKEN = 1'b1;
   localparam NOT_TAKEN = 1'b0;

   reg state, next_state;

   // input equation
   always @(*) begin
      case (state)
         TAKEN:      next_state = prev_taken ? TAKEN : NOT_TAKEN;
         NOT_TAKEN:  next_state = prev_taken ? TAKEN : NOT_TAKEN;
         default:    next_state = NOT_TAKEN;
      endcase
   end

   // sequential logic
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         state <= NOT_TAKEN;
      end
      else begin
         if (is_branch) begin
            state <= next_state;
         end
      end
   end

   // output equation
   always @(*) begin
      if (is_branch) begin
         predict_taken = state;
      end
      else begin
         predict_taken = 0;
      end
   end

endmodule


