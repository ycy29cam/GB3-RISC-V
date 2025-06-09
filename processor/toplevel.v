module top (led);
	output [7:0]	led;

	wire		clk_proc;
	wire		data_clk_stall;
	
	wire 		locked;
	wire		clk_hf;
	wire 		clk_pll;
	reg		ENCLKHF		= 1'b1;	// Plock enable
	reg		CLKHF_POWERUP	= 1'b1;	// Power up the HFOSC circuit


	/*
	 *	Use the iCE40's hard primitive for the clock source.
	 */
	SB_HFOSC #(.CLKHF_DIV("0b11")) OSCInst0 (
		.CLKHFEN(ENCLKHF),
		.CLKHFPU(CLKHF_POWERUP),
		.CLKHF(clk_hf)
	);

	SB_PLL40_CORE #(
			.FEEDBACK_PATH("SIMPLE"),
			.DIVR(4'b0000),		// DIVR =  0
			.DIVF(7'b0111111),	// DIVF = 63
			.DIVQ(3'b100),		// DIVQ =  4
			.FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
		) uut (
			.LOCK(locked),
			.RESETB(1'b1),
			.BYPASS(1'b0),
			.REFERENCECLK(clk_hf),
			.PLLOUTCORE(clk_pll)
	);

	/*
	 *	Memory interface
	 */
	wire[31:0]	inst_in;
	wire[31:0]	inst_out;
	wire[31:0]	data_out;
	wire[31:0]	data_addr;
	wire[31:0]	data_WrData;
	wire		data_memwrite;
	wire		data_memread;
	wire[3:0]	data_sign_mask;


	cpu processor(
		.clk(clk_proc),
		.inst_mem_in(inst_in),
		.inst_mem_out(inst_out),
		.data_mem_out(data_out),
		.data_mem_addr(data_addr),
		.data_mem_WrData(data_WrData),
		.data_mem_memwrite(data_memwrite),
		.data_mem_memread(data_memread),
		.data_mem_sign_mask(data_sign_mask)
	);

	instruction_memory inst_mem( 
		.addr(inst_in), 
		.out(inst_out)
	);

	data_mem data_mem_inst(
			.clk(clk_pll),
			.addr(data_addr),
			.write_data(data_WrData),
			.memwrite(data_memwrite), 
			.memread(data_memread), 
			.read_data(data_out),
			.sign_mask(data_sign_mask),
			.led(led),
			.clk_stall(data_clk_stall)
		);

	assign clk_proc = (data_clk_stall) ? 1'b1 : clk_pll;
endmodule
