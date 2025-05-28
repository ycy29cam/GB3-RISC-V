// pll_ctrl.v  – feeds the SoC clock; powers the PLL VCO down during WFI
module pll_ctrl (
    input  wire clk_ref,   // 48-MHz HFOSC
    input  wire wfi,       // wait-for-interrupt flag from CPU
    output wire clk_core   // clock delivered to cpu.clk
);
    //------------------------------------------------------------------
    //  Hard PLL.  LOW-POWER MODE when wfi=1 :
    //    * BYPASS = 1           routes REFCLK -> PLLOUT
    //    * LATCHINPUTVALUE = 1  freezes VCO & dividers
    //    * ENABLE_ICEGATE_* = 1 required per data-sheet
    //------------------------------------------------------------------
    SB_PLL40_CORE #(
        .DIVR(4'd0), .DIVF(7'd31), .DIVQ(3'd5),
        .FILTER_RANGE(3'b001),
        .ENABLE_ICEGATE_PORTA(1'b1),   // << new
        .ENABLE_ICEGATE_PORTB(1'b1)    // << new
    ) pll (
        .REFERENCECLK    (clk_ref),
        .PLLOUTCORE      (clk_core),
        .BYPASS          (wfi),        // 1 = route REFCLK
        .LATCHINPUTVALUE (wfi),        // 1 = low-power freeze
        .RESETB          (1'b1),
        .LOCK            ()            // unused
    );
endmodule
