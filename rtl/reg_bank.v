`timescale 1ns/10ps
module reg_bank (
   input  wire          clk,
                        rst_n,
                        w_e,
                        r_e,
   input  wire [7:0]    w_addr,
                        r_addr,
                        w_data,
   output reg  [7:0]    r_data,
   input  wire [7:0]    FSR,
                        RBR,
   output wire [7:0]    MDR,
                        DLL,
                        DLH,
                        LCR,
                        IER,
                        TBR,
   output reg           tx_flag,
   output wire          rx_flag
);

   reg [7:0] FSR_d;
   reg [7:0] MEM [0:7];
   // 0 - MDR - Write & Read
   // 1 - DLL - Write & Read
   // 2 - DLH - Write & Read
   // 3 - LCR - Write & Read
   // 4 - IER - Write & Read
   // 5 - FSR - Read only (not even a register)
   // 6 - TBR - Write & Read
   // 7 - RBR - Read only (not even a register)

   assign MDR = MEM[0];
   assign DLL = MEM[1];
   assign DLH = MEM[2];
   assign LCR = MEM[3];
   assign IER = MEM[4];
   assign TBR = MEM[6];    // -5 -7

   // Write to MEM
   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         MEM[0] <= 0;
         MEM[1] <= 0;
         MEM[2] <= 0;
         MEM[3] <= 0;
         MEM[4] <= 0;
         MEM[6] <= 0;
      end
      else begin
         if (w_e) begin
            case (w_addr)
               0: MEM[0] <= {7'b0, w_data[0]};
               1: MEM[1] <= w_data;
               2: MEM[2] <= w_data;
               3: MEM[3] <= {2'b0, w_data[5:0]};
               4: MEM[4] <= {4'b0, w_data[3:0]};
               6: MEM[6] <= w_data;
            endcase
         end
      end
   end

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n)
         FSR_d <= 8'b0;
      else
         FSR_d <= FSR;  
   end

   always @(*) begin
      MEM[7] = RBR;
   end

   always @(*) begin
      MEM[5] = FSR_d;
   end


   // Read out MEM immediately (comb)
   always @(*) begin
      case (r_addr)
         0: r_data = MEM[0];
         1: r_data = MEM[1];
         2: r_data = MEM[2];
         3: r_data = MEM[3];
         4: r_data = MEM[4];
         5: r_data = MEM[5];
         6: r_data = MEM[6];
         7: r_data = MEM[7];
         default: r_data = MEM[7];
      endcase
   end

   assign rx_flag = (r_addr == 7) ? 1'b1 : 1'b0;

   always @(posedge clk, negedge rst_n) begin
      if (!rst_n) begin
         tx_flag <= 0;
      end
      else begin
         if (w_e && (w_addr == 6)) begin
            tx_flag <= 1;
         end
         else begin
            tx_flag <= 0;
         end
      end
   end

endmodule