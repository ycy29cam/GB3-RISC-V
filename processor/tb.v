`define SIMULATION
`timescale 1ns/1ps

module tb;
  reg clk;
  reg [63:0] cycle_count = 0;
  reg [31:0] mis_predicted = 0;
  reg [31:0] mis_jump = 0;


  top uut ();
  assign uut.clk = clk;


  initial clk = 0;
  always #5 clk = ~clk;

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    // commit-mask: branch instruction in MEM stage
    if (uut.processor.ex_mem_out[6]) begin       // commit this cycle

        // wrong-direction 1: predicted TAKEN, actually NOT-TAKEN
        if (uut.processor.branch_decide.Mispredict)
            mis_predicted <= mis_predicted + 1;

        // wrong-direction 2: predicted NOT-TAKEN, actually TAKEN
        // (exclude unconditional Jump pulses)
        if (uut.processor.branch_decide.Branch_Jump_Trigger)
            mis_jump <= mis_jump + 1;
    end
  end

  initial begin
    $dumpfile("wave.fst");
    $dumpvars(1, tb.uut.processor.branch_predictor_FSM);
    $dumpvars(2, tb);

    $writememh("before.hex", tb.uut.data_mem_inst.data_block);
    #2000000000;
    $finish;
  end
endmodule
