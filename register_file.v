module regfile(clk, write, wrAddr, wrData, rdAddrA, rdDataA, rdAddrB, rdDataB);
	input			clk;
	input			write;
	input [4:0]		wrAddr;
	input [31:0]	wrData;
	input [4:0]		rdAddrA;
	output [31:0]	rdDataA;
	input [4:0]		rdAddrB;
	output [31:0]	rdDataB;

	wire        we          =  write & (wrAddr != 5'd0);  // block writes to x0
    wire [7:0]  waddr8      = {3'b000, wrAddr};           // EBR is 256 deep
    wire [7:0]  raddrA8     = {3'b000, rdAddrA};
    wire [7:0]  raddrB8     = {3'b000, rdAddrB};

	wire [15:0] rdALo, rdAHi, rdBLo, rdBHi;

	ram ram_lo_A(
		.RDATA(rdALo),
		.raddr(raddrA8),
		.clk(clk),
		.WDATA(wrData[15:0]),
		.waddr(waddr8),
		.write(we),
	);

	ram ram_hi_A(
		.RDATA(rdAHi),
		.raddr(raddrA8),
		.clk(clk),
		.WDATA(wrData[31:16]),
		.waddr(waddr8),
		.write(we),
	);

	ram ram_lo_B(
		.RDATA(rdBLo),
		.raddr(raddrB8),
		.clk(clk),
		.WDATA(wrData[15:0]),
		.waddr(waddr8),
		.write(we),
	);

	ram ram_hi_B(
		.RDATA(rdBHi),
		.raddr(raddrB8),
		.clk(clk),
		.WDATA(wrData[31:16]),
		.waddr(waddr8),
		.write(we),
	);

	/*
	 *	buffer to store address at each positive clock edge
	 */
	reg [4:0]   rdAddrA_buf, rdAddrB_buf, wrAddr_buf;
    reg [31:0]  wrData_buf;
    reg         write_buf;
    reg [31:0]  regDatA, regDatB;

    wire [31:0] memDatA = {rdAHi, rdALo};
    wire [31:0] memDatB = {rdBHi, rdBLo};

	always @(posedge clk) begin
        // write-back forwarding pipeline
        wrAddr_buf   <= wrAddr;
        wrData_buf   <= wrData;
        write_buf    <= write;

        rdAddrA_buf  <= rdAddrA;
        rdAddrB_buf  <= rdAddrB;

        regDatA      <= (rdAddrA == 5'd0) ? 32'd0 : memDatA;
        regDatB      <= (rdAddrB == 5'd0) ? 32'd0 : memDatB;
    end

	assign	rdDataA = ((wrAddr_buf==rdAddrA_buf) & write_buf & wrAddr_buf!=5'b0) ? wrData_buf : regDatA;
	assign	rdDataB = ((wrAddr_buf==rdAddrB_buf) & write_buf & wrAddr_buf!=5'b0) ? wrData_buf : regDatB;
endmodule