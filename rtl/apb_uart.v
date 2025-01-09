module apb_uart (
   input  wire          clk,
                        rst_n,
   // UART
   input  wire          UART_RX_I,
   output wire          UART_TX_O,
                        tx_fifo_empty,
                        tx_fifo_full,
                        rx_fifo_empty,
                        rx_fifo_full,
   //APB
   input  wire          PENABLE,
                        PSEL,
                        PWRITE,
   input  wire [31:0]   PWDATA,
                        PADDR,
   output wire          PREADY,
   output wire          PSLVERR,
   output wire [31:0]   PRDATA
);

   wire [7:0]  MDR,
               DLL,
               DLH,
               LCR,
               IER,
               TBR,
               RBR,
               FSR;
   wire        tx_flag, tx_flag_tmp,
               rx_flag, rx_flag_tmp;

   apb_slave u_apb_slave (
      .clk     (clk     ),
      .rst_n   (rst_n   ),
      .PENABLE (PENABLE ),
      .PSEL    (PSEL    ),
      .PWRITE  (PWRITE  ),
      .PWDATA  (PWDATA  ),
      .PADDR   (PADDR   ),
      .PREADY  (PREADY  ),
      .PSLVERR (PSLVERR ),
      .PRDATA  (PRDATA  ),
      .FSR     (FSR     ),
      .RBR     (RBR     ),
      .MDR     (MDR     ),
      .DLL     (DLL     ),
      .DLH     (DLH     ),
      .LCR     (LCR     ),
      .IER     (IER     ),
      .TBR     (TBR     ),
      .tx_flag (tx_flag_tmp ),
      .rx_flag (rx_flag_tmp )
   );

   edge_detector u_tx_pulse (
      .clk(clk),
      .data_in(tx_flag_tmp),
      .pulse_out(tx_flag)
   );

   edge_detector u_rx_pulse (
      .clk(clk),
      .data_in(rx_flag_tmp),
      .pulse_out(rx_flag)
   );

   // UART IP
   UART_IP u_UART_IP (
      .clk              (clk           ),
      .rst_n            (rst_n         ),
      .en_tx_fifo_empty (IER[1]        ),
      .en_tx_fifo_full  (IER[0]        ),
      .en_rx_fifo_empty (IER[3]        ),
      .en_rx_fifo_full  (IER[2]        ),
      .tx_flag          (tx_flag       ),
      .rx_flag          (rx_flag       ),
      .PEN              (LCR[3]        ),
      .EPS              (LCR[4]        ),
      .STB              (LCR[2]        ),
      .BGE              (LCR[5]        ),
      .OSM_SEL          (MDR[0]        ),
      .WLS              (LCR[1:0]      ),
      .TBR_i            (TBR           ),
      .DLL              (DLL           ),
      .DLH              (DLH           ),
      .UART_RX_I        (UART_RX_I     ),
      .UART_TX_O        (UART_TX_O     ),
      .RBR_o            (RBR           ),
      .tx_fifo_empty    (tx_fifo_empty ),
      .tx_fifo_full     (tx_fifo_full  ),
      .rx_fifo_empty    (rx_fifo_empty ),
      .rx_fifo_full     (rx_fifo_full  ),
      .FSR_o            (FSR           )
   );

endmodule