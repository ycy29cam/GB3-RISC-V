// pll_ctrl.v  – single-output PLL with BYPASS+LATCHINPUTVALUE gating
module pll_ctrl (
    input  wire clk_ref,   // 48-MHz HFOSC
    input  wire wfi,       // Wait-For-Interrupt from CPU
    output wire clk_core   // clock that feeds the SoC
);

    SB_PLL40_CORE #(
        // ───────── frequency programme: 48 MHz ─▶ 24 MHz ────────────
        .DIVR(4'd0),          // ÷1  (REFCLK 48 MHz)
        .DIVF(7'd31),         // ×32
        .DIVQ(3'd5),          // ÷32 → 24 MHz when BYPASS = 0
        .FILTER_RANGE(3'b001),
        .FEEDBACK_PATH("SIMPLE"),
        .PLLOUT_SELECT("GENCLK")
    ) pll (
        .REFERENCECLK    (clk_ref),
        .PLLOUTCORE      (clk_core),
        .BYPASS          (wfi),     // 1 = route REFCLK
        .LATCHINPUTVALUE (wfi),     // 1 = freeze VCO & save power
        .RESETB          (1'b1),
        .LOCK            ()         // not used
    );
endmodule
