`timescale 1ns/1ps
module regfile
(
    input            clk,

    input            write,
    input  [4:0]     wrAddr,
    input  [31:0]    wrData,

    input  [4:0]     rdAddrA,
    output [31:0]    rdDataA,

    input  [4:0]     rdAddrB,
    output [31:0]    rdDataB
);
    // ---------------------------------------------------------------------
    // Internal signals
    // ---------------------------------------------------------------------
    wire        we          =  write & (wrAddr != 5'd0);  // block writes to x0
    wire [7:0]  waddr8      = {3'b000, wrAddr};           // EBR is 256 deep
    wire [7:0]  raddrA8     = {3'b000, rdAddrA};
    wire [7:0]  raddrB8     = {3'b000, rdAddrB};

    // Low / high halves coming from the four RAM blocks
    wire [15:0] rdALo, rdAHi, rdBLo, rdBHi;

    // ---------- low word, feeds read port A ----------
    SB_RAM256x16 ram_lo_A (
        .RDATA      (rdALo),
        .RADDR      (raddrA8),
        .RCLK       (clk),
        .RCLKE      (1'b1),
        .RE         (1'b1),

        .WDATA      (wrData[15:0]),
        .WADDR      (waddr8),
        .WCLK       (clk),
        .WCLKE      (1'b1),
        .WE         (we),
        .MASK       (16'hFFFF)
    );

    // ---------- high word, feeds read port A ----------
    SB_RAM256x16 ram_hi_A (
        .RDATA      (rdAHi),
        .RADDR      (raddrA8),
        .RCLK       (clk),
        .RCLKE      (1'b1),
        .RE         (1'b1),

        .WDATA      (wrData[31:16]),
        .WADDR      (waddr8),
        .WCLK       (clk),
        .WCLKE      (1'b1),
        .WE         (we),
        .MASK       (16'hFFFF)
    );

    // ---------- low word, feeds read port B ----------
    SB_RAM256x16 ram_lo_B (
        .RDATA      (rdBLo),
        .RADDR      (raddrB8),
        .RCLK       (clk),
        .RCLKE      (1'b1),
        .RE         (1'b1),

        .WDATA      (wrData[15:0]),
        .WADDR      (waddr8),
        .WCLK       (clk),
        .WCLKE      (1'b1),
        .WE         (we),
        .MASK       (16'hFFFF)
    );

    // ---------- high word, feeds read port B ----------
    SB_RAM256x16 ram_hi_B (
        .RDATA      (rdBHi),
        .RADDR      (raddrB8),
        .RCLK       (clk),
        .RCLKE      (1'b1),
        .RE         (1'b1),

        .WDATA      (wrData[31:16]),
        .WADDR      (waddr8),
        .WCLK       (clk),
        .WCLKE      (1'b1),
        .WE         (we),
        .MASK       (16'hFFFF)
    );

    // ---------------------------------------------------------------------
    //  Pipeline registers and simple forwarding (same as original design)
    // ---------------------------------------------------------------------
    reg [4:0]   rdAddrA_buf, rdAddrB_buf, wrAddr_buf;
    reg [31:0]  wrData_buf;
    reg         write_buf;
    reg [31:0]  regDatA, regDatB;

    wire [31:0] memDatA = {rdAHi, rdALo};
    wire [31:0] memDatB = {rdBHi, rdBLo};

    always @(posedge clk) begin
        // write-back forwarding pipeline
        wrAddr_buf   <= wrAddr;
        wrData_buf   <= wrData;
        write_buf    <= write;

        rdAddrA_buf  <= rdAddrA;
        rdAddrB_buf  <= rdAddrB;

        regDatA      <= (rdAddrA == 5'd0) ? 32'd0 : memDatA;
        regDatB      <= (rdAddrB == 5'd0) ? 32'd0 : memDatB;
    end

    // RAW hazard forwarding (identical to original)
    assign rdDataA =
        ( write_buf & (wrAddr_buf == rdAddrA_buf) & (wrAddr_buf != 5'd0) )
            ? wrData_buf : regDatA;

    assign rdDataB =
        ( write_buf & (wrAddr_buf == rdAddrB_buf) & (wrAddr_buf != 5'd0) )
            ? wrData_buf : regDatB;

endmodule
