/*
    Authored 2018-2019, Ryan Voo.
*/

/*
    Optimised ALU — one–hot-gated results + XOR reduction
    Keeps original I/O ports for seamless integration.
*/
`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

module alu(
    input  [6:0]  ALUctl,          // {branch[6:4], op[3:0]}
    input  [31:0] A,
    input  [31:0] B,
    output wire [31:0] ALUOut, // ALU result
    // output reg [31:0] ALUOut,
    // output reg       Branch_Enable
    output wire       Branch_Enable // Branch condition result
);

    //------------------------------------------------------------------
    // 1. Local one-hot decode (keep until the ID stage supplies one-hot)
    //------------------------------------------------------------------
    wire op_and   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND);
    wire op_or    = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR);
    wire op_add   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD);
    wire op_sub   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB);
    wire op_slt   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT);
    wire op_srl   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL);
    wire op_sra   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA);
    wire op_sll   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL);
    wire op_xor   = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR);
    wire op_csrrw = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW);
    wire op_csrrs = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS);
    wire op_csrrc = (ALUctl[3:0] == `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC);

    //------------------------------------------------------------------
    // 2. Shared add/sub datapath (swap in your DSP instance if desired)
    //------------------------------------------------------------------
    wire [31:0] add_raw;
    assign add_raw = op_sub ? (A - B) : (A + B);
    // Example DSP instance:
    // adder_dsp u_dsp (.input1(A), .input2(B), .is_sub(op_sub), .out(add_raw));

    //------------------------------------------------------------------
    // 3. Gate every candidate result with its one-hot bit
    //------------------------------------------------------------------
    wire [31:0] w_and   = op_and   ? (A &  B)                         : 32'h0;
    wire [31:0] w_or    = op_or    ? (A |  B)                         : 32'h0;
    wire [31:0] w_add   = op_add   ?  add_raw                       : 32'h0;
    wire [31:0] w_sub   = op_sub   ?  add_raw                         : 32'h0;
    wire [31:0] w_slt   = op_slt   ? (($signed(A) <  $signed(B)) ? 32'h1 : 32'h0) : 32'h0;
    wire [31:0] w_srl   = op_srl   ? (A >>  B[4:0])                   : 32'h0;
    wire [31:0] w_sra   = op_sra   ? ($signed(A) >>> B[4:0])          : 32'h0;
    wire [31:0] w_sll   = op_sll   ? (A <<  B[4:0])                   : 32'h0;
    wire [31:0] w_xor   = op_xor   ? (A ^  B)                         : 32'h0;
    wire [31:0] w_csrrw = op_csrrw ?  A                               : 32'h0;
    wire [31:0] w_csrrs = op_csrrs ? (A |  B)                         : 32'h0;
    wire [31:0] w_csrrc = op_csrrc ? ((~A) & B)                       : 32'h0;

    //------------------------------------------------------------------
    // 4. XOR-reduction replaces the old wide multiplexer
    //------------------------------------------------------------------
    wire [31:0] alu_res =
           w_and ^ w_or  ^ w_add ^ w_sub ^
           w_slt ^ w_srl ^ w_sra ^ w_sll ^
           w_xor ^ w_csrrw ^ w_csrrs ^ w_csrrc;

    // Keep output port type (reg) unchanged
    assign ALUOut = alu_res;

    //------------------------------------------------------------------
    // 5. Branch condition logic – unchanged
    //------------------------------------------------------------------

    wire br_beq  = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ);
    wire br_bne  = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE);
    wire br_blt  = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT);
    wire br_bge  = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE);
    wire br_bltu = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU);
    wire br_bgeu = (ALUctl[6:4] == `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU);

    //---------------------------------------------------------------
    //  individual branch predicates (32-bit comparisons)
    //---------------------------------------------------------------
    wire take_beq  = br_beq  & (ALUOut == 32'h0);                // result of SUB == 0
    wire take_bne  = br_bne  & (ALUOut != 32'h0);
    wire take_blt  = br_blt  & ($signed(A) <  $signed(B));
    wire take_bge  = br_bge  & ($signed(A) >= $signed(B));
    wire take_bltu = br_bltu & (A <  B);                         // unsigned
    wire take_bgeu = br_bgeu & (A >= B);


    assign Branch_Enable = take_beq  | take_bne  | take_blt | take_bge  | take_bltu | take_bgeu;
    // always @* begin
    //     case (ALUctl[6:4])
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ : Branch_Enable = (ALUOut == 0);
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE : Branch_Enable = (ALUOut != 0);
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT : Branch_Enable = ($signed(A) <  $signed(B));
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE : Branch_Enable = ($signed(A) >= $signed(B));
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable = (A < B);
    //         `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable = (A >= B);
    //         default                                  : Branch_Enable = 1'b0;
    //     endcase
    // end
endmodule



/* Baseline (use case which get sythesised into MUX)*/


// `include "../include/rv32i-defines.v"
// `include "../include/sail-core-defines.v"

// module alu(
//     input  [6:0]  ALUctl,
//     input  [31:0] A,
//     input  [31:0] B,
//     output reg [31:0] ALUOut,
//     output reg       Branch_Enable
// );

//     // DSP adder outputs
//     wire [31:0] dsp_add;
//     wire [31:0] dsp_sub;

//     // // Instantiate the DSP-based add/sub units
//     // adder_dsp adder_add (
//     //     .input1(A),
//     //     .input2(B),
//     //     .is_sub(1'b0),
//     //     .out(dsp_add)
//     // );

//     // adder_dsp adder_sub (
//     //     .input1(A),
//     //     .input2(B),
//     //     .is_sub(1'b1),
//     //     .out(dsp_sub)
//     // );

//     // ALU Results
//     always @* begin
//         case (ALUctl[3:0])
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:  ALUOut = A & B;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:   ALUOut = A | B;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:  ALUOut = A + B;//dsp_add;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:  ALUOut = A - B;//dsp_sub;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:  ALUOut = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:  ALUOut = A >> B[4:0];
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:  ALUOut = $signed(A) >>> B[4:0];
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:  ALUOut = A << B[4:0];
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:  ALUOut = A ^ B;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:ALUOut = A;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:ALUOut = A | B;
//             `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:ALUOut = (~A) & B;
//             default:                                  ALUOut = 32'b0;
//         endcase
//     end

//     // Branch condition evaluation
//     always @* begin
//         case (ALUctl[6:4])
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  Branch_Enable = (ALUOut == 0);
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  Branch_Enable = (ALUOut != 0);
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  Branch_Enable = ($signed(A) < $signed(B));
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  Branch_Enable = ($signed(A) >= $signed(B));
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: Branch_Enable = (A < B);
//             `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: Branch_Enable = (A >= B);
//             default:                                  Branch_Enable = 1'b0;
//         endcase
//     end

// endmodule


