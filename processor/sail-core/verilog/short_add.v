module short_adder(input1, input2, out);
	input [29:0]	input1;
	input [29:0]	input2;
	output [29:0]	out;

	assign		out = input1 + input2;
endmodule