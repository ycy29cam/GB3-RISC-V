module spram_wrap #(
    parameter INIT_FILE = ""      // optional HEX for prog mem
)(
    input  logic         clk,
    input  logic         sel,     // 1 = normal access
    input  logic         we,
    input  logic  [3:0]  be,
    input  logic [15:0]  addr,
    input  logic [31:0]  din,
    output logic [31:0]  dout,

    // -------- power pins -----------------------------------------------------
    input  logic         ls_req,  // light-sleep  (Stand-by)
    input  logic         ds_req   // deep-sleep   (Sleep)
);

    SB_SPRAM256KA #(.INIT_FILE(INIT_FILE),
                    .STANDBY(1'b0))

    ram (
        .CLOCK      (clk),
        .CHIPSELECT (sel),
        .WREN       (we),
        .MASKWREN   (be),
        .ADDRESS    (addr),
        .DATAIN     (din),
        .DATAOUT    (dout),
        /* ❷ power-state pins */
        .STANDBY    (ls_req),
        .SLEEP      (ds_req),
        .POWEROFF   (1'b1)           // unused in this work
    );
endmodule