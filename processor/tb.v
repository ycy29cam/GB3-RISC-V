// `define SIMULATION
// `timescale 1ns/1ps

// module tb;
//   reg clk;
//   reg [63:0] cycle_count = 0;
//   reg [31:0] mis_predicted = 0;
//   reg [31:0] mis_jump = 0;


//   top uut ();
//   assign uut.clk = clk;


//   initial clk = 0;
//   always #5 clk = ~clk;

//   initial begin
//     $writememh("before.hex", tb.uut.data_mem_inst.data_block);
//   #2000000;
//     $writememh("after.hex", tb.uut.data_mem_inst.data_block);
//     $finish;
//   end
// endmodule