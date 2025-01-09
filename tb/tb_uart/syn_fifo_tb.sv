`timescale 1ns/1ps
// module syn_fifo_tb ();
//    localparam WIDTH = 8;
//    localparam DEPTH = 4;

//    localparam FREQ   = 50_000_000;
//    localparam PERIOD = 1_000_000_000/FREQ;
//    localparam HALF_PERIOD = PERIOD/2;
   
//    reg               clk,
//                      rst_n;
//    reg   [WIDTH-1:0] w_data;
//    reg               w_request,
//                      r_request;
//    wire  [WIDTH-1:0] r_data;
//    wire              full_status,
//                      empty_status;  

//    syn_fifo #(
//       .WIDTH(WIDTH),
//       .DEPTH(DEPTH)
//    ) u_syn_fifo (
//       .clk           (clk           ),
//       .rst_n         (rst_n         ),
//       .w_data        (w_data        ),
//       .r_data        (r_data        ),
//       .w_request     (w_request     ),
//       .r_request     (r_request     ),
//       .full_status   (full_status   ),
//       .empty_status  (empty_status  )
//    );

//    always #HALF_PERIOD clk = ~clk;


//    initial begin
//       clk = 0;
//       rst_n = 1;
//       #(2*PERIOD);
//       rst_n = 0;
//       #(2*PERIOD);
//       rst_n = 1;
//       #(18*PERIOD);
//       $finish;
//    end

//    initial begin
//       #(5*PERIOD);
//       w_data = 8'h00;
//       #(PERIOD);
//       w_data = 8'h01;
//       #(PERIOD);
//       w_data = 8'h02;
//       #(PERIOD);
//       w_data = 8'h03;
//       #(PERIOD);
//       w_data = 8'h04;
//       #(PERIOD);
//       w_data = 8'h05;
//       #(PERIOD);
//       w_data = 8'h06;
//       #(PERIOD);
//       w_data = 8'h07;
//       #(PERIOD);
//       w_data = 8'h08;
//       #(PERIOD);
//       w_data = 8'h09;
//       #(PERIOD);
//       w_data = 8'h0A;
//       #(PERIOD);
//       w_data = 8'h0B;
//       #(PERIOD);
//       w_data = 8'h0C;
//       #(5*PERIOD);
//    end

//    initial begin
//       w_request = 0;
//       #(5*PERIOD);
//       w_request = 1;
//       #(9*PERIOD);
//       w_request = 0;
//       #(8*PERIOD);
//    end

//    initial begin
//       r_request = 0;
//       #(7*PERIOD);
//       r_request = 1;
//       #(3*PERIOD);
//       r_request = 0;
//       #(5*PERIOD);
//       r_request = 1;
//       #(7*PERIOD);
//    end
   
//    initial begin
//       $dumpfile("syn_fifo.vcd");
//       $dumpvars(0, syn_fifo_tb);
//    end

// endmodule




module syn_fifo_tb ();
   localparam WIDTH = 8;
   localparam DEPTH = 4;

   localparam FREQ   = 50_000_000;
   localparam PERIOD = 1_000_000_000/FREQ;
   localparam HALF_PERIOD = PERIOD/2;

   reg               clk,
                     rst_n;
   reg   [WIDTH-1:0] w_data;
   reg               w_request,
                     r_request;
   wire  [WIDTH-1:0] r_data;
   wire              full_status,
                     empty_status;  

   syn_fifo #(
      .WIDTH(WIDTH),
      .DEPTH(DEPTH)
   ) u_syn_fifo (
      .clk           (clk           ),
      .rst_n         (rst_n         ),
      .w_data        (w_data        ),
      .r_data        (r_data        ),
      .w_request     (w_request     ),
      .r_request     (r_request     ),
      .full_status   (full_status   ),
      .empty_status  (empty_status  )
   );

   always #HALF_PERIOD clk = ~clk;


   initial begin
      clk = 1;
      rst_n = 1;
      #(2*PERIOD);
      rst_n = 0;
      #(2*PERIOD);
      rst_n = 1;
      #(18*PERIOD);
      $finish;
   end

   initial begin
      #(5*PERIOD);
      w_data <= 8'h00;
      #(PERIOD);
      w_data <= 8'h01;
      #(PERIOD);
      w_data <= 8'h02;
      #(PERIOD);
      w_data <= 8'h03;
      #(PERIOD);
      w_data <= 8'h04;
      #(PERIOD);
      w_data <= 8'h05;
      #(PERIOD);
      w_data <= 8'h06;
      #(PERIOD);
      w_data <= 8'h07;
      #(PERIOD);
      w_data <= 8'h08;
      #(PERIOD);
      w_data <= 8'h09;
      #(PERIOD);
      w_data <= 8'h0A;
      #(PERIOD);
      w_data <= 8'h0B;
      #(PERIOD);
      w_data <= 8'h0C;
      #(5*PERIOD);
   end

   initial begin
      w_request <= 0;
      #(5*PERIOD);
      w_request <= 1;
      #(9*PERIOD);
      w_request <= 0;
      #(8*PERIOD);
   end

   initial begin
      r_request <= 0;
      #(7*PERIOD);
      r_request <= 1;
      #(3*PERIOD);
      r_request <= 0;
      #(5*PERIOD);
      r_request <= 1;
      #(7*PERIOD);
   end

   initial begin
      $dumpfile("syn_fifo.vcd");
      $dumpvars(0, syn_fifo_tb);
   end

endmodule
