module instruction_memory(addr, out);
	input [31:0]		addr;
	output [31:0]		out;

	reg [31:0]		instruction_memory[0:2**12-1];

	/*
	 *	According to the "iCE40 SPRAM Usage Guide" (TN1314 Version 1.0), page 5:
	 *
	 *		"SB_SPRAM256KA RAM does not support initialization through device configuration."
	 *
	 *	The only way to have an initializable memory is to use the Block RAM.
	 */
	initial begin
		/*
		 *	read from "program.hex" and store the instructions in instruction memory
		 */
		$readmemh("verilog/program.hex",instruction_memory);
	end

	assign out = instruction_memory[addr >> 2];
endmodule
