module short_pc(inAddr, outAddr, clk);
	input			clk;
	input [29:0]		inAddr;
	output reg[29:0]	outAddr;

	initial begin
		outAddr = 30'b0;
	end

	always @(posedge clk) begin
		outAddr <= inAddr;
	end
endmodule