// module mux2to1(input0, input1, select, out);
// 	input [31:0]	input0, input1;
// 	input		select;
// 	output [31:0]	out;

// 	assign out = (select) ? input1 : input0;
// endmodule


/*
 * 2-to-1 multiplexer, parameter-controlled width
 */
module mux2to1 #(
    parameter integer WIDTH = 32          // 1 ≤ WIDTH ≤ 32
)(
    input  wire [WIDTH-1:0] input0,
    input  wire [WIDTH-1:0] input1,
    input  wire             select,
    output wire [WIDTH-1:0]      out
);

    // core MUX decision on the chosen width
    assign out = select ? input1 : input0;

endmodule