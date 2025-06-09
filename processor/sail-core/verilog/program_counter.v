// program_counter.v  (Option A, no rst, no stall)
module program_counter #(
    parameter RESET_VAL = 32'b0
)(
    input  logic        clk,
    input  logic        branch_i,         // new: take branch_target_i
    input  logic [31:0] branch_target_i,  // from addr_adder
    output logic [31:0] pc_o              // replaces outAddr
);

    // next‐PC mux
    logic [31:0] pc_next;
    always_comb begin
        if (branch_i)      pc_next = branch_target_i;  
        else                pc_next = pc_o + 32'd4;      // sequential +4
    end

    // PC register, no external reset/stall
    initial pc_o = RESET_VAL;
    always @(posedge clk) begin
        pc_o <= pc_next;
    end
endmodule
