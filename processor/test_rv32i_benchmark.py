# test_rv32i_benchmark.py  – progress bar + total cycles + mnemonic labels
import cocotb
from cocotb.clock    import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.result   import TestFailure

# ───── configuration ─────────────────────────────────────────────
CLK_PERIOD_NS   = 10                     # 100 MHz
DATA_MEM_PATH   = "data_mem_inst.data_block"
WORDS_TO_SKIP   = 1                      # results_idx at mem[0]
REPORT_EVERY_US = 100                    # progress-print period
RESET_PRESENT   = False
# ─────────────────────────────────────────────────────────────────


def build_expected_and_labels():
    """Return (values, labels) lists of equal length."""
    a, b = 0x12345678, 0x0FEDCBA9
    values = [
        (a + b) & 0xFFFFFFFF, (a - b) & 0xFFFFFFFF, a ^ b, a | b, a & b,
        (a << 3) & 0xFFFFFFFF, a >> 5, a >> 5,
        int(a < b), int((a & 0xFFFFFFFF) < (b & 0xFFFFFFFF)),
        (a + 33) & 0xFFFFFFFF, a ^ 0x55, a | 0xAA, a & 0xFFF,
        (a << 7) & 0xFFFFFFFF, (a >> 9) & 0xFFFFFFFF, a >> 9,
        0x12345000, None,
        a, b, 0x7B, 0x7B, 0xABCD, 0xFFFFABCD,
        0, 1, 0, 0, 1, 1,
        (0xDEADBEEF + 1) & 0xFFFFFFFF,
        0x5555AAAA,
    ]
    labels = [
        "ADD", "SUB", "XOR", "OR", "AND",
        "SLL", "SRL", "SRA",
        "SLT", "SLTU",
        "ADDI", "XORI", "ORI", "ANDI",
        "SLLI", "SRLI", "SRAI",
        "LUI",  "AUIPC",
        "LW a", "LW b", "LBU", "LB", "LHU", "LH",
        "BEQ", "BNE", "BLT", "BLTU", "BGE", "BGEU",
        "ADD_ONE", "SENTINEL",
    ]
    return values, labels


# ───── helpers ───────────────────────────────────────────────────
def _hier(root, dotted):
    h = root
    for part in dotted.split('.'):
        h = getattr(h, part)
    return h


def _bar(done, total, width=33):
    filled = int(done / total * width)
    return "▓" * filled + "░" * (width - filled)


async def wait_for_sentinel(dut, mem, idx, total_words):
    clk = dut.clk
    cycles = 0
    rep_cycles = (REPORT_EVERY_US * 1000) // CLK_PERIOD_NS

    while True:
        word = mem[idx].value
        if word.is_resolvable and int(word) == 0x5555AAAA:
            dut._log.info("[%7.2f µs] %02d/%d %s",
                          cycles * CLK_PERIOD_NS / 1000, total_words,
                          total_words, _bar(total_words, total_words))
            return cycles
        cycles += 1
        if cycles % rep_cycles == 0:
            rs_val = mem[0].value
            pushed = int(rs_val) if rs_val.is_resolvable else 0
            if pushed > total_words:
                pushed = total_words
            dut._log.info("[%7.2f µs] %02d/%d %s",
                          cycles * CLK_PERIOD_NS / 1000, pushed,
                          total_words, _bar(pushed, total_words))
        await RisingEdge(clk)


# ───── main test ────────────────────────────────────────────────
@cocotb.test()
async def rv32i_selfcheck(dut):
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
    dut._log.info("Clock started")

    if RESET_PRESENT:
        dut.rst_n.value = 0
        await Timer(100, units="ns")
        dut.rst_n.value = 1
        dut._log.info("Reset released")

    mem = _hier(dut, DATA_MEM_PATH)
    expected, labels = build_expected_and_labels()
    sentinel = WORDS_TO_SKIP + len(expected) - 1

    cycles = await wait_for_sentinel(dut, mem, sentinel, len(expected) - 1)
    dut._log.info("Program finished in %d cycles (%.2f µs)",
                  cycles, cycles * CLK_PERIOD_NS / 1000)

    # Compare -------------------------------------------------------
    mism = 0
    for i, (gold, label) in enumerate(zip(expected, labels)):
        if gold is None:                    # AUIPC
            continue
        got = int(mem[WORDS_TO_SKIP + i].value) & 0xFFFFFFFF
        if got != gold:
            mism += 1
            dut._log.error("idx %02d %-8s MISMATCH got 0x%08X exp 0x%08X",
                           i, label, got, gold)
        else:
            dut._log.info ("idx %02d %-8s OK 0x%08X", i, label, got)

    if mism:
        raise TestFailure(f"{mism} mismatches in benchmark results")
    dut._log.info("All %d words match – TEST PASSED",
                  len(expected) - expected.count(None))
