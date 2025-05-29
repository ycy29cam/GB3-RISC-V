// Generates 24 MHz system clock and supports light- and deep-sleep modes.

module osc_ctrl (
    clk_req,
    clk_sys,
    osc_ready
        // goes HIGH after HFOSC is running
);

    input  wire  clk_req;      // 1 = CPU active, 0 = WFI / deep idle
    output wire  clk_sys;     // 24 MHz when granted
    output wire osc_ready;

    wire clk24, hf_en, hf_pu;

    // light-sleep gate : immediate resume (<2 µs)
    assign hf_pu = 1'b1;            // keep bias ON
    assign hf_en = clk_req;

    SB_HFOSC #(.CLKHF_DIV("0b01")) hfosc (
        .CLKHFPU (hf_pu),           // bias
        .CLKHFEN (hf_en),           // clock enable
        .CLKHF   (clk24)
    );

    // slow clock for timed wake-up
    SB_LFOSC lfosc ( .CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF() );

    SB_GB gb (.USER_SIGNAL_TO_GLOBAL_BUFFER(clk24),
              .GLOBAL_BUFFER_OUTPUT(clk_sys));

    localparam [1:0] OFF   = 2'd0,
                 WAIT1 = 2'd1,
                 WAIT2 = 2'd2,
                 ON    = 2'd3;
    reg [1:0] state;

    always @(posedge clk24 or negedge hf_en) begin
        if (!hf_en)
            state <= OFF;
        else
            state <= state + 2'd1;
    end
    assign osc_ready = (state==ON);

endmodule