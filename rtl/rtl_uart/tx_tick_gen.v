module tx_tick_gen (
   input  wire       clk,
                     rst_n,
                     en,
                     OSM_SEL,
   output wire       tx_tick
);
   reg         tx_tick_tmp;
   reg   [3:0] counter;
   wire  [3:0] counter_compare;

   assign counter_compare = OSM_SEL ? (13 - 1) : (16 - 1);

   always @(posedge clk, negedge rst_n) begin
      if(!rst_n) begin
         tx_tick_tmp <= 0;
         counter <= 0;
      end
      else begin
         if (en) begin
            if (counter == counter_compare) begin
               tx_tick_tmp <= 1;
               counter <= 0;
            end
            else begin
               tx_tick_tmp <= 0;
               counter <= counter + 1;
            end
         end
         else begin
            counter <= counter;
         end
      end
   end

   edge_detector u_edge_detector (
      .clk        (clk        ),
      .data_in    (tx_tick_tmp),
      .pulse_out  (tx_tick    )
   );

 endmodule
