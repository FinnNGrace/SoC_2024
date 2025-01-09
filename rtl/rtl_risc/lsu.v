////////////////////////////////////
// Doan Dinh Nam      
// 23.11.2024   
// namhero02@gmail.com 
// Due to the resource limitations of DE2-Standard
// I firmly believe that we cannot implement a fully aligned LSU
// This means, the alignment is only valid for IN_MEM, OUT_MEM
// But it's not the case for DMEM
////////////////////////////////////

`include "cpu_def.vh"

module lsu (
   // ==== control signal ===== //
   input  wire          clk,
                        rst_n,
                        w_en,
   input  wire [31:0]   w_data,
   output reg  [31:0]   r_data,
   input  wire [15:0]   addr,
   input  wire [2:0]    data_mode,     // b - h - w - bu - hu
   // ==== input signal ==== //
   input  wire [31:0]   SW,            //SW[17] used to reset
                        KEY,

                        PREADY,
                        PSLVERR,
                        PRDATA,
   // ==== output signal ===== //
   output wire [31:0]   LEDR,          //LEDR[17] used to display SW[17]
                        LEDG,
                        HEX_H,
                        HEX_L,
                        LCD,

                        PSEL,
                        PENABLE,
                        PADDR,
                        PWDATA,
                        PWRITE
); 
   // Breakdown w_data into Bytes
   wire  [7:0] BYTE  [0:3];   

   // IN_MEM
   reg   [31:0]   KEY_MEM;          // 0x7810
   reg   [31:0]   SW_MEM;           // 0x7800

   // OUT_MEM
   reg   [31:0]   LCD_MEM;          // 0x7030
   reg   [31:0]   HEX_MEM_H;        // 0x7024
   reg   [31:0]   HEX_MEM_L;        // 0x7020
   reg   [31:0]   LEDG_MEM;         // 0x7010
   reg   [31:0]   LEDR_MEM;         // 0x7000

   // IN_MEM_APB
   reg   [31:0]   PREADY_MEM;           // 0x7834 - ok
   reg   [31:0]   PSLVERR_MEM;          // 0x7830 - ok
   reg   [31:0]   PRDATA_MEM;           // 0x7820 - ok

   // OUT_MEM_APB
   reg   [31:0]   PSEL_MEM;             // 0x783C - ok
   reg   [31:0]   PENABLE_MEM;          // 0x7838 - ok
   reg   [31:0]   PADDR_MEM;            // 0x782C - ok
   reg   [31:0]   PWDATA_MEM;           // 0x7828 - ok
   reg   [31:0]   PWRITE_MEM;           // 0x7824 - ok
   

   // DMEM
   reg   [31:0]   DMEM [0:(2**11)/4-1];   // 0x0000 - 0x07FF
   
   // Connect w_data to their byte pieces
   assign BYTE[0] = w_data[7:0];
   assign BYTE[1] = w_data[15:8];
   assign BYTE[2] = w_data[23:16];
   assign BYTE[3] = w_data[31:24]; 

   // Connect OUT_MEM to their counterparts
   assign LEDR       = LEDR_MEM;
   assign LEDG       = LEDG_MEM;
   assign HEX_H      = HEX_MEM_H;
   assign HEX_L      = HEX_MEM_L;
   assign LCD        = LCD_MEM;
   assign PSEL       = PSEL_MEM;
   assign PENABLE    = PENABLE_MEM;
   assign PADDR      = PADDR_MEM;
   assign PWDATA     = PWDATA_MEM;
   assign PWRITE     = PWRITE_MEM;
   
   // MEM_OUT_SELECT
   reg   [31:0]   MEM_OUT_B,
                  MEM_OUT_H,
                  MEM_OUT_W,
                  MEM_OUT_BU,
                  MEM_OUT_HU;

   // ==== Write without Alignment ==== //
   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         KEY_MEM <= 32'b0;
         SW_MEM <= 32'b0;
         PREADY_MEM <= 32'b0;
         PSLVERR_MEM <= 32'b0;
         PRDATA_MEM <= 32'b0;
      end
      else begin
         KEY_MEM <= KEY;
         SW_MEM <= SW;
         PREADY_MEM <= PREADY;
         PSLVERR_MEM <= PSLVERR;
         PRDATA_MEM <= PRDATA;
      end
   end

   always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         LCD_MEM <= 32'b0;
         HEX_MEM_H <= 32'b0;
         HEX_MEM_L <= 32'b0;
         LEDG_MEM <= 32'b0;
         LEDR_MEM <= 32'b0;
         PSEL_MEM <= 32'b0;
         PENABLE_MEM <= 32'b0;
         PADDR_MEM <= 32'b0;
         PWDATA_MEM <= 32'b0;
         PWRITE_MEM <= 32'b0;
      end
      else begin
         if (w_en) begin
            casez (addr)
               16'b0111_1000_0011_11??:
               begin
                  case (data_mode)
                  `B: begin
                     PSEL_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     PSEL_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     PSEL_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end         
               16'b0111_1000_0011_10??:
               begin
                  case (data_mode)
                  `B: begin
                     PENABLE_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     PENABLE_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     PENABLE_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_1000_0010_11??:
               begin
                  case (data_mode)
                  `B: begin
                     PADDR_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     PADDR_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     PADDR_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_1000_0010_10??:
               begin
                  case (data_mode)
                  `B: begin
                     PWDATA_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     PWDATA_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     PWDATA_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_1000_0010_01??:
               begin
                  case (data_mode)
                  `B: begin
                     PWRITE_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     PWRITE_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     PWRITE_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end

               16'b0111_0000_0011_00??:         // 0x7030   (LCD_MEM)
               begin
                  case (data_mode)
                  `B: begin
                     LCD_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     LCD_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     LCD_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_0000_0010_01??:         // 0x7024   (HEX_MEM_H)
               begin
                  case (data_mode)
                  `B: begin
                     HEX_MEM_H[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     HEX_MEM_H[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     HEX_MEM_H[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_0000_0010_00??:         // 0x7020   (HEX_MEM_L)
               begin
                  case (data_mode)
                  `B: begin
                     HEX_MEM_L[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     HEX_MEM_L[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     HEX_MEM_L[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_0000_0001_00??:         // 0x7010   (LEDG_MEM)
               begin
                  case (data_mode)
                  `B: begin
                     LEDG_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     LEDG_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     LEDG_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0111_0000_0000_00??:         // 0x7000   (LEDR_MEM)
               begin
                  case (data_mode)
                  `B: begin
                     LEDR_MEM[7:0] <= BYTE[0];
                  end     
                  `H: begin
                     LEDR_MEM[15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     LEDR_MEM[31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
               16'b0000_0???_????_????:         // 0x0000 - 0x07FFF  (DMEM)
               begin
                  case (data_mode)
                  `B: begin
                     DMEM[addr[10:2]][7:0] <= BYTE[0];
                  end     
                  `H: begin
                     DMEM[addr[10:2]][15:0] <= {BYTE[1], BYTE[0]};
                  end
                  `W: begin
                     DMEM[addr[10:2]][31:0] <= {BYTE[3], BYTE[2], BYTE[1], BYTE[0]};
                  end
                  endcase
               end
         endcase
         end
      end
   end

   // ==== Read without Alignment ==== //
   // MEM_OUT_SELECT
   always @(*) begin
      casez (addr)
         16'b0111_1000_0001_00??:         // KEY
         begin
            MEM_OUT_B = {{24{KEY_MEM[7]}}, KEY_MEM[7:0]};
            MEM_OUT_H = {{16{KEY_MEM[15]}}, KEY_MEM[15:0]};
            MEM_OUT_W = KEY_MEM;
            MEM_OUT_BU = {24'b0, KEY_MEM[7:0]};
            MEM_OUT_HU = {16'b0, KEY_MEM[15:0]};
         end
         16'b0111_1000_0000_00??:         // SW
         begin
            MEM_OUT_B = {{24{SW_MEM[7]}}, SW_MEM[7:0]};
            MEM_OUT_H = {{16{SW_MEM[15]}}, SW_MEM[15:0]};
            MEM_OUT_W = SW_MEM;
            MEM_OUT_BU = {24'b0, SW_MEM[7:0]};
            MEM_OUT_HU = {16'b0, SW_MEM[15:0]};
         end
         // APB
         16'b0111_1000_0011_01??:
         begin
            MEM_OUT_B = {{24{PREADY_MEM[7]}}, PREADY_MEM[7:0]};
            MEM_OUT_H = {{16{PREADY_MEM[15]}}, PREADY_MEM[15:0]};
            MEM_OUT_W = PREADY_MEM;
            MEM_OUT_BU = {24'b0, PREADY_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PREADY_MEM[15:0]};
         end
         16'b0111_1000_0011_00??:
         begin
            MEM_OUT_B = {{24{PSLVERR_MEM[7]}}, PSLVERR_MEM[7:0]};
            MEM_OUT_H = {{16{PSLVERR_MEM[15]}}, PSLVERR_MEM[15:0]};
            MEM_OUT_W = PSLVERR_MEM;
            MEM_OUT_BU = {24'b0, PSLVERR_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PSLVERR_MEM[15:0]};
         end
         16'b0111_1000_0010_00??:
         begin
            MEM_OUT_B = {{24{PRDATA_MEM[7]}}, PRDATA_MEM[7:0]};
            MEM_OUT_H = {{16{PRDATA_MEM[15]}}, PRDATA_MEM[15:0]};
            MEM_OUT_W = PRDATA_MEM;
            MEM_OUT_BU = {24'b0, PRDATA_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PRDATA_MEM[15:0]};
         end
         16'b0111_1000_0011_11??:
         begin
            MEM_OUT_B = {{24{PSEL_MEM[7]}}, PSEL_MEM[7:0]};
            MEM_OUT_H = {{16{PSEL_MEM[15]}}, PSEL_MEM[15:0]};
            MEM_OUT_W = PSEL_MEM;
            MEM_OUT_BU = {24'b0, PSEL_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PSEL_MEM[15:0]};
         end         
         16'b0111_1000_0011_10??:
         begin
            MEM_OUT_B = {{24{PENABLE_MEM[7]}}, PENABLE_MEM[7:0]};
            MEM_OUT_H = {{16{PENABLE_MEM[15]}}, PENABLE_MEM[15:0]};
            MEM_OUT_W = PENABLE_MEM;
            MEM_OUT_BU = {24'b0, PENABLE_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PENABLE_MEM[15:0]};
         end
         16'b0111_1000_0010_11??:
         begin
            MEM_OUT_B = {{24{PADDR_MEM[7]}}, PADDR_MEM[7:0]};
            MEM_OUT_H = {{16{PADDR_MEM[15]}}, PADDR_MEM[15:0]};
            MEM_OUT_W = PADDR_MEM;
            MEM_OUT_BU = {24'b0, PADDR_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PADDR_MEM[15:0]};
         end
         16'b0111_1000_0010_10??:
         begin
            MEM_OUT_B = {{24{PWDATA_MEM[7]}}, PWDATA_MEM[7:0]};
            MEM_OUT_H = {{16{PWDATA_MEM[15]}}, PWDATA_MEM[15:0]};
            MEM_OUT_W = PWDATA_MEM;
            MEM_OUT_BU = {24'b0, PWDATA_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PWDATA_MEM[15:0]};
         end
         16'b0111_1000_0010_01??:
         begin
            MEM_OUT_B = {{24{PWRITE_MEM[7]}}, PWRITE_MEM[7:0]};
            MEM_OUT_H = {{16{PWRITE_MEM[15]}}, PWRITE_MEM[15:0]};
            MEM_OUT_W = PWRITE_MEM;
            MEM_OUT_BU = {24'b0, PWRITE_MEM[7:0]};
            MEM_OUT_HU = {16'b0, PWRITE_MEM[15:0]};
         end
         //
         16'b0111_0000_0011_00??:         // 0x7030   (LCD_MEM)
         begin
            MEM_OUT_B = {{24{LCD_MEM[7]}}, LCD_MEM[7:0]};
            MEM_OUT_H = {{16{LCD_MEM[15]}}, LCD_MEM[15:0]};
            MEM_OUT_W = LCD_MEM;
            MEM_OUT_BU = {24'b0, LCD_MEM[7:0]};
            MEM_OUT_HU = {16'b0, LCD_MEM[15:0]};
         end
         16'b0111_0000_0010_01??:         // 0x7024   (HEX_MEM_H)
         begin
            MEM_OUT_B = {{24{HEX_MEM_H[7]}}, HEX_MEM_H[7:0]};
            MEM_OUT_H = {{16{HEX_MEM_H[15]}}, HEX_MEM_H[15:0]};
            MEM_OUT_W = HEX_MEM_H;
            MEM_OUT_BU = {24'b0, HEX_MEM_H[7:0]};
            MEM_OUT_HU = {16'b0, HEX_MEM_H[15:0]};
         end
         16'b0111_0000_0010_00??:         // 0x7020   (HEX_MEM_L)
         begin
            MEM_OUT_B = {{24{HEX_MEM_L[7]}}, HEX_MEM_L[7:0]};
            MEM_OUT_H = {{16{HEX_MEM_L[15]}}, HEX_MEM_L[15:0]};
            MEM_OUT_W = HEX_MEM_L;
            MEM_OUT_BU = {24'b0, HEX_MEM_L[7:0]};
            MEM_OUT_HU = {16'b0, HEX_MEM_L[15:0]};
         end
         16'b0111_0000_0001_00??:         // 0x7010   (LEDG_MEM)
         begin
            MEM_OUT_B = {{24{LEDG_MEM[7]}}, LEDG_MEM[7:0]};
            MEM_OUT_H = {{16{LEDG_MEM[15]}}, LEDG_MEM[15:0]};
            MEM_OUT_W = LEDG_MEM;
            MEM_OUT_BU = {24'b0, LEDG_MEM[7:0]};
            MEM_OUT_HU = {16'b0, LEDG_MEM[15:0]};
         end
         16'b0111_0000_0000_00??:         // 0x7000   (LEDR_MEM)
         begin
            MEM_OUT_B = {{24{LEDR_MEM[7]}}, LEDR_MEM[7:0]};
            MEM_OUT_H = {{16{LEDR_MEM[15]}}, LEDR_MEM[15:0]};
            MEM_OUT_W = LEDR_MEM;
            MEM_OUT_BU = {24'b0, LEDR_MEM[7:0]};
            MEM_OUT_HU = {16'b0, LEDR_MEM[15:0]};
         end
         16'b0000_0???_????_????:         // 0x0000 - 0x07FFF  (DMEM)
         begin
            MEM_OUT_B = {{24{DMEM[addr[10:2]][7]}}, DMEM[addr[10:2]][7:0]};
            MEM_OUT_H = {{16{DMEM[addr[10:2]][15]}}, DMEM[addr[10:2]][15:0]};
            MEM_OUT_W = DMEM[addr[10:2]];
            MEM_OUT_BU = {24'b0, DMEM[addr[10:2]][7:0]};
            MEM_OUT_HU = {16'b0, DMEM[addr[10:2]][15:0]};
         end
         default:
         begin
            MEM_OUT_B = 32'b0;
            MEM_OUT_H = 32'b0;
            MEM_OUT_W = 32'b0;
            MEM_OUT_BU = 32'b0;
            MEM_OUT_HU = 32'b0;
         end
      endcase
   end   
   
   // DATA_MODE_SELECT
   always @(*) begin
      case (data_mode)
         `B: r_data = MEM_OUT_B;
         `H: r_data = MEM_OUT_H;
         `W: r_data = MEM_OUT_W;
         `BU: r_data = MEM_OUT_BU;
         `HU: r_data = MEM_OUT_HU;           
         default: r_data = 32'b0;
      endcase
   end
endmodule