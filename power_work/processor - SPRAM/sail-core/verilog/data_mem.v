// -----------------------------------------------------------------------------
// Data memory – read / write, byte-enable, Stand-by on WFI
// -----------------------------------------------------------------------------
module data_mem (
    input  wire         clk,
    input  wire [31:0]  addr,
    input  wire [31:0]  write_data,
    input  wire         memwrite,
    input  wire         memread,
    input  wire [3:0]   sign_mask,     // byte enables
    input  wire         wfi,
    output wire [31:0]  read_data,
    output wire [7:0]   led            // LED mapped at 0x2000
);
    //---------------------------------------------------------------
    wire [15:0] d_addr = addr[17:2];   // word address
    wire [31:0] dout;

    spram_wrap dmem (
        .clk   (clk),
        .sel   (memread | memwrite),
        .we    (memwrite),
        .be    (sign_mask),
        .addr  (d_addr),
        .din   (write_data),
        .dout  (dout),
        .ls_req(wfi),                 // Stand-by on CPU idle
        .ds_req(1'b0)                 // keep wake penalty 1 cycle
    );
    assign read_data = dout;

    //---------------- LED register at address 0x2000 ----------------
    reg [31:0] led_reg /* synthesis preserve */;
    always_ff @(posedge clk)
        if (memwrite && addr==32'h2000) led_reg <= write_data;

    assign led = led_reg[7:0];
endmodule
