// pll_ctrl.v  – gates the hard PLL with BYPASS during WFI
module pll_ctrl (
    input  wire clk_ref,   // 48-MHz HFOSC
    input  wire wfi,       // 1 = CPU idle
    output wire clk_core   // 24-MHz to the CPU
);
    // -------------------------------------------------------------
    //  PLL instance
    // -------------------------------------------------------------
    SB_PLL40_CORE #(
        .DIVR(4'd0),      // ÷1 reference  (48 MHz)
        .DIVF(7'd31),     // ×32-1 => 48 MHz *32 / (1<<n) … here we simply
        .DIVQ(3'd5),      // ÷32          drop back to 24 MHz after BYPASS
        .FILTER_RANGE(3'b001)
    ) pll (
        .REFERENCECLK (clk_ref),
        .PLLOUTCORE   (clk_core),
        .BYPASS       (wfi),       // <-- 1 = route REFCLK, VCO off
        .RESETB       (1'b1),
        .LOCK         ()           // unused, latency <1 clk if BYPASS=1
    );
endmodule
