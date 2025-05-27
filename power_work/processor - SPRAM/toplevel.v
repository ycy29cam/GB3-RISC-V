module top (led);
    output [7:0] led;

    //----------------- 24-MHz HFOSC -----------------
    wire clk;
    SB_HFOSC #(.CLKHF_DIV("0b11")) HF (
        .CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    //----------------- CPU --------------------------
    wire [31:0] imem_addr, imem_data;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire        dmem_wr, dmem_rd;
    wire [3:0]  dmem_be;
    wire        wfi;               // << NEW

    cpu u_cpu (
        .clk                (clk),  // direct clock, no stall gating
        .wfi_out            (wfi),  // new export
        .inst_mem_in        (imem_addr),
        .inst_mem_out       (imem_data),
        .data_mem_addr      (dmem_addr),
        .data_mem_WrData    (dmem_wdata),
        .data_mem_memwrite  (dmem_wr),
        .data_mem_memread   (dmem_rd),
        .data_mem_sign_mask (dmem_be),
        .data_mem_out       (dmem_rdata)
    );

    //----------------- Low-power memories -----------
    instruction_memory IM (
        .clk  (clk),
        .addr (imem_addr),
        .wfi  (wfi),
        .out  (imem_data)
    );

    data_mem DM (
        .clk        (clk),
        .addr       (dmem_addr),
        .write_data (dmem_wdata),
        .memwrite   (dmem_wr),
        .memread    (dmem_rd),
        .sign_mask  (dmem_be),
        .wfi        (wfi),
        .read_data  (dmem_rdata),
        .led        (led)
    );
endmodule
