// spram_wrap.v  – ONE SB_SPRAM256KA, 32-bit interface (two 16-bit beats)
module spram_wrap (
    input  wire        clk,
    input  wire        sel,        // 1 = chip selected
    input  wire        we,         // 1 = write
    input  wire [3:0]  be,         // byte-enable
    input  wire [15:0] addr,       // word address [15:1], half-word sel in addr[0]
    input  wire [31:0] din,
    output reg  [31:0] dout,
    input  wire        ls_req,     // STANDBY
    input  wire        ds_req      // SLEEP
);
    //---------------------------------------------------------------
    // physical address : {addr[15:1], 1’b0}   (16-bit words)
    wire [13:0] phy_addr = addr[15:2];    // 14 bits → 16 k words

    wire [15:0] ram_dout;

    SB_SPRAM256KA ram (
        .CLOCK     (clk),
        .CHIPSELECT(sel),
        .ADDRESS   ({2'b00, phy_addr}),   // 0-extended to 16 bits
        .DATAIN    (addr[0] ? din[31:16] : din[15:0]),
        .MASKWREN  (be),
        .WREN      (we),
        .DATAOUT   (ram_dout),
        .STANDBY   (ls_req),
        .SLEEP     (ds_req),
        .POWEROFF  (1'b0)
    );

    //---------------------------------------------------------------
    // Re-assemble 32-bit read data over two cycles
    //---------------------------------------------------------------
    always @(posedge clk) begin
        if (!addr[0])                     // low half read first
            dout[15:0]  <= ram_dout;
        else
            dout[31:16] <= ram_dout;
    end
endmodule
