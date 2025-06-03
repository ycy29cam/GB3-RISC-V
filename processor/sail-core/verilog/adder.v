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



// module adder(input1, input2, out);
// 	input [31:0]	input1;
// 	input [31:0]	input2;
// 	output [31:0]	out;

// 	assign		out = input1 + input2;

// endmodule


/* (new)
  *	Adder using the SB_MAC16 primitive.
  *	This is a 32-bit adder that can perform addition or subtraction depending on the is_sub input.
*/

module adder(input1, input2, out);
	input [31:0]	input1;
	input [31:0]	input2;
	output [31:0]	out;

	assign		out = input1 + input2;
// endmodule
  
// `ifdef SIMULATION
//   assign out = input1 + input2; // For simulation, use a simple addition
// `else
    // wire [31:0] result;

    // SB_MAC16 mac_inst (
    //   .A(input1[31:16]),            // input1[15:0] (bot), input1[31:16] (top)
    //   .B(input2[15:0]),            // input2[15:0] (bot), input2[31:16] (top)
    //   .C(input2[31:16]),
    //   .D(input1[15:0]),
    //   .O(result),
    //   .CI(1'b0),             // No carry-in
    //   .CO(),        // Final carry-out from top adder

    //   // No clocking / pipelining
    //   .CLK(1'b0),
    //   .CE(1'b1),
    //   .IRSTTOP(1'b0), .IRSTBOT(1'b0),
    //   .ORSTTOP(1'b0), .ORSTBOT(1'b0),
    //   .OLOADTOP(1'b0), .OLOADBOT(1'b0),
    //   .OHOLDTOP(1'b0), .OHOLDBOT(1'b0),
    //   .AHOLD(1'b0), .BHOLD(1'b0),
    //   .CHOLD(1'b0), .DHOLD(1'b0),
    //   .ACCUMCI(1'b0), .ACCUMCO(),
    //   .SIGNEXTIN(1'b0), .SIGNEXTOUT(),
    // .ADDSUBTOP(1'b0), .ADDSUBBOT(1'b0)  
    // );

    // defparam mac_inst.TOPOUTPUT_SELECT        = 2'b00; // direct output (Top Output Select: 00: Adder/Subtractor, not registered)
    // defparam mac_inst.BOTOUTPUT_SELECT        = 2'b00; // direct output (Bottom Output Select:00: Adder/Subtractor, not registered)

    // defparam mac_inst.TOPADDSUB_LOWERINPUT    = 2'b00; // A
    // defparam mac_inst.TOPADDSUB_UPPERINPUT    = 1'b1;  // C
    // defparam mac_inst.TOPADDSUB_CARRYSELECT   = 2'b00; // constant 0

    // defparam mac_inst.BOTADDSUB_LOWERINPUT    = 2'b00; // B
    // defparam mac_inst.BOTADDSUB_UPPERINPUT    = 1'b1;  // D
    // defparam mac_inst.BOTADDSUB_CARRYSELECT   = 2'b00; // constant 0

    // defparam mac_inst.MODE_8x8                = 1'b0;  // disable multiplier
    // defparam mac_inst.A_SIGNED                = 1'b0;
    // defparam mac_inst.B_SIGNED                = 1'b0;

    // assign out = result;
// `endif
endmodule