

module dataMem_mask_gen(func3, sign_mask);
	input [2:0]	func3;
	output [3:0]	sign_mask;

	reg [2:0]	mask;

	/*
	 *	sign - for LBU and LHU the sign bit is 0, indicating read data should be zero extended, otherwise sign extended
	 *	mask - for determining if the load/store operation is on word, halfword or byte
	 *
	 *	TODO - a Karnaugh map should be able to describe the mask without case, the case is for reading convenience
	*/

	always @(*) begin
		case(func3[1:0])
			2'b00: mask = 3'b001;	// byte only
			2'b01: mask = 3'b011;	// halfword
			2'b10: mask = 3'b111;	// word
			default: mask = 3'b000;	// should not happen for loads/stores
		endcase
	end

	assign sign_mask = {(~func3[2]), mask};
endmodule


// module sign_mask_gen(
//     input  [2:0] func3,
//     output [3:0] sign_mask
// );
//     // One-hot encoded types
//     wire is_lb  = (func3 == 3'b000);  // Load Byte
//     wire is_lh  = (func3 == 3'b001);  // Load Halfword
//     wire is_lw  = (func3 == 3'b010);  // Load Word
//     wire is_lbu = (func3 == 3'b100);  // Load Byte Unsigned
//     wire is_lhu = (func3 == 3'b101);  // Load Halfword Unsigned

//     // Each of these contributes to one-hot control for size & signedness
//     wire [3:0] lb_mask  = is_lb  ? 4'b1001 : 4'b0000;
//     wire [3:0] lh_mask  = is_lh  ? 4'b1011 : 4'b0000;
//     wire [3:0] lw_mask  = is_lw  ? 4'b1111 : 4'b0000;
//     wire [3:0] lbu_mask = is_lbu ? 4'b0001 : 4'b0000;
//     wire [3:0] lhu_mask = is_lhu ? 4'b0011 : 4'b0000;

//     // Final result using XOR of one-hot sources
//     assign sign_mask = lb_mask ^ lh_mask ^ lw_mask ^ lbu_mask ^ lhu_mask;

// endmodule
