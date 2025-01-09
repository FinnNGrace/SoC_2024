module apb_slave (
   input  wire          clk,
                        rst_n,
   input  wire          PENABLE,
                        PSEL,
                        PWRITE,
   input  wire [31:0]   PWDATA,
                        PADDR,
   output reg           PREADY,
   output wire          PSLVERR,
   output wire [31:0]   PRDATA,
   // UART-SPECIFIC
   input  wire [7:0]    FSR,
                        RBR,
   output wire [7:0]    MDR,
                        DLL,
                        DLH,
                        LCR,
                        IER,
                        TBR,
   output wire          tx_flag,
   output wire          rx_flag   
);
   wire        w_en, r_en;
   wire  [7:0] r_data;
   wire        access_phase;
   reg         addr_vld;
   reg   [7:0] addr;

   assign access_phase = PENABLE & PSEL;
   
   reg delayed_access_phase_1;
   reg delayed_access_phase_2;

   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           delayed_access_phase_1 <= 1'b0;
           delayed_access_phase_2 <= 1'b0;
           PREADY <= 1'b0;
       end else begin
           delayed_access_phase_1 <= access_phase; 
           delayed_access_phase_2 <= delayed_access_phase_1; 
           PREADY <= delayed_access_phase_2;
       end
   end
   

   // address decoder
   always @(*) begin
      addr = PADDR[7:0];
      if (PADDR <= 8'h07) begin
         addr_vld = 1;
      end
      else begin
         addr_vld = 0;
      end
   end

   assign PSLVERR = PREADY && access_phase && (~addr_vld);
   assign r_en = PREADY && access_phase && addr_vld && (~PWRITE);
   assign w_en = PREADY && access_phase && addr_vld && PWRITE;

   reg_bank u_reg_bank (
      .clk     (clk     ),
      .rst_n   (rst_n   ),
      .w_e     (w_en    ),
      .r_e     (r_en    ),
      .w_addr  (addr    ),
      .r_addr  (addr    ),
      .w_data  (PWDATA[7:0]),
      .r_data  (r_data  ),
      .FSR     (FSR     ),
      .RBR     (RBR     ),
      .MDR     (MDR     ),
      .DLL     (DLL     ),
      .DLH     (DLH     ),
      .LCR     (LCR     ),
      .IER     (IER     ),
      .TBR     (TBR     ),
      .tx_flag (tx_flag ),
      .rx_flag (rx_flag )
   );
   
   // assign PRDATA = r_en ? {24'b0, r_data} : 32'bz;
   assign PRDATA = r_en ? {24'b0, r_data} : {24'b0, r_data};

endmodule