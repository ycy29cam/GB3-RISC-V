// One SB_IO per LED so we can gate the pad in WFI
module io_leds (
    input  wire       clk,
    input  wire [7:0] led_bus,
    input  wire       wfi,
    output wire [7:0] led_pad
);
    genvar i;
    generate for (i=0;i<8;i=i+1) begin : g
        SB_IO #(
            .PIN_TYPE(6'b010000),       // simple registered output
            .DRIVE_STRENGTH("x1"),
            .PULLUP(1'b0)
        ) io (
            .OUTPUT_ENABLE(~wfi),       // iCEGate-style freeze
            .D_OUT_0      (led_bus[i]),
            .PACKAGE_PIN  (led_pad[i])
        );
    end endgenerate
endmodule
