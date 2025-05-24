module branch_decision(
    input Branch,                     // Control signal: branch instruction
    input Predicted,                  // BTB prediction signal (from branch_predictor)
    input Branch_Enable,              // ALU branch enable (from EX)
    input Jump,                       // Control signal: jump instruction
    output reg Mispredict,            // New: misprediction flag
    output reg Decision,              // Actual branch decision
    output reg Branch_Jump_Trigger    // Existing: PC select
);

    always @(*) begin
        // Determine if actual branch or jump should be taken
        Decision = (Branch & Branch_Enable) | Jump;

        // PC selection: take branch or jump
        Branch_Jump_Trigger = Decision;

        // Compare prediction to actual outcome
        if (Predicted != Decision)
            Mispredict = 1'b1;       // Prediction was wrong
        else
            Mispredict = 1'b0;       // Prediction correct
    end
endmodule
