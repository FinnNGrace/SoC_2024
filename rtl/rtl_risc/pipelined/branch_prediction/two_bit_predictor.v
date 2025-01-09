module two_bit_predictor (
   input  wire clk,
               rst_n,
               is_branch,
               prev_taken,
   output reg  predict_taken
);
   
   localparam STRONG_TAKEN = 2'b00;
   localparam WEAK_TAKEN   = 2'b01;
   localparam STRONG_NOT_TAKEN = 2'b10;
   localparam WEAK_NOT_TAKEN = 2'b11;

   reg [1:0] state, next_state;

   // input equation
   always @(*) begin
      case (state)
         STRONG_TAKEN:     next_state = prev_taken ? STRONG_TAKEN : WEAK_TAKEN;
         WEAK_TAKEN:       next_state = prev_taken ? STRONG_TAKEN : WEAK_NOT_TAKEN;
         WEAK_NOT_TAKEN:   next_state = prev_taken ? WEAK_TAKEN : STRONG_NOT_TAKEN;
         STRONG_NOT_TAKEN: next_state = prev_taken ? WEAK_NOT_TAKEN : STRONG_NOT_TAKEN;
         default: next_state = STRONG_NOT_TAKEN;
      endcase
   end

   // sequential logic
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         state <= STRONG_NOT_TAKEN;
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
         case (state)
         STRONG_TAKEN:     predict_taken = 1;
         WEAK_TAKEN:       predict_taken = 1;
         WEAK_NOT_TAKEN:   predict_taken = 0;
         STRONG_NOT_TAKEN: predict_taken = 0;
         default:          predict_taken = 0;
         endcase      
      end
      else begin
         predict_taken = 0;
      end
   end

endmodule