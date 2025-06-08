module clk_div3(
    input    wire  clk_in,
    output   wire  clk_out
    );
 
  reg [1:0] pos_count, neg_count;

  initial begin
    pos_count = 0;
    neg_count = 0;
  end

  always @(posedge clk_in) begin
    if (pos_count ==2) pos_count <= 0;
    else pos_count<= pos_count +1;
  end

  always @(negedge clk_in) begin
    if (neg_count ==2) neg_count <= 0;
    else neg_count<= neg_count +1;
  end

  assign clk_out = ((pos_count == 2) | (neg_count == 2));
endmodule