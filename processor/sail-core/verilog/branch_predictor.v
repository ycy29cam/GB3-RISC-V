module branch_predictor(
    input         clk,
    input         reset,
    input         actual_branch_decision,
    input         branch_decode_sig,
    input         branch_mem_sig,
    input [31:0]  in_addr,
    input [31:0]  offset,
    output [31:0] branch_addr,
    output        prediction
);

    wire hit;
    wire [31:0] predicted_target;

    branch_target_buffer btb (
        .clk(clk),
        .reset(reset),
        .pc_in(in_addr),
        .update(branch_mem_sig), // Update BTB when branch resolves
        .branch_pc(in_addr),     // Resolved branch PC
        .target_addr(in_addr + offset), // Target computed in MEM
        .hit(hit),
        .predicted_target(predicted_target)
    );

    // Combine BTB hit with decode signal
    assign branch_addr = predicted_target;
    assign prediction = hit & branch_decode_sig;

endmodule
