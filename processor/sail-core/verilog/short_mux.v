module short_mux(input0, input1, select, out);
	input [29:0]	input0, input1;
	input		select;
	output [29:0]	out;

	assign out = (select) ? input1 : input0;
endmodule
