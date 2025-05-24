module branch_target_buffer(
    input         clk,
    input         reset,
    input [31:0]  pc_in,           // PC in Fetch stage
    input         update,          // Update BTB entry when branch resolved
    input [31:0]  branch_pc,       // Resolved branch PC (from MEM stage)
    input [31:0]  target_addr,     // Resolved branch target
    output reg    hit,             // BTB hit signal
    output reg [31:0] predicted_target // Predicted target address
);
    parameter BTB_SIZE = 16;

    reg [31:0] btb_pc [0:BTB_SIZE-1];      // Stores PC of branches
    reg [31:0] btb_target [0:BTB_SIZE-1];  // Stores target addresses
    reg        btb_valid [0:BTB_SIZE-1];   // Valid bits

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                btb_pc[i] <= 32'b0;
                btb_target[i] <= 32'b0;
                btb_valid[i] <= 1'b0;
            end
        end else if (update) begin
            btb_pc[branch_pc[5:2]] <= branch_pc;
            btb_target[branch_pc[5:2]] <= target_addr;
            btb_valid[branch_pc[5:2]] <= 1'b1;
        end
    end

    always @(*) begin
        if (btb_valid[pc_in[5:2]] && btb_pc[pc_in[5:2]] == pc_in) begin
            hit = 1'b1;
            predicted_target = btb_target[pc_in[5:2]];
        end else begin
            hit = 1'b0;
            predicted_target = pc_in + 4; // Default next PC
        end
    end
endmodule
