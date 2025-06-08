module top (output [7:0] led);

    /* --------------------------- 1. raw oscillator ------------------------ */
    wire clk_ref;                                       // 48-MHz HFOSC
    SB_HFOSC #(.CLKHF_DIV("0b00")) HF (
        .CLKHFPU(1'b1), .CLKHFEN(1'b1),
        .CLKHF(clk_ref)
    );

    /* --------------------------- 2. PLL wrapper -------------------------- */
    wire clk_core;     // final system clock
    wire wfi;          // idle flag from CPU

    pll_ctrl PLLG (
        .clk_ref(clk_ref),
        .wfi(wfi),         // BYPASS+LATCH when idle
        .clk_core(clk_core)
    );

    /* --------------------------- 3. CPU core ----------------------------- */
    wire [31:0] im_addr, im_data;
    wire [31:0] dm_addr, dm_wdata, dm_rdata;
    wire        dm_wr, dm_rd;
    wire [3:0]  dm_be;

    cpu processor (
        .clk               (clk_core),
        .wfi_out           (wfi),
        .inst_mem_in       (im_addr),
        .inst_mem_out      (im_data),
        .data_mem_addr     (dm_addr),
        .data_mem_WrData   (dm_wdata),
        .data_mem_memwrite (dm_wr),
        .data_mem_memread  (dm_rd),
        .data_mem_sign_mask(dm_be),
        .data_mem_out      (dm_rdata)
    );

    /* --------------------------- 4. Memories ----------------------------- */
    instruction_memory IM (
        .addr (im_addr),
        .out  (im_data)
    );

    data_mem DM (
        .clk        (clk_core),
        .addr       (dm_addr),
        .write_data (dm_wdata),
        .memwrite   (dm_wr),
        .memread    (dm_rd),
        .sign_mask  (dm_be),
        .read_data  (dm_rdata),
        .led        (led)
    );
endmodule
