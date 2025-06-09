module program_counter #(
    parameter RESET_VAL = 32'b0
)(
    input        clk,
    // NEW highest-priority replay on mis-predict
    input        replay_i,            // asserted one cycle when predictor wrong
    input  [31:0] replay_addr_i,      // usually ID/EX.pc_plus4
    // existing branch and fence controls
    input        branch_i,
    input  [31:0] branch_target_i,
    input        fence_i,
    output [31:0] pc_o,
    output [31:0] pc_plus4_o
);
    reg [31:0] pc_o, pc_next;

    assign pc_plus4_o = pc_o + 32'b100;

    always @(*) begin
        if      (replay_i)   pc_next = replay_addr_i;   // (1) mis-predict fix-up
        else if (branch_i)   pc_next = branch_target_i; // (2) real taken branch
        else if (fence_i)    pc_next = pc_o;            // (3) replay same PC
        else                 pc_next = pc_plus4_o;      // (4) sequential +4
    end

    initial pc_o = RESET_VAL;
	always @(posedge clk) begin
        pc_o <= pc_next;
    end
endmodule
