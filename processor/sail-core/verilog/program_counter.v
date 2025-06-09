module program_counter #(
    parameter RESET_VAL = 32'b0
)(
    input        clk,               // CPU clock
    input        branch_i,          // take the branch/jump target
    input  [31:0] branch_target_i,  // computed by addr_adder
    input        fence_i,           // FENCE.I replay
    output [31:0] pc_o              // current PC for fetch
);

    reg [31:0] pc_o;
    reg [31:0] pc_next;

    // combinational next-PC logic
    always @(*) begin
        if (branch_i)
            pc_next = branch_target_i;  // redirect on BNE/BEQ/JAL/JALR
        else if (fence_i)
            pc_next = pc_o;             // replay same PC
        else
            pc_next = pc_o + 32'b100;     // normal sequential +4
    end

    // register update
    initial begin
        pc_o = RESET_VAL;
    end

    always @(posedge clk) begin
        pc_o <= pc_next;
    end

endmodule