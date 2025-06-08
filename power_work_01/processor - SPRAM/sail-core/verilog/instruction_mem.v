// -----------------------------------------------------------------------------
// Instruction memory   – dual spram_wrap, Stand-by on WFI, no deep-sleep
// -----------------------------------------------------------------------------
module instruction_memory (
    input  wire         clk,        // original core clock
    input  wire [31:0]  addr,       // byte address from PC
    input  wire         wfi,        // wait-for-interrupt flag
    output wire [31:0]  out
);
    /* split 32-bit fetch into two 16-bit half-word reads */
    wire [17:1] word_addr = addr[17:1];
    wire [15:0] q_hi, q_lo;

    spram_wrap imem_hi (
        .clk   (clk),
        .sel   (1'b1),            // always selected
        .we    (1'b0), .be(4'h0),
        .addr  ({word_addr,1'b1}),
        .din   (16'h0),
        .dout  (q_hi),
        .ls_req(wfi), .ds_req(1'b0)   // Stand-by only
    );

    spram_wrap imem_lo (
        .clk   (clk),
        .sel   (1'b1),
        .we    (1'b0), .be(4'h0),
        .addr  ({word_addr,1'b0}),
        .din   (16'h0),
        .dout  (q_lo),
        .ls_req(wfi), .ds_req(1'b0)
    );

    assign out = {q_hi, q_lo};
endmodule
