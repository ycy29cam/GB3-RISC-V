module cla32(
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] sum,
    output wire        cout
);

  // (1) Bitwise propagate/generate
  wire [31:0] p, g;
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : gen_bit_pg
      xor x1 (p[i], a[i], b[i]);
      and a1 (g[i], a[i], b[i]);
    end
  endgenerate

  // (2) 4-bit group propagate/generate
  wire [7:0] PG, GG;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_group_pg
      wire p3, p2, p1, p0, g3, g2, g1, g0;
      assign p3 = p[i*4 + 3];  assign g3 = g[i*4 + 3];
      assign p2 = p[i*4 + 2];  assign g2 = g[i*4 + 2];
      assign p1 = p[i*4 + 1];  assign g1 = g[i*4 + 1];
      assign p0 = p[i*4 + 0];  assign g0 = g[i*4 + 0];

      wire t0, t1;
      and a2 (t0  , p3, p2);
      and a3 (t1  , t0, p1);
      and a4 (PG[i], t1, p0);

      wire w0, w1, w2;
      and a5 (w0   , p3, g2);
      and a6 (w1   , p3, p2, g1);
      and a7 (w2   , p3, p2, p1, g0);
      or  o1 (GG[i] , g3, w0, w1, w2);
    end
  endgenerate

  // (3) Group carry‐lookahead
  wire [8:0] Cg;
  assign Cg[0] = 1'b0;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_group_carry
      wire w;
      and a8 (w, PG[i], Cg[i]);
      or  o2 (Cg[i+1], GG[i], w);
    end
  endgenerate
  assign cout = Cg[8];

  // (4) Bitwise carries, in two passes
  wire [32:0] Cb;
  assign Cb[0] = 1'b0;

// 4-bit boundary carries
generate
  genvar i;
  for (i = 4; i <= 32; i = i + 4) begin : gen_boundary_cbs
    if (i < 32)
      assign Cb[i] = Cg[i/4];
    else
      assign Cb[32] = Cg[8];
  end
endgenerate

// “Interior” carries: declare `wire w;` unconditionally inside each loop iteration,
// but only instantiate the AND/OR when (i+1)%4 != 0.
generate
  for (i = 0; i < 32; i = i + 1) begin : gen_interior_carry
    wire w;  // ◀─ now Yosys knows “w” is 1 bit, even if gates are skipped

    if ((i + 1) % 4 != 0) begin
      and a9 (w, p[i], Cb[i]);
      or  o3 (Cb[i+1], g[i], w);
    end
    // if (i+1)%4 == 0, `w` simply remains declared (unused) and no gates drive Cb[i+1].
  end
endgenerate

  // (5) Compute final sums
  generate
    for (i = 0; i < 32; i = i + 1) begin : gen_sum
      xor x2 (sum[i], p[i], Cb[i]);
    end
  endgenerate
endmodule
