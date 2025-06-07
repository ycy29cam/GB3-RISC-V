module ramNR #(
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
    input  wire        RCLK,
    input  wire        RE,
    input  wire [7:0]  RADDR,
    output wire [15:0] RDATA,

);

    SB_RAM256x16NR #(
        .INIT_0(INIT_0),  .INIT_1(INIT_1),  .INIT_2(INIT_2),  .INIT_3(INIT_3),
        .INIT_4(INIT_4),  .INIT_5(INIT_5),  .INIT_6(INIT_6),  .INIT_7(INIT_7),
        .INIT_8(INIT_8),  .INIT_9(INIT_9),  .INIT_A(INIT_A),  .INIT_B(INIT_B),
        .INIT_C(INIT_C),  .INIT_D(INIT_D),  .INIT_E(INIT_E),  .INIT_F(INIT_F)
    ) ram_inst (
        .RCLK(RCLK),
        .RE(RE),
        .RADDR(RADDR),
        .RDATA(RDATA),
        // Tie off unused write ports
        .WCLK(1'b0),
        .WE(1'b0),
        .WADDR(8'h00),
        .WDATA(16'h0000),
        .MASK(16'h1111)
    );

endmodule

// example usage:
// ramNR #(
//     .INIT_0(256'h00112233445566778899aabbccddeeff112233445566778899aabbccddeeff00),
//     .INIT_1(256'h...), // fill in rest
//     ...
// ) instr_bram (
//     .RCLK(clk),
//     .RE(1'b1),
//     .RADDR(addr[9:2]),  // assuming word-aligned
//     .RDATA(instr_data),
//     .WCLK(1'b0),
//     .WE(1'b0),
//     .WADDR(8'h00),
//     .WDATA(16'h0000),
//     .MASK(16'hFFFF)
// );
