`timescale  1ns/1ns
// `define     CONFIG_PATH  "./../c_model/tx_config.txt"
// `define     TBR_PATH     "./../c_model/tx_data.txt"
// `define     RBR_PATH     "./../c_model/extracted_data.txt"


module UART_IP_random_tb ();
   parameter CONFIG_PATH    = "./../c_model/tx_config.txt";
   parameter TBR_PATH       = "./../c_model/tx_data.txt";
   parameter RBR_PATH       = "./../c_model/extracted_data.txt";
   
   localparam FREQ = 50_000_000;
   localparam PERIOD = 1_000_000_000 / FREQ;
   localparam HALF_PERIOD = PERIOD / 2;
   
   integer     config_file,
               tbr_file,
               rbr_file;

   reg         clk,
               rst_n;
   reg  [15:0] divisor;
   reg         OSM_SEL,
               BGE,
               PEN,
               EPS,
               STB,
               tx_flag,
               rx_flag;
   reg  [1:0]  WLS;
   reg         en_tx_fifo_empty,
               en_tx_fifo_full,
               en_rx_fifo_empty,
               en_rx_fifo_full;
   reg  [7:0]  TBR_i,
               RBR_o;

   wire        baud_clk,
               UART_TX_O,
               UART_RX_I,
               tx_fifo_empty,
               tx_fifo_full,
               rx_fifo_empty,
               rx_fifo_full;
   wire [7:0]  DLH, DLL;
   
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
      .rx_fifo_full     (rx_fifo_full     )
   );

   always #HALF_PERIOD clk = ~clk;
   // back to back testing, evil testing
   assign UART_RX_I = UART_TX_O;

   initial begin
      clk = 0;
      rst_n = 1;
      tx_flag = 0;
      tx_flag = 0;
      #(20*PERIOD);
      rst_n = 0;
      #(200*PERIOD);
      rst_n = 1;
   end
   
   // UART Config
   initial begin
      BGE = 0;
      #1;
      config_file = $fopen(CONFIG_PATH, "r");
      if (config_file == 0)      $error("Config file was NOT opened successfully");
      #1;
      $fscanf(config_file, "%b", WLS);
      $fscanf(config_file, "%b", PEN);
      $fscanf(config_file, "%b", EPS);
      $fscanf(config_file, "%b", STB);
      #1;
      $fclose(config_file);
      #1;
      OSM_SEL = $urandom_range(0,1);
      divisor = $urandom_range(27, 1603);
      BGE = 1;
   end
   
   // UART Transmisstion - back to back
   initial begin
      #(400*PERIOD);
      tbr_file = $fopen(TBR_PATH,"r");
      $fscanf(tbr_file, "%b", TBR_i);
      while (!$feof(tbr_file)) begin
         if (!tx_fifo_full) begin
            @(posedge clk);
            tx_flag = 1;
            @(negedge clk);
            tx_flag = 0;
            $fscanf(tbr_file, "%b", TBR_i);
         end 
         else begin
            @(negedge clk);
            TBR_i = TBR_i;
            tx_flag = 0;
         end
      end

      #(PERIOD*divisor*16*12*16);        // Wait to send-receive all possible data cycle x divisor x max osm x max frame length x max depth 
      $fclose(tbr_file);
      $fclose(rbr_file);   
      $finish;
   end

   // UART Reception - back to back
   initial begin
      rbr_file = $fopen(RBR_PATH, "w");
      while (1) begin
         if (!rx_fifo_empty) begin
            @(posedge clk);
            rx_flag = 1;
            @(negedge clk);
            rx_flag = 0;
            $fdisplay(rbr_file, "%b", RBR_o);
         end
         else begin
            @(negedge clk);
            rx_flag = 0;
         end
      end
   end
   /*
   initial begin
      $dumpfile("UART_IP_random.vcd");
      $dumpvars(0, UART_IP_random_tb);
   end
   */
endmodule
