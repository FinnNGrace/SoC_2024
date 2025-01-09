module rx_tick_gen (
   input  wire    clk,
                  rst_n,
                  en,
                  OSM_SEL,
                  syn_clr,
   output wire    rx_tick
);
   reg         rx_tick_tmp;
   reg   [3:0] counter;
   wire  [3:0] counter_compare;
   wire  [3:0] counter_max;

   assign counter_compare = OSM_SEL ? (7 - 1) : (8 - 1);
   assign counter_max     = OSM_SEL ? (13 - 1) : (16 - 1);

   // always @(posedge clk, negedge rst_n) begin
   //    if (!rst_n | syn_clr) begin
   //       rx_tick_tmp <= 0;
   //       counter <= 0;
   //    end
   //    else begin
   //       if (en) begin
   //          if (counter == counter_compare) begin
   //             rx_tick_tmp <= 1;
   //             counter <= counter + 1;
   //          end
   //          else begin
   //             if (counter == counter_max) begin
   //                rx_tick_tmp <= 0;
   //                counter <= 0;
   //             end
   //             else begin
   //                rx_tick_tmp <= 0;
   //                counter <= counter + 1;
   //             end
   //          end
   //       end
   //       else begin
   //          counter <= counter;
   //       end
   //    end
   // end

   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         rx_tick_tmp <= 0;
         counter <= 0;
      end
      else begin
         if (syn_clr) begin
            rx_tick_tmp <= 0;
            counter <= 0;
         end
         else begin
            if (en) begin
               if (counter == counter_compare) begin
                  rx_tick_tmp <= 1;
                  counter <= counter + 1;
               end
               else begin
                  if (counter == counter_max) begin
                     rx_tick_tmp <= 0;
                     counter <= 0;
                  end
                  else begin
                     rx_tick_tmp <= 0;
                     counter <= counter + 1;
                  end
               end
            end
            else begin
               counter <= counter;
            end            
         end
      end
   end

   edge_detector u_edge_detector (
      .clk        (clk        ),
      .data_in    (rx_tick_tmp),
      .pulse_out  (rx_tick    )
   );   

endmodule
