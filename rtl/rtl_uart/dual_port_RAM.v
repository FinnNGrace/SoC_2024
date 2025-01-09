module dual_port_RAM #(
   parameter WIDTH = 8,
   parameter DEPTH = 4,
   parameter ADDR_W = $clog2(DEPTH)
)(
   input  wire                clk,
   input  wire [WIDTH-1:0]    w_data,
   output reg  [WIDTH-1:0]    r_data,
   input  wire                w_en,
                              r_en,
   input  wire [ADDR_W-1:0]   w_addr,
                              r_addr
);

   reg [WIDTH-1:0] RAM [0:DEPTH-1];

   always @(posedge clk) begin
      if (w_en) begin
         RAM[w_addr] <= w_data;
      end
      else begin
         RAM[w_addr] <= RAM[w_addr];
      end
   end
   always @(posedge clk) begin
      if (r_en) begin
         r_data <= RAM[r_addr];
      end
      else begin
         r_data <= r_data;
      end
   end
endmodule