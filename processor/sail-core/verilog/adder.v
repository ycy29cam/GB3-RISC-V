// // 3 adders can be used wherever

// module dsp_adder(
//     input [31:0] input1,
//     input [31:0] input2,
//     output [31:0] out
// );
//     wire [31:0] O;
// 	adder_dsp dsp_inst (
//         .input1(input1),
//         .input2(input2),
//         .is_sub(0),
//         .out(out)
//     );

//     assign out = O;  // O[31:0] is the full 32-bit result
// endmodule

// module dsp_subtractor(
//     input [31:0] input1,
//     input [31:0] input2,
//     output [31:0] out
// );
//     wire [31:0] O;
// 	adder_dsp dsp_inst (
//         .input1(input1),
//         .input2(input2),
//         .is_sub(1),
//         .out(O)
//     );

//     assign out = O;  // O[31:0] is the full 32-bit result
// endmodule

// module dsp_addsub(
//     input [31:0] input1,
//     input [31:0] input2,
//     input is_sub,
//     output [31:0] out
// );
//     wire [31:0] O;
// 	adder_dsp dsp_inst (
//         .input1(input1),
//         .input2(input2),
//         .is_sub(is_sub),
//         .out(O)
//     );

//     assign out = O;  // O[31:0] is the full 32-bit result
// endmodule

module adder(input1, input2, out);
	input [31:0]	input1;
	input [31:0]	input2;
	output [31:0]	out;

	assign		out = input1 + input2;
endmodule

module full_adder(carry_in, input1, input2, out);
	input		carry_in;
	input [31:0]	input1;
	input [31:0]	input2;
	output [31:0]	out;

	assign		out = input1 + input2 + carry_in;
endmodule