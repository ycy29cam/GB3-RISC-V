// io_freeze.v  – drive Bank-2 LED outputs; gate them during WFI
module io_freeze (
    input  wire        clk,       // still 12-MHz HFOSC
    input  wire        wfi,       // 1 = CPU idle
    input  wire [7:0]  led_bus,   // internal LED register
    output wire [7:0]  led_pad    // board pins
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : g
            SB_IO #(
                .PIN_TYPE(6'b0100_00),        // registered output
                .DRIVE_STRENGTH("x1"),         // 2-mA at 3V3 or 2V5
                .PULLUP(1'b0)
            ) pad (
                .PACKAGE_PIN   (led_pad[i]),
                .D_OUT_0       (led_bus[i]),
                .OUTPUT_ENABLE (~wfi)          // ❶ icegate signal
            );
        end
    endgenerate
endmodule
