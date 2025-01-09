// Author: Nam Doan

module UART_IP (
   input wire           clk,
                        rst_n,
                        en_tx_fifo_empty,
                        en_tx_fifo_full,
                        en_rx_fifo_empty,
                        en_rx_fifo_full,
                        tx_flag,
                        rx_flag,
                        PEN, EPS, STB, BGE, OSM_SEL,
   input  wire [1:0]    WLS,  
   input  wire [7:0]    TBR_i,
                        DLH, DLL,
   input  wire          UART_RX_I,
   output wire          UART_TX_O,
   output wire [7:0]    RBR_o,
   output wire          tx_fifo_empty,
                        tx_fifo_full,
                        rx_fifo_empty,
                        rx_fifo_full,
   output wire [7:0]    FSR_o
);
   
   wire        tx_empty_status,
               tx_full_status,
               rx_empty_status,
               rx_full_status,
               tx_done,
               rx_done,
               baud_clk;
   wire  [7:0] tx_data,
               rx_data;
   
   // FSR concatenation
   assign FSR_o = {4'b0000, rx_empty_status, rx_full_status, tx_empty_status, tx_full_status};
   
   // Interrupt Generator
   assign tx_fifo_empty = en_tx_fifo_empty & tx_empty_status;
   assign tx_fifo_full  = en_tx_fifo_full  & tx_full_status;
   assign rx_fifo_empty = en_rx_fifo_empty & rx_empty_status;
   assign rx_fifo_full  = en_rx_fifo_full  & rx_full_status;

   // Baud Generator
   baud_generator u_baud_generator (
      .clk        (clk     ),
      .rst_n      (rst_n   ),
      .en         (BGE     ),
      .DLH        (DLH     ),
      .DLL        (DLL     ),
      .baud_clk   (baud_clk)
   );

   // Tx FIFO
   syn_fifo #(
      .WIDTH         (8 ),
      .DEPTH         (16)
   ) u_Tx_FIFO (
      .clk           (clk              ),
      .rst_n         (rst_n            ),
      .w_data        (TBR_i            ),
      .r_data        (tx_data          ),
      .w_request     (tx_flag          ),
      .r_request     (tx_done          ),
      .full_status   (tx_full_status   ),
      .empty_status  (tx_empty_status  )
   );

   // Rx FIFO
   syn_fifo #(
      .WIDTH         (8 ),
      .DEPTH         (16)
   ) u_Rx_FIFO (
      .clk           (clk              ),
      .rst_n         (rst_n            ),
      .w_data        (rx_data          ),
      .r_data        (RBR_o            ),
      .w_request     (rx_done          ),
      .r_request     (rx_flag          ),
      .full_status   (rx_full_status   ),
      .empty_status  (rx_empty_status  )
   );

   // UART Tx
   UART_Tx u_UART_Tx (
      .clk              (clk              ),
      .rst_n            (rst_n            ),
      .tx_empty_status  (tx_empty_status  ),
      .baud_clk         (baud_clk         ),
      .PEN              (PEN              ),
      .EPS              (EPS              ),
      .STB              (STB              ),
      .BGE              (BGE              ),
      .OSM_SEL          (OSM_SEL          ),
      .WLS              (WLS              ),
      .tx_data          (tx_data          ),
      .tx_done          (tx_done          ),
      .UART_TX_O        (UART_TX_O        )
   );

   // UART Rx
   UART_Rx u_UART_Rx (
      .clk              (clk        ),
      .rst_n            (rst_n      ),
      .baud_clk         (baud_clk   ),
      .UART_RX_I        (UART_RX_I  ),
      .PEN              (PEN        ),
      .STB              (STB        ),
      .BGE              (BGE        ),
      .OSM_SEL          (OSM_SEL    ),
      .WLS              (WLS        ),
      .rx_done          (rx_done    ),
      .rx_data          (rx_data    )
   );

endmodule
