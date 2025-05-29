module branch_target_buffer (
    input wire clk,
    input wire rst,

    // Fetch stage input
    input wire [31:0] fetch_pc,       // PC of instruction being fetched
    output reg prediction,            // 1: predict taken, 0: predict not-taken
    output reg [31:0] branch_addr,    // Predicted target address

    // Update (resolution) input from EX/MEM
    input wire update_en,             // Enable update (branch resolved)
    input wire [31:0] update_pc,      // PC of branch instruction resolved
    input wire [31:0] update_target,  // Actual target address
    input wire is_branch,             // Is it a branch (not a jump)
    input wire branch_taken           // Was the branch actually taken
);

    parameter SETS = 16;              // Number of sets
    parameter WAYS = 2;               // Number of ways per set
    parameter TAG_BITS = 20;          // Number of PC bits for tag

    // BTB: Stores tags, targets, valid bits
    reg [TAG_BITS-1:0] tag [0:SETS-1][0:WAYS-1];
    reg [31:0] target [0:SETS-1][0:WAYS-1];
    reg valid [0:SETS-1][0:WAYS-1];

    // BHT: 2-bit saturating counters
    reg [1:0] counter [0:SETS-1][0:WAYS-1];

    // Round-robin replacement pointer
    reg [0:0] rr_replace [0:SETS-1];

    integer i, j;

    // Index and tag extraction
    wire [$clog2(SETS)-1:0] fetch_index = fetch_pc[5:2];
    wire [TAG_BITS-1:0] fetch_tag = fetch_pc[31:32-TAG_BITS];

    wire [$clog2(SETS)-1:0] update_index = update_pc[5:2];
    wire [TAG_BITS-1:0] update_tag = update_pc[31:32-TAG_BITS];

    // Initialization and updates
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < SETS; i = i + 1) begin
                rr_replace[i] <= 0;
                for (j = 0; j < WAYS; j = j + 1) begin
                    tag[i][j] <= 0;
                    target[i][j] <= 0;
                    valid[i][j] <= 1'b0;
                    counter[i][j] <= 2'b10;  // Weakly taken
                end
            end
        end else if (update_en && is_branch) begin
            integer match_found = 0;
            for (j = 0; j < WAYS; j = j + 1) begin
                if (valid[update_index][j] && tag[update_index][j] == update_tag) begin
                    match_found = 1;
                    target[update_index][j] <= update_target;
                    if (branch_taken && counter[update_index][j] < 2'b11)
                        counter[update_index][j] <= counter[update_index][j] + 1;
                    else if (!branch_taken && counter[update_index][j] > 2'b00)
                        counter[update_index][j] <= counter[update_index][j] - 1;
                end
            end
            if (!match_found) begin
                integer rr = rr_replace[update_index];
                tag[update_index][rr] <= update_tag;
                target[update_index][rr] <= update_target;
                valid[update_index][rr] <= 1'b1;
                counter[update_index][rr] <= branch_taken ? 2'b11 : 2'b00;
                rr_replace[update_index] <= rr + 1;  // Toggle 0 ↔ 1
            end
        end
    end

    // Prediction logic
    always @(*) begin
        prediction = 1'b0;
        branch_addr = fetch_pc + 4;  // Default: not-taken, next PC
        for (j = 0; j < WAYS; j = j + 1) begin
            if (valid[fetch_index][j] && tag[fetch_index][j] == fetch_tag && counter[fetch_index][j][1] == 1'b1) begin
                prediction = 1'b1;
                branch_addr = target[fetch_index][j];
            end
        end
    end

endmodule
