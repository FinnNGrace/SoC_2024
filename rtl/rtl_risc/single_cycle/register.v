module register #(
   parameter DATA_W = 32
)(
   input  wire                clk,
                              rst_n,
                              en,
                              syn_clr,     // synchronous clear
   input  wire [DATA_W-1:0]   data_in,
   output reg  [DATA_W-1:0]   data_out
);
   
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         data_out <= 0;
      end
      else begin
         if (syn_clr) begin
            data_out <= 0;
         end
         else begin
            if (en) begin
               data_out <= data_in;
            end
            else begin
               data_out <= data_in;
            end
         end
      end
   end

endmodule


// // In Altera devices, register signals have a set priority.
// // The HDL design should reflect this priority.
// always @ (negedge <reset> or posedge <asynch_load> or posedge <clock_signal>)
// begin
// 	// The asynchronous reset signal has highest priority
// 	if (!<reset>)
// 	begin
// 		<register_variable> <= 1'b0;
// 	end
// 	// Asynchronous load has next priority
// 	else if (<asynch_load>)
// 	begin
// 		<register_variable> <= <other_data>;
// 	end
// 	else
// 	begin
// 		// At a clock edge, if asynchronous signals have not taken priority,
// 		// respond to the appropriate synchronous signal.
// 		// Check for synchronous reset, then synchronous load.
// 		// If none of these takes precedence, update the register output 
// 		// to be the register input.
// 		if (<clock_enable>)
// 		begin
// 			if (!<synch_reset>)
// 			begin
// 				<register_variable> <= 1'b0;
// 			end
// 			else if (<synch_load>)
// 			begin
// 				<register_variable> <= <other_data>;
// 			end
// 			else
// 			begin
// 				<register_variable> <= <data>;
// 			end
// 		end
// 	end
// end


