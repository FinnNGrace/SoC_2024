`timescale  1ns/1ns

module UART_IP_full_random_tb ();
   // parameter CONFIG_PATH_BASE    = "./../c_model/tx_config_";
   // parameter TBR_PATH_BASE       = "./../c_model/tx_data_";
   // parameter RBR_PATH_BASE       = "./../c_model/extracted_data_";
   event      event_a;

   localparam FREQ         = 50_000_000;
   localparam PERIOD       = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD  = PERIOD / 2;

   integer     config_file, 
               tbr_file, 
               rbr_file;
   integer     i;

   reg         clk, 
               rst_n;
   reg  [15:0] divisor;
   reg         OSM_SEL, BGE, PEN, EPS, STB, tx_flag, rx_flag;
   reg  [1:0]  WLS;
   reg         en_tx_fifo_empty, en_tx_fifo_full, en_rx_fifo_empty, en_rx_fifo_full;
   reg  [7:0]  TBR_i, RBR_o;

   wire        baud_clk, UART_TX_O, UART_RX_I, tx_fifo_empty, tx_fifo_full, rx_fifo_empty, rx_fifo_full;
   wire [7:0]  DLH, DLL;
   wire [7:0]  FSR_o;

   assign {DLH, DLL} = divisor;

   UART_IP u_UART_IP (
      .clk              (clk              ),
      .rst_n            (rst_n            ),
      .en_tx_fifo_empty (en_tx_fifo_empty ),
      .en_tx_fifo_full  (en_tx_fifo_full  ),
      .en_rx_fifo_empty (en_rx_fifo_empty ),
      .en_rx_fifo_full  (en_rx_fifo_full  ),
      .tx_flag          (tx_flag          ),
      .rx_flag          (rx_flag          ),
      .PEN              (PEN              ),
      .EPS              (EPS              ),
      .STB              (STB              ),
      .BGE              (BGE              ),
      .OSM_SEL          (OSM_SEL          ),
      .WLS              (WLS              ),
      .TBR_i            (TBR_i            ),
      .DLH              (DLH              ),
      .DLL              (DLL              ),
      .UART_RX_I        (UART_RX_I        ),
      .UART_TX_O        (UART_TX_O        ),
      .RBR_o            (RBR_o            ),
      .tx_fifo_empty    (tx_fifo_empty    ),
      .tx_fifo_full     (tx_fifo_full     ),
      .rx_fifo_empty    (rx_fifo_empty    ),
      .rx_fifo_full     (rx_fifo_full     ),
      .FSR_o            (FSR_o            )
   );

   always #HALF_PERIOD clk = ~clk;
   // back to back testing, evil testing
   assign UART_RX_I = UART_TX_O;

   // UART Configuration
   task uart_config_task(input integer n);
      begin
         BGE = 0;
         #(10*PERIOD);
         config_file = $fopen($sformatf("../c_model/tx_config_%0d.txt", n), "r");
         if (config_file == 0) $error("Config file tx_config_%0d.txt was NOT opened successfully", n);
         #1;
         $fscanf(config_file, "%b", WLS);
         $fscanf(config_file, "%b", PEN);
         $fscanf(config_file, "%b", EPS);
         $fscanf(config_file, "%b", STB);
         #1;
         $fclose(config_file);
         #1;
         OSM_SEL = $urandom_range(0, 1);
         divisor = $urandom_range(27, 1603);
         BGE = 1;
         $display("config CMPL");
      end
   endtask

   // UART Transmission
   task uart_transmit_task(input integer n);
      begin
         #(400 * PERIOD);
         tbr_file = $fopen($sformatf("../c_model/tx_data_%0d.txt", n), "r");
         if (tbr_file == 0) $error("Data file tx_data_%0d.txt was NOT opened successfully", n);
         $fscanf(tbr_file, "%b", TBR_i);
         while (!$feof(tbr_file)) begin
            if (!tx_fifo_full) begin
               @(posedge clk);
               tx_flag = 1;
               @(negedge clk);
               tx_flag = 0;
               $fscanf(tbr_file, "%b", TBR_i);
            end else begin
               @(negedge clk);
               TBR_i = TBR_i;
               tx_flag = 0;
            end
         end
         $display("transmit CMPL");
         #(PERIOD * divisor * 16 * 12  * 2 * 16);
         -> event_a;
         $fclose(tbr_file);
      end
   endtask

   // UART Reception
   task uart_receive_task(input integer n);
      begin
         rbr_file = $fopen($sformatf("../c_model/extracted_data_%0d.txt", n), "w");
         if (rbr_file == 0) $error("Output file extracted_data_%0d.txt was NOT created successfully", n);
         while (!event_a.triggered) begin
            if (!rx_fifo_empty) begin
               @(posedge clk);
               rx_flag = 1;
               @(negedge clk);
               rx_flag = 0;
               $fdisplay(rbr_file, "%b", RBR_o);
            end else begin
               @(negedge clk);
               rx_flag = 0;
            end
         end
         $fclose(rbr_file);
         $display("receive CMPL");
      end
   endtask

   initial begin
      clk = 0;
      rst_n = 1;
      tx_flag = 0;
      rx_flag = 0;
      #(20 * PERIOD);
      rst_n = 0;
      #(200 * PERIOD);
      rst_n = 1;

      for (i = 1; i <= 100; i = i + 1) begin
         uart_config_task(i);
         fork
            uart_transmit_task(i);
            uart_receive_task(i);
         join
         #(100*PERIOD);
         $display("Test package %0d completed.", i);
      end
      $finish;
   end


endmodule
