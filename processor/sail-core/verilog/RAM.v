module RAM #(
    parameter READ_MODE  = "0", // "0": 256x16 mode
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
) (
    input  wire        clk,
    input  wire        en,
    input  wire [7:0]  addr,
    output wire [15:0] data
);

    SB_RAM40_4K ram_inst (
        .WDATA (16'h0000),
        .MASK  (16'h0000),
        .WADDR (8'h00),
        .WE    (1'b0),
        .WCLKE (1'b0),
        .WCLK  (clk),

        .RADDR (addr),
        .RE    (en),
        .RCLKE (1'b1),
        .RCLK  (clk),
        .RDATA (data)
    );

    defparam ram_inst.READ_MODE  = READ_MODE;
    defparam ram_inst.WRITE_MODE = "0";

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
