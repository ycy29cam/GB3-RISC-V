`timescale 1ns/1ps

module tb_branch_predictor;

    reg clk;
    reg [31:0] fetch_pc;
    reg update_en;
    reg [31:0] update_pc;
    reg [31:0] update_target;
    wire [31:0] branch_addr;
    wire prediction;
    integer i;
    
    // Instantiate the branch predictor
    branch_predictor uut (
        .clk(clk),
        .fetch_pc(fetch_pc),
        .branch_addr(branch_addr),
        .prediction(prediction),
        .update_en(update_en),
        .update_pc(update_pc),
        .update_target(update_target)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (period 10ns)
        
    end

    initial begin
        // Initialize signals
        fetch_pc = 0;
        update_en = 0;
        update_pc = 0;
        update_target = 0;

        // Add waveform dump for GTKWave
        $dumpfile("branch_predictor_tb.vcd");
        $dumpvars(0, tb_branch_predictor);

        // Test 1: Predict for PC not in BTB
        #10 fetch_pc = 32'h00001000;  // Prediction should be PC+4
        #10;

        // Test 2: Add a branch entry at 0x1000 -> 0x2000
        update_pc = 32'h00001000;
        update_target = 32'h00002000;
        update_en = 1;
        #10 update_en = 0;

        // Test 3: Predict for 0x1000 (should hit with target 0x2000)
        #10 fetch_pc = 32'h00001000;
        #10;

        // Test 4: Add another entry at 0x3000 -> 0x4000
        update_pc = 32'h00003000;
        update_target = 32'h00004000;
        update_en = 1;
        #10 update_en = 0;

        // Test 5: Predict for 0x3000
        #10 fetch_pc = 32'h00003000;
        #10;

        // Test 6: Predict for 0x5000 (no entry, predict PC+4)
        #10 fetch_pc = 32'h00005000;
        #10;

        // Test 7: Update same PC 0x1000 with new target 0x2100 (overwrite)
        update_pc = 32'h00001000;
        update_target = 32'h00002100;
        update_en = 1;
        #10 update_en = 0;

        // Predict for 0x1000 (should reflect new target 0x2100)
        #10 fetch_pc = 32'h00001000;
        #10;

        // Test 8: Insert multiple entries to test LRU replacement
        for (i = 0; i < 5; i = i + 1) begin
            update_pc = 32'h00006000 + (i * 4);
            update_target = 32'h00007000 + (i * 4);
            update_en = 1;
            #10 update_en = 0;
        end

        // Predict for the first inserted entry (might be replaced if BTB is small)
        #10 fetch_pc = 32'h00006000;
        #10;

        // Done
        #50 $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | fetch_pc=0x%08h | prediction=%b | branch_addr=0x%08h | update_en=%b update_pc=0x%08h update_target=0x%08h",
                  $time, fetch_pc, prediction, branch_addr, update_en, update_pc, update_target);
    end

endmodule
