module syn_fifo #(
   parameter WIDTH = 8,
   parameter DEPTH = 16,
   parameter ADDR_W = $clog2(DEPTH)
)(
   input  wire             clk,
                           rst_n,
   input  wire [WIDTH-1:0] w_data,
   output wire [WIDTH-1:0] r_data,
   input  wire             w_request,
                           r_request,
   output wire             full_status,
                           empty_status
);
   // length of ptr is ADDR_W + 1
   reg   [ADDR_W:0]  w_ptr,
                     r_ptr;
   wire  w_en,
         r_en;

   assign w_en = w_request & ~full_status;
   assign r_en = r_request & ~empty_status;

   dual_port_RAM #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
   ) u_dual_port_RAM (
      .clk           (clk              ),
      .w_data        (w_data           ),
      .r_data        (r_data           ),
      .w_en          (w_en             ),
      .r_en          (r_en             ),
      .w_addr        (w_ptr[ADDR_W-1:0]),
      .r_addr        (r_ptr[ADDR_W-1:0])
   );

   // write-pointer, read-pointer
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         w_ptr <= 0;
      end
      else begin
         if (w_request & !full_status)  begin
            w_ptr <= w_ptr + 1'b1;
         end
         else begin
            w_ptr <= w_ptr;
         end
      end
   end

   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         r_ptr <= 0;
      end
      else begin
         if (r_request & !empty_status)  begin
            r_ptr <= r_ptr + 1'b1;
         end
         else begin
            r_ptr <= r_ptr;
         end
      end
   end

   // full_status, empty_status
   assign empty_status  = (w_ptr == r_ptr);
   assign full_status   = (w_ptr[ADDR_W-1:0] == r_ptr[ADDR_W-1:0]) && (w_ptr[ADDR_W] != r_ptr[ADDR_W]);


endmodule
