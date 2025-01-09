// `define STATIC_PREDICTOR
// `define ONE_BIT_PREDICTOR
`define TWO_BIT_PREDICTOR


// `define USE_SINGLE_CYCLE   
// `define USE_PIPELINED_VER1
`define USE_PIPELINED_VER2


// data_mode
`define B   3'd1
`define H   3'd2
`define W   3'd3
`define BU  3'd4
`define HU  3'd5

// peripheral address
`define KEY_addr     16'h7810
`define SW_addr      16'h7800
`define LCD_addr     16'h7030
`define HEX_H_addr   16'h7024
`define HEX_L_addr   16'h7020
`define LEDG_addr    16'h7010
`define LEDR_addr    16'h7000

// alu mode
`define ADD    4'd1
`define SUB    4'd2
`define SLT    4'd3
`define SLTU   4'd4
`define XOR    4'd5
`define OR     4'd6
`define AND    4'd7
`define SLL    4'd8
`define SRL    4'd9
`define SRA    4'd10
`define LUI    4'd11

// Instruction format opcodes for Control Unit & Immediate Generator
`define R_TYPE          7'b0110011  // Register-type (ADD, SUB, etc.)
`define I_TYPE_ARITH    7'b0010011  // Immediate-type Arithmetic (ADDI, ANDI, etc.)
`define I_TYPE_LOAD     7'b0000011  // Immediate-type Load (LW, LB, etc.)
`define I_TYPE_ECALL_EBREAK 7'b1110011 // Immediate-type Call/Break (ECALL, EBREAK)
`define I_TYPE_JALR     7'b1100111  // Immediate-type Jump and Link Register (JALR)
`define S_TYPE          7'b0100011  // Store-type (SW, SB, etc.)
`define B_TYPE          7'b1100011  // Branch-type (BEQ, BNE, etc.)
`define U_TYPE_LUI      7'b0110111  // Upper-type (LUI)
`define U_TYPE_AUIPC    7'b0010111  // Upper-type (AUIPC)
`define J_TYPE          7'b1101111  // Jump-type (JAL)

// Write-back Select
`define WB_SEL_ALU   2'd1
`define WB_SEL_LSU   2'd2
`define WB_SEL_PC4   2'd3

