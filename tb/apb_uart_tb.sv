`timescale 1ns/1ns

module apb_uart_tb ();
   localparam FREQ         = 50_000_000;
   localparam PERIOD       = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD  = PERIOD / 2;

   integer     config_file, 
               tbr_file, 
               rbr_file;
   integer     i;   

   // Clock and Reset
   reg clk;
   reg rst_n;

   // APB slave
   reg         PENABLE;
   reg         PSEL;
   reg         PWRITE;
   reg  [31:0] PWDATA;
   reg  [31:0] PADDR;
   wire        PREADY;
   wire        PSLVERR;
   wire [31:0] PRDATA;

   // UART
   wire        UART_TX_O, UART_RX_I, 
               tx_fifo_empty, tx_fifo_full, rx_fifo_empty, rx_fifo_full;
   // UART inner register
   reg         OSM_SEL, BGE, PEN, EPS, STB;
   reg  [1:0]  WLS;
   wire [7:0]  DLH, DLL;
   reg  [7:0]  TBR_i;
   reg  [15:0] divisor;

   assign {DLH, DLL} = divisor;

   wire [7:0] MDR_val, DLL_val, DLH_val, LCR_val, IER_val;
   assign MDR_val = {7'b0, OSM_SEL};
   assign DLL_val = DLL;
   assign DLH_val = DLH;
   assign LCR_val = {2'b0, BGE, EPS, PEN, STB, WLS};
   assign IER_val = 8'b0000_1111;

   // DUT
   apb_uart u_apb_uart (
      .clk           (clk     ),
      .rst_n         (rst_n   ),
      .PENABLE       (PENABLE ),
      .PSEL          (PSEL    ),
      .PWRITE        (PWRITE  ),
      .PWDATA        (PWDATA  ),
      .PADDR         (PADDR   ),
      .PREADY        (PREADY  ),
      .PSLVERR       (PSLVERR ),
      .PRDATA        (PRDATA  ),
      .UART_TX_O     (UART_TX_O),
      .UART_RX_I     (UART_RX_I),
      .tx_fifo_empty (tx_fifo_empty ),
      .tx_fifo_full  (tx_fifo_full  ),
      .rx_fifo_empty (rx_fifo_empty ),
      .rx_fifo_full  (rx_fifo_full  )
   );

   always #HALF_PERIOD clk = ~clk;
   // back to back testing, evil testing
   assign UART_RX_I = UART_TX_O;
   
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

   task apb_uart_config (input integer n);
   begin
      @(posedge clk);

      BGE = 0;
      @(posedge clk);
      apb_write(3, LCR_val);

      config_file = $fopen($sformatf("../c_model/tx_config_%0d.txt", n), "r");
      if (config_file == 0) $error("Config file tx_config_%0d.txt was NOT opened successfully", n);
      $fscanf(config_file, "%b", WLS);
      $fscanf(config_file, "%b", PEN);
      $fscanf(config_file, "%b", EPS);
      $fscanf(config_file, "%b", STB);
      @(posedge clk);
      apb_write(3, LCR_val);
      $fclose(config_file);

      OSM_SEL = $urandom_range(0, 1);
      divisor = $urandom_range(27, 1603);
      @(posedge clk);
      apb_write(0, MDR_val);
      apb_write(2, DLH_val);
      apb_write(1, DLL_val);

      BGE = 1;
      @(posedge clk);
      apb_write(3,LCR_val);
      @(posedge clk);
      $display("config CMPL");
   end
   endtask

   int write_nums, read_nums, line_data;
   task apb_uart_write_read_line (input integer n);
      write_nums = 0; 
      read_nums = 0;
   begin
      @(posedge clk);
      tbr_file = $fopen($sformatf("../c_model/tx_data_%0d.txt", n), "r");
      if (tbr_file == 0) $error("Data file tx_data_%0d.txt was NOT opened successfully", n);
      if (tbr_file) begin
         while (!$feof(tbr_file)) begin
             void'($fscanf(tbr_file, "%b", line_data));
             write_nums++;
         end
      end
      $fclose(tbr_file);
      // magic
      @(negedge clk);
      @(posedge clk);
      tbr_file = $fopen($sformatf("../c_model/tx_data_%0d.txt", n), "r");
      if (tbr_file == 0) $error("Data file tx_data_%0d.txt was NOT opened successfully", n);
      rbr_file = $fopen($sformatf("../c_model/extracted_data_%0d.txt", n), "w");
      if (rbr_file == 0) $error("Output file extracted_data_%0d.txt was NOT created successfully", n);

      $fscanf(tbr_file, "%b", TBR_i);
      while (!$feof(tbr_file) || (read_nums < write_nums - 1)) begin
         // send a line by apb_write
         if (!tx_fifo_full) begin
            apb_write(6, TBR_i);
            $fscanf(tbr_file, "%b", TBR_i);
         end
         
         // receive a line by apb_read
         wait (!rx_fifo_empty) begin
            @(posedge clk);
            apb_read(7);      
            read_nums++;
            $fdisplay(rbr_file, "%b", PRDATA[7:0]);
         end
      end
      $fclose(tbr_file);
      $fclose(rbr_file);
      @(posedge clk);
      $display("transmit & receive line by line CMPL");
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

      // IRQs
      apb_write(4, IER_val);
      
      // back to back test
      for (i = 1; i <= 2000; i = i + 1) begin
         apb_uart_config(i);
         apb_uart_write_read_line(i);
         #(100000*PERIOD);
         $display("Test package %0d completed.", i);
      end
      $finish;
   end


endmodule
