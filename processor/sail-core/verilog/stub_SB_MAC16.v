// Stub definition for SB_MAC16 (ICE40 DSP block)
// Use command yosys -p ' read_verilog verilog/*.v;  hierarchy -top cpu;  write_json cpu_for_svg.json'
// to generate a svg schematic
(* blackbox *)
module SB_MAC16 #(
    parameter A_REG = "0",
    parameter B_REG = "0",
    parameter C_REG = "0",
    parameter D_REG = "0",
    parameter TOP_8x8_MULT_REG = "0",
    parameter BOT_8x8_MULT_REG = "0",
    parameter PIPELINE_16x16_MULT_REG1 = "0",
    parameter PIPELINE_16x16_MULT_REG2 = "0",
    parameter PIPELINE_16x16_MULT_REG3 = "0",
    parameter CARRYIN_REG = "0",
    parameter ADD_SUB_REG = "0",
    parameter CARRYOUT_REG = "0"
)(
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    input [15:0] D,
    input        CLK,
    input        CE,
    input        A_SIGNED,
    input        B_SIGNED,
    input        OPMODE0,
    input        OPMODE1,
    input        OPMODE2,
    input        OPMODE3,
    input        OPMODE4,
    input        OPMODE5,
    input        CARRYIN,
    output [15:0] CARRYOUT,
    output [31:0] RESULT
);
endmodule
