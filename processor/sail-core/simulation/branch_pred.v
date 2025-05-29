module branch_predictor (
    input clk,
    input [31:0] fetch_pc,
    output reg [31:0] branch_addr,
    output reg prediction,
    input update_en,
    input [31:0] update_pc,
    input [31:0] update_target
);
    parameter BTB_SIZE = 16;
    parameter ASSOC = 4;

    reg [31:0] btb_pc [0:BTB_SIZE-1][0:ASSOC-1];
    reg [31:0] btb_target [0:BTB_SIZE-1][0:ASSOC-1];
    reg btb_valid [0:BTB_SIZE-1][0:ASSOC-1];
    reg [1:0] lru_counter [0:BTB_SIZE-1];

    integer w;              // Loop/index variable
    integer lru_way;        // LRU way to replace
    integer match_found;    // Match detection flag

    always @(posedge clk) begin
        if (update_en) begin
            match_found = 0;
            for (w = 0; w < ASSOC; w = w + 1) begin
                if (btb_valid[update_pc[5:2]][w] && btb_pc[update_pc[5:2]][w] == update_pc) begin
                    btb_target[update_pc[5:2]][w] <= update_target;
                    match_found = 1;
                end
            end
            if (!match_found) begin
                lru_way = lru_counter[update_pc[5:2]];
                btb_pc[update_pc[5:2]][lru_way] <= update_pc;
                btb_target[update_pc[5:2]][lru_way] <= update_target;
                btb_valid[update_pc[5:2]][lru_way] <= 1'b1;
                lru_counter[update_pc[5:2]] <= (lru_counter[update_pc[5:2]] + 1) % ASSOC;
            end
        end
    end

    reg hit;
    reg [31:0] predicted_target;
    always @(*) begin
        hit = 1'b0;
        predicted_target = fetch_pc + 4;
        for (w = 0; w < ASSOC; w = w + 1) begin
            if (btb_valid[fetch_pc[5:2]][w] && btb_pc[fetch_pc[5:2]][w] == fetch_pc) begin
                hit = 1'b1;
                predicted_target = btb_target[fetch_pc[5:2]][w];
            end
        end
    end

    always @(*) begin
        branch_addr = predicted_target;
        prediction = hit;
    end
endmodule
