module ice40_ram40_4k #(
    parameter MODE = 0, // 0: 256x16, 1: 512x8, 2: 1024x4, 3: 2048x2
    parameter INIT_0 = 256'h0,
    parameter INIT_1 = 256'h0,
    parameter INIT_2 = 256'h0,
    parameter INIT_3 = 256'h0,
    parameter INIT_4 = 256'h0,
    parameter INIT_5 = 256'h0,
    parameter INIT_6 = 256'h0,
    parameter INIT_7 = 256'h0,
    parameter INIT_8 = 256'h0,
    parameter INIT_9 = 256'h0,
    parameter INIT_A = 256'h0,
    parameter INIT_B = 256'h0,
    parameter INIT_C = 256'h0,
    parameter INIT_D = 256'h0,
    parameter INIT_E = 256'h0,
    parameter INIT_F = 256'h0
)(
    input wire [15:0] WDATA,
    input wire [15:0] MASK,
    input wire [7:0]  WADDR,
    input wire        WE,
    input wire        WCLKE,
    input wire        WCLK,
    input wire [7:0]  RADDR,
    output wire [15:0] RDATA,
    input wire        RE,
    input wire        RCLKE,
    input wire        RCLK
);

// Single instance of SB_RAM40_4K
SB_RAM40_4K ram_inst (
    .WDATA(WDATA),
    .MASK(MASK),
    .WADDR(WADDR),
    .WE(WE),
    .WCLKE(WCLKE),
    .WCLK(WCLK),
    .RADDR(RADDR),
    .RE(RE),
    .RCLKE(RCLKE),
    .RCLK(RCLK),
    .RDATA(RDATA)
);

// Set read/write mode and initialization with defparam
defparam ram_inst.READ_MODE = MODE;
defparam ram_inst.WRITE_MODE = MODE;

defparam ram_inst.INIT_0 = INIT_0;
defparam ram_inst.INIT_1 = INIT_1;
defparam ram_inst.INIT_2 = INIT_2;
defparam ram_inst.INIT_3 = INIT_3;
defparam ram_inst.INIT_4 = INIT_4;
defparam ram_inst.INIT_5 = INIT_5;
defparam ram_inst.INIT_6 = INIT_6;
defparam ram_inst.INIT_7 = INIT_7;
defparam ram_inst.INIT_8 = INIT_8;
defparam ram_inst.INIT_9 = INIT_9;
defparam ram_inst.INIT_A = INIT_A;
defparam ram_inst.INIT_B = INIT_B;
defparam ram_inst.INIT_C = INIT_C;
defparam ram_inst.INIT_D = INIT_D;
defparam ram_inst.INIT_E = INIT_E;
defparam ram_inst.INIT_F = INIT_F;

endmodule