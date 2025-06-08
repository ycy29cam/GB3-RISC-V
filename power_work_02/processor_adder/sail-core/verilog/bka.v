module black  (output Gout, Pout, input Gk, Pk, Gj, Pj);
    wire t;
    and a1 (t , Pk , Gj);
    or  o1 (Gout , Gk , t);
    and a2 (Pout , Pk , Pj);
endmodule

module grey   (output Gout,        input Gk, Pk, Gj);
    wire t;
    and a1 (t , Pk , Gj);
    or  o1 (Gout , Gk , t);
endmodule


/* ============================================================
 *  32-bit Brent–Kung parallel-prefix adder
 * ============================================================
 */
module brent_kung32
(
    input  wire [31:0] a ,
    input  wire [31:0] b ,
    output wire [31:0] sum,
    output wire        cout
);
    /* leaf propagate / generate ------------------------------ */
    wire [31:0] P, G;
    genvar i;
    generate
        for (i=0; i<32; i=i+1) begin : pg
            xor xo (P[i] , a[i] , b[i]);
            and an (G[i] , a[i] , b[i]);
        end
    endgenerate

    /* --------------------------------------------------------
     * Brent-Kung prefix network
     * Levels: 1-2-3-4-5-6 = log2(32)
     * Nodes named gn[k],pn[k] where n = level
     * ------------------------------------------------------ */
    /* level 1 : span 1 */
    wire [31:1] g1, p1;
    generate
        for (i=1; i<32; i=i+2) begin
            black b1 (g1[i], p1[i], G[i], P[i], G[i-1], P[i-1]);
        end
    endgenerate

    /* level 2 : span 2 */
    wire [31:3] g2, p2;
    generate
        for (i=3; i<32; i=i+4) begin
            black b2 (g2[i], p2[i], g1[i], p1[i], g1[i-2], p1[i-2]);
        end
    endgenerate

    /* level 3 : span 4 */
    wire [31:7] g3, p3;
    generate
        for (i=7; i<32; i=i+8) begin
            black b3 (g3[i], p3[i], g2[i], p2[i], g2[i-4], p2[i-4]);
        end
    endgenerate

    /* level 4 : span 8 */
    wire [31:15] g4;
    generate
        for (i=15; i<32; i=i+16) begin
            grey g4cell (g4[i], g3[i], p3[i], g3[i-8]);
        end
    endgenerate

    /* level 5 : span 16 (only one needed for 32-bit) */
    wire g5;
    grey g5cell (g5, g4[31], p3[31], g4[15]);

    /* --------- downward (grey) fan-out --------------------- */
    wire [31:0] C;  // carry into bit i (C0 = 0)
    assign C[0]=1'b0;

    /* helper function: produce grey cells for required nodes */
    // level 4 fan-out
    grey g4a (C[16], g3[17], p3[17], g3[15]);
    grey g4b (C[24], g3[25], p3[25], g3[23]);

    // level 3 fan-out
    grey g3a (C[8] , g2[9] , p2[9] , g2[7]);
    grey g3b (C[12], g2[13], p2[13], g2[11]);
    grey g3c (C[20], g2[21], p2[21], g2[19]);
    grey g3d (C[28], g2[29], p2[29], g2[27]);

    // level 2 fan-out
    generate
        for (i=2; i<32; i=i+4) begin : l2grey
            grey g2cell (C[i], g1[i+1], p1[i+1], g1[i-1]);
        end
    endgenerate

    // level 1 carries
    generate
        for (i=1; i<32; i=i+2) begin : l1grey
            grey g1cell (C[i], G[i], P[i], C[i-1]);
        end
    endgenerate

    assign C[32] = g5;          // final carry out
    assign cout  = C[32];

    /* ----------------- final sum --------------------------- */
    generate
        for (i=0;i<32;i=i+1) begin : sumbits
            xor xs (sum[i], P[i], C[i]);
        end
    endgenerate
endmodule