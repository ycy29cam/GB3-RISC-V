// io_leds.v  – freeze LED pads while CPU is in WFI
module io_leds (
    input  wire       clk,         // kept for registered output
    input  wire [7:0] led_bus,
    input  wire       wfi,
    output wire [7:0] led_pad
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : g
            SB_IO #(
                .PIN_TYPE   (6'b0100_00),   // registered output
                .PULLUP     (1'b0)          // no pull-up
                // no DRIVE_STRENGTH here
            ) io (
                .PACKAGE_PIN  (led_pad[i]),
                .OUTPUT_ENABLE(~wfi),       // high-Z during WFI
                .D_OUT_0      (led_bus[i])
            );
        end
    endgenerate
endmodule
