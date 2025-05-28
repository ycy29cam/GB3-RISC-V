`define SIMULATION
`timescale 1ns/1ps

module tb;
  reg clk;
  reg [63:0] cycle_count = 0;

  top uut ();
  assign uut.clk = clk;


  initial clk = 0;
  always #5 clk = ~clk;

  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
  end

  initial begin
    $dumpfile("wave.fst");
    $dumpvars(2, tb);
    $writememh("before.hex", tb.uut.data_mem_inst.data_block);
    #2000000000;
    $writememh("after.hex", tb.uut.data_mem_inst.data_block);

    $display("Simulation timed out at cycle %0d", cycle_count);
    $finish;
  end
endmodule
