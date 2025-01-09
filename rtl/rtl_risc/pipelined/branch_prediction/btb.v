module btb (
   input  wire          clk,
                        rst_n,
   input  wire [9:0]    r_addr, w_addr,        // 10-bit index
   input  wire          w_en,

   input  wire [31:0]   pc_target_i,
   input  wire [19:0]   tag_i,                 // 20-bit tag

   output wire [31:0]   pc_target_o,
   output wire [19:0]   tag_o,
   output wire          vld_o

);
   // 51 = 1-bit vld + 20-bit tag + 30-bit target_PC
   reg [50:0] cache [0:1023];

   integer i;
   // write to cache
   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         for (i = 0; i < 1024; i = i + 1) begin
            cache[i][50] <= 0;         // system reset cache-valid bit
         end
      end
      else begin
         if (w_en) begin
            cache[w_addr] <= {1'b1, tag_i, pc_target_i[31:2]}; 
         end      
      end
   end   

   // read from cache
   assign {vld_o, tag_o, pc_target_o[31:2]} = cache[r_addr];
   assign pc_target_o[1:0] = 2'b00;

endmodule