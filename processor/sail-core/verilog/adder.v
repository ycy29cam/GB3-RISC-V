/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



/*
 *	Description:
 *
 *		This module implements an adder for use by the branch unit
 *		and program counter increment among other things.
 */



module adder(
    input [31:0] input1,
    input [31:0] input2,
    input clk,              // Clock required for DSP
    output [31:0] out
);

    wire [31:0] dsp_sum;
    wire [31:0] O;

    SB_MAC16 dsp_adder (
        .A(input1[15:0]),
        .B(input2[15:0]),
        .C(input1[31:16]),
        .D(input2[31:16]),
        .O(O),
        .CLK(clk),
        .CE(1'b1),
        .ADDSUBTOP(1'b0),       // Add operation
        .ADDSUBBOT(1'b0),
        .OLOADTOP(1'b0),
        .OLOADBOT(1'b0),
        .OHOLDTOP(1'b0),
        .OHOLDBOT(1'b0),
        .CI(1'b0),
        .CO(),
        .ACCUMCI(1'b0),
        .ACCUMCO(),
        .SIGNEXTIN(1'b0),
        .SIGNEXTOUT()
    );

    // Configuration for Single 32-bit Adder mode
    defparam dsp_adder.TOPOUTPUT_SELECT = 2'b00;   // Top: Adder output
    defparam dsp_adder.BOTOUTPUT_SELECT = 2'b00;   // Bottom: Adder output
    defparam dsp_adder.A_SIGNED = 1'b0;
    defparam dsp_adder.B_SIGNED = 1'b0;

    assign out = O;  // O[31:0] is the full 32-bit result

endmodule
