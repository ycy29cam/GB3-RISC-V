/* rv32i_benchmark_int_ptr_onebuffer.c
 *
 * – single 64-word array `results[]`
 *     • indices  0 … 32  → push-log (33 pushes incl. sentinel)
 *     • indices 56 … 63  → 8-word scratchpad for load/store tests
 * – pure RV32-I; no other arrays, no standard headers
 */

/* ── verification buffer and pointer-style push ── */
volatile int results[64];
static volatile int *wr_ptr = results;
static inline void push(int v) { *wr_ptr++ = v; }

/* optional counter if your test-bench still uses it */
volatile int results_idx = 0;

/* force jal / jalr */
__attribute__((noinline)) static int add_one(int x) { return x + 1; }

int main(void)
{
    /* ---------- clear the whole 64-word buffer ---------- */
    {
        volatile int *p = results;
        int n = 64;
        while (n--) { *p++ = 0; }
    }

    /* ---------- define an 8-word scratchpad INSIDE results[] ---------- */
    volatile int *scratch = results + 56;   /* uses indices 56 … 63 */

    /* operands */
    int a = 0x12345678;
    int b = 0x0FEDCBA9;
    int tmp;

    /* 1. R-type ALU -------------------------------------------------- */
    push(a + b);                     results_idx++;
    push(a - b);                     results_idx++;
    push(a ^ b);                     results_idx++;
    push(a | b);                     results_idx++;
    push(a & b);                     results_idx++;
    push(a << 3);                    results_idx++;
    push(a >> 5);                    results_idx++;
    push(a >> 5);                    results_idx++;        /* sra == srl (a>0) */
    push(a <  b);                    results_idx++;        /* slt  */
    push((unsigned)a < (unsigned)b); results_idx++;        /* sltu */

    /* 2. I-type immediates ------------------------------------------- */
    push(a + 33);                    results_idx++;
    push(a ^ 0x55);                  results_idx++;
    push(a | 0xAA);                  results_idx++;
    push(a & 0xFFF);                 results_idx++;
    push(a << 7);                    results_idx++;
    push((unsigned)a >> 9);          results_idx++;        /* srli */
    push(a >> 9);                    results_idx++;        /* srai */

    /* 3. LUI / AUIPC ------------------------------------------------- */
    int v_lui;
    __asm__ volatile ("lui   %0, 0x12345" : "=r"(v_lui));
    push(v_lui);                     results_idx++;

    int v_auipc;
    __asm__ volatile ("auipc %0, 0" : "=r"(v_auipc));
    push(v_auipc);                   results_idx++;

    /* 4. Loads & stores (scratchpad lives in results[56-63]) ---------- */
    scratch[0] = a;                  /* sw */
    scratch[1] = b;                  /* sw */

    push(scratch[0]);                results_idx++;

    __asm__ volatile ("lw %0, 4(%1)" : "=r"(tmp) : "r"(scratch));
    push(tmp);                       results_idx++;

    /* byte & half-word stores within the scratchpad */
    *((volatile char  *)scratch +  8) = 0x7B;   /* sb  */
    *((volatile short *)scratch +  5) = 0xABCD; /* sh  */

    char  lbu;  signed char  lb;
    unsigned short lhu;  short lh;

    __asm__ volatile ("lbu %0, 8(%1)"  : "=r"(lbu) : "r"(scratch));
    __asm__ volatile ("lb  %0, 8(%1)"  : "=r"(lb)  : "r"(scratch));
    __asm__ volatile ("lhu %0, 10(%1)" : "=r"(lhu) : "r"(scratch));
    __asm__ volatile ("lh  %0, 10(%1)" : "=r"(lh)  : "r"(scratch));

    push((int)lbu);                  results_idx++;
    push((int)lb);                   results_idx++;
    push((int)lhu);                  results_idx++;
    push((int)lh);                   results_idx++;

    /* 5. Branch outcomes --------------------------------------------- */
    int f;
    f = (a == b);                    push(f); results_idx++;
    f = (a != b);                    push(f); results_idx++;
    f = (a  < b);                    push(f); results_idx++;
    f = ((unsigned)a < (unsigned)b); push(f); results_idx++;
    f = (a  >= b);                   push(f); results_idx++;
    f = ((unsigned)a >= (unsigned)b);push(f); results_idx++;

    /* 6. Jump check -------------------------------------------------- */
    push(add_one(0xDEADBEEF));       results_idx++;

    /* 7. Sentinel ---------------------------------------------------- */
    push(0x5555AAAA);                results_idx++;

    while (1) { /* spin */ }
    return 0;
}


// /* rv32i_benchmark_int_ptr.c
//  *
//  * – Freestanding, pure-RV32I self-check
//  * – Uses plain {int,char,short}
//  * – All memory writes (buffer clear + push) go through pointers
//  */

// /* ────────────────────────────────────────────────────────── */
// /* 0.  Result buffer and pointer-style push                   */
// /* ────────────────────────────────────────────────────────── */
// volatile int results[64];
// static volatile int *wr_ptr = results;      /* write cursor */

// static inline void push(int v)
// {
//     *wr_ptr++ = v;                          /* store & advance */
// }

// /* keep a counter if your test-bench likes it */
// volatile int results_idx = 0;

// /* ────────────────────────────────────────────────────────── */
// /* 1.  Helper that enforces jal / jalr                        */
// /* ────────────────────────────────────────────────────────── */
// __attribute__((noinline)) static int add_one(int x) { return x + 1; }

// /* ────────────────────────────────────────────────────────── */
// /* 2.  Benchmark                                             */
// /* ────────────────────────────────────────────────────────── */
// int main(void)
// {
//     /* 2.1  Clear results[0‥63] with a pointer walk */
//     {
//         volatile int *p = results;
//         int n = 64;
//         while (n--)  { *p++ = 0; }
//     }

//     /* 2.2  Scratchpad mem32[0‥7] cleared the same way */
//     static volatile int mem32[8];
//     {
//         volatile int *p = mem32;
//         int n = 8;
//         while (n--)  { *p++ = 0; }
//     }

//     /* operands */
//     int a = 0x12345678;
//     int b = 0x0FEDCBA9;
//     int tmp;

//     /* 3.  R-type ALU (10 pushes) */
//     push(a + b);              results_idx++;
//     push(a - b);              results_idx++;
//     push(a ^ b);              results_idx++;
//     push(a | b);              results_idx++;
//     push(a & b);              results_idx++;
//     push(a << 3);             results_idx++;
//     push(a >> 5);             results_idx++;
//     push(a >> 5);             results_idx++;      /* sra = srl for +ve a */
//     push(a <  b);             results_idx++;      /* slt  */
//     push((unsigned)a < (unsigned)b); results_idx++; /* sltu */

//     /* 4.  I-type immediates (7 pushes) */
//     push(a + 33);             results_idx++;
//     push(a ^ 0x55);           results_idx++;
//     push(a | 0xAA);           results_idx++;
//     push(a & 0xFFF);          results_idx++;
//     push(a << 7);             results_idx++;
//     push((unsigned)a >> 9);   results_idx++;      /* srli */
//     push(a >> 9);             results_idx++;      /* srai */

//     /* 5.  LUI / AUIPC (2 pushes) */
//     int v_lui;
//     __asm__ volatile ("lui   %0, 0x12345" : "=r"(v_lui));
//     push(v_lui);              results_idx++;

//     int v_auipc;
//     __asm__ volatile ("auipc %0, 0" : "=r"(v_auipc));
//     push(v_auipc);            results_idx++;

//     /* 6.  Loads & stores (6 pushes) */
//     mem32[0] = a;
//     mem32[1] = b;

//     push(mem32[0]);           results_idx++;

//     __asm__ volatile ("lw %0, 4(%1)" : "=r"(tmp) : "r"(mem32));
//     push(tmp);                results_idx++;

//     *((volatile char *)  mem32 +  8) = 0x7B;   /* sb  */
//     *((volatile short *) mem32 + 5) = 0xABCD;  /* sh  */

//     char  lbu;  signed char  lb;
//     unsigned short lhu;  short lh;

//     __asm__ volatile ("lbu %0, 8(%1)"  : "=r"(lbu) : "r"(mem32));
//     __asm__ volatile ("lb  %0, 8(%1)"  : "=r"(lb)  : "r"(mem32));
//     __asm__ volatile ("lhu %0, 10(%1)" : "=r"(lhu) : "r"(mem32));
//     __asm__ volatile ("lh  %0, 10(%1)" : "=r"(lh)  : "r"(mem32));

//     push((int)lbu);           results_idx++;
//     push((int)lb);            results_idx++;
//     push((int)lhu);           results_idx++;
//     push((int)lh);            results_idx++;

//     /* 7.  Branch outcomes (6 pushes) */
//     int f;
//     f = (a == b);                    push(f); results_idx++;
//     f = (a != b);                    push(f); results_idx++;
//     f = (a  < b);                    push(f); results_idx++;
//     f = ((unsigned)a < (unsigned)b); push(f); results_idx++;
//     f = (a  >= b);                   push(f); results_idx++;
//     f = ((unsigned)a >= (unsigned)b);push(f); results_idx++;

//     /* 8.  Jump check (1 push) */
//     push(add_one(0xDEADBEEF));       results_idx++;

//     /* 9.  Sentinel (1 push) */
//     push(0x5555AAAA);                results_idx++;

//     while (1) { /* spin forever */ }
//     return 0;
// }
