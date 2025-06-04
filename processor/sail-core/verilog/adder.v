module adder(
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] out
);

    wire [31:0] O;

	adder_dsp dsp_inst (
        .input1(input1),
        .input2(input2),
        .is_sub(0),
        .out(O)
    );

    assign out = O;  // O[31:0] is the full 32-bit result

endmodule