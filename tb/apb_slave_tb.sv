`timescale 1ns/1ps

module apb_slave_tb ();
   // Clock generation
   localparam FREQ         = 50_000_000;
   localparam PERIOD       = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD  = PERIOD / 2;   

  // Clock and Reset
   reg clk;
   reg rst_n;
 
   // APB interface signals
   reg         PENABLE;
   reg         PSEL;
   reg         PWRITE;
   reg  [31:0] PWDATA;
   reg  [31:0] PADDR;
   wire        PREADY;
   wire        PSLVERR;
   wire [31:0] PRDATA;

   apb_slave u_apb_slave (
      .clk     (clk),
      .rst_n   (rst_n),
      .PENABLE (PENABLE),
      .PSEL    (PSEL),
      .PWRITE  (PWRITE),
      .PWDATA  (PWDATA),
      .PADDR   (PADDR),
      .PREADY  (PREADY),
      .PSLVERR (PSLVERR),
      .PRDATA  (PRDATA),
      .FSR     (8'b0), 
      .RBR     (8'b0), 
      .MDR(), .DLL(), .DLH(), .LCR(), .IER(), .TBR(), .tx_flag(), .rx_flag()
   );

   always #HALF_PERIOD clk = ~clk;

   // Task to perform APB write
   task apb_write (
      input [31:0] addr,
      input [31:0] data
   );
   begin
      @(posedge clk);
      PADDR = addr;
      PWDATA = data;
      PWRITE = 1;
      PENABLE = 0;

      @(posedge clk);
      PENABLE = 1;

      @(posedge clk);
      while (!PREADY) begin
        @(posedge clk);
      end

      PENABLE = 0;
   end
   endtask   

     // Task to perform APB read
   task apb_read (
      input  [31:0] addr
   );
   begin   
      @(posedge clk);
      PADDR = addr;
      PWRITE = 0;
      PENABLE = 0;

      @(posedge clk);
      PENABLE = 1;

      @(posedge clk);
      while (!PREADY) begin
         @(posedge clk);
      end

      PENABLE = 0;
   end
   endtask

   initial begin
      clk = 0;
      rst_n = 0;
      PENABLE = 0;
      PSEL = 1;
      PWRITE = 0;
      PWDATA = 0;
      PADDR = 0;

      @(posedge clk);
      rst_n = 1;

      // Write to address 0x01
      $display("APB Write: Address = 0x01, Data = 0x78");
      apb_write(32'h01, 32'h78);

      // Write to address 0x02
      $display("APB Write: Address = 0x02, Data = 0x21");
      apb_write(32'h02, 32'h21);

      // Read from address 0x01
      $display("APB Read: Address = 0x01");
      apb_read(32'h01);
      $display("PRDATA = 0x%h", PRDATA);

      // Read from address 0x02
      $display("APB Read: Address = 0x02");
      apb_read(32'h02);
      $display("PRDATA = 0x%h", PRDATA);

      // Read from an invalid address 0x10
      $display("APB Read: Invalid Address = 0x10");
      apb_read(32'h10);
      $display("PRDATA = 0x%h", PRDATA);

      $finish;
   end
endmodule