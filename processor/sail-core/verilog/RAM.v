module ram #(
    parameter INIT_0  = 256'h0,
    parameter INIT_1  = 256'h0,
    parameter INIT_2  = 256'h0,
    parameter INIT_3  = 256'h0,
    parameter INIT_4  = 256'h0,
    parameter INIT_5  = 256'h0,
    parameter INIT_6  = 256'h0,
    parameter INIT_7  = 256'h0,
    parameter INIT_8  = 256'h0,
    parameter INIT_9  = 256'h0,
    parameter INIT_A  = 256'h0,
    parameter INIT_B  = 256'h0,
    parameter INIT_C  = 256'h0,
    parameter INIT_D  = 256'h0,
    parameter INIT_E  = 256'h0,
    parameter INIT_F  = 256'h0
) (

    output wire [15:0] RDATA,
    input wire [4:0] raddr,
    input wire clk,
    input wire [15:0] WDATA,
    input wire [4:0] waddr,
    input wire write

);

    SB_RAM256x16 #(
        .INIT_0(INIT_0),  .INIT_1(INIT_1),  .INIT_2(INIT_2),  .INIT_3(INIT_3),
        .INIT_4(INIT_4),  .INIT_5(INIT_5),  .INIT_6(INIT_6),  .INIT_7(INIT_7),
        .INIT_8(INIT_8),  .INIT_9(INIT_9),  .INIT_A(INIT_A),  .INIT_B(INIT_B),
        .INIT_C(INIT_C),  .INIT_D(INIT_D),  .INIT_E(INIT_E),  .INIT_F(INIT_F)
    ) ram_inst (
        .RDATA      (RDATA),
        .RADDR      (raddr),
        .RCLK       (clk),
        .RCLKE      (1'b1),
        .RE         (1'b1),

        .WDATA      (WDATA),
        .WADDR      (waddr),
        .WCLK       (clk),
        .WCLKE      (1'b1),
        .WE         (write),
        .MASK       (16'hFFFF)
    );

endmodule