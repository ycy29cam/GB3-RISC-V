module cla32
(
    input  wire [31:0] a ,
    input  wire [31:0] b ,
    output wire [31:0] sum,
    output wire        cout
);

    /* ---------------- bit propagate / generate -------------- */
    wire [31:0] p, g;            // p = a ^ b ,  g = a & b
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_pg
            xor  x1 (p[i] , a[i] , b[i]);
            and  a1 (g[i] , a[i] , b[i]);
        end
    endgenerate

    /* ---------------- 4-bit group P/G ----------------------- */
    wire [7:0] PG, GG;           // 8 groups of 4 bits
    generate
        for (i = 0; i < 8; i = i + 1) begin : grp_pg
            wire p3,p2,p1,p0,g3,g2,g1,g0,t0,t1,t2;

            assign p3 = p[i*4+3];  assign g3 = g[i*4+3];
            assign p2 = p[i*4+2];  assign g2 = g[i*4+2];
            assign p1 = p[i*4+1];  assign g1 = g[i*4+1];
            assign p0 = p[i*4+0];  assign g0 = g[i*4+0];

            /* group propagate */
            and a2 (t0 , p3 , p2);
            and a3 (t1 , t0 , p1);
            and a4 (PG[i] , t1 , p0);

            /* group generate */
            wire w0,w1,w2;
            and a5 (w0 , p3 , g2);
            and a6 (w1 , p3 , p2 , g1);
            and a7 (w2 , p3 , p2 , p1 , g0);
            or  o1 (GG[i] , g3 , w0 , w1 , w2);
        end
    endgenerate

    /* --------------- carry look-ahead network --------------- */
    wire [8:0] Cg;               // group carries (Cg[0] = cin = 0)
    assign Cg[0] = 1'b0;
    generate
        for (i = 0; i < 8; i = i + 1) begin : grp_carry
            wire w;
            and a8 (w , PG[i] , Cg[i]);
            or  o2 (Cg[i+1] , GG[i] , w);
        end
    endgenerate
    assign cout = Cg[8];

    /* --------------- bit carries ---------------------------- */
    wire [32:0] Cb;              // Cb[0] = cin = 0
    assign Cb[0] = 1'b0;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_carry
            if (i % 4 == 0)
                assign Cb[i] = Cg[i/4];         // pick group carry
            wire w;
            and a9  (w , p[i] , Cb[i]);
            or  o3  (Cb[i+1] , g[i] , w);
        end
    endgenerate

    /* ---------------- final sum ----------------------------- */
    generate
        for (i = 0; i < 32; i = i + 1) begin : bit_sum
            xor x2 (sum[i] , p[i] , Cb[i]);
        end
    endgenerate
endmodule