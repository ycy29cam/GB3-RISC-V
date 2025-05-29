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
 *		Branch Predictor FSM
 */

module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	/*
	 *	inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	outputs
	 */
	output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	internal state
	 */
	reg [1:0]	s;

	reg		branch_mem_sig_reg;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		s = 2'b00;
		branch_mem_sig_reg = 1'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
			s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
		end
	end

	wire [31:0] dsp_sum;
	SB_MAC16 dsp_branch_addr (
		.A(in_addr[15:0]),
		.B(offset[15:0]),
		.C(in_addr[31:16]),
		.D(offset[31:16]),
		.O(dsp_sum),
		.CLK(clk),
		.CE(1'b1),
		.ADDSUBTOP(1'b0),  // Add
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
	defparam dsp_branch_addr.TOPOUTPUT_SELECT = 2'b00;
	defparam dsp_branch_addr.BOTOUTPUT_SELECT = 2'b00;
	defparam dsp_branch_addr.A_SIGNED = 1'b0;
	defparam dsp_branch_addr.B_SIGNED = 1'b0;

	assign branch_addr = dsp_sum;
	assign prediction = s[1] & branch_decode_sig;
endmodule
