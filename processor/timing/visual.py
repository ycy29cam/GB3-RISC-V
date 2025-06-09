"""
scan_reports.py  –  v3
Scans every *.txt report in the script’s folder, extracts
    • Total number of logic levels
    • Total path delay (ns)
and produces two conference-ready bar charts
shown one above the other in your desktop’s figure stack.

NOTE: The execution environment here disallows true matplotlib sub-plots,
so each chart is still a separate figure, but they are sized and styled
as a coordinated pair.
"""

import os
import re
import glob
import matplotlib.pyplot as plt

# ───────────────────────────────────────────────────────────────
# 1) Directory that contains this script and the reports
# ───────────────────────────────────────────────────────────────
HERE = os.path.abspath(os.path.dirname(__file__))

# ───────────────────────────────────────────────────────────────
# 2) Regular-expression patterns
# ───────────────────────────────────────────────────────────────
logic_pat = re.compile(r"Total number of logic levels:\s*(\d+)")
delay_pat = re.compile(r"Total path delay:\s*([\d.]+)\s*ns", re.I)

# ───────────────────────────────────────────────────────────────
# 3) Extract data from every .txt file
# ───────────────────────────────────────────────────────────────
results = {}  # {filename: {"logic": int, "delay": float}}

for path in glob.glob(os.path.join(HERE, "*.txt")):
    logic = delay = None
    with open(path, "r", errors="ignore") as f:
        for line in f:
            if logic is None:
                m = logic_pat.search(line)
                if m:
                    logic = int(m.group(1))
            if delay is None:
                m = delay_pat.search(line)
                if m:
                    delay = float(m.group(1))
            if logic is not None and delay is not None:
                break

    if logic is not None and delay is not None:
        results[os.path.basename(path)] = {"logic": logic, "delay": delay}

if not results:
    raise RuntimeError("No reports processed or patterns not found.")

# ───────────────────────────────────────────────────────────────
# 4) Prepare data arrays
# ───────────────────────────────────────────────────────────────
file_names = list(results.keys())
logic_vals = [v["logic"] for v in results.values()]
delay_vals = [v["delay"] for v in results.values()]

# ───────────────────────────────────────────────────────────────
# 5) Matplotlib styling for a professional, projector-friendly look
#    (Colour-blind safe palette: 'tab:blue', 'tab:orange')
# ───────────────────────────────────────────────────────────────
plt.rcParams.update({
    "figure.figsize": (11, 8),    # wide & short → stacks neatly
    "font.size":      12,
    "axes.grid":      True,
    "grid.linestyle": "dotted",
})

bar_kwargs_logic = dict(color="tab:blue",   edgecolor="black", linewidth=0.8)
bar_kwargs_delay = dict(color="tab:orange", edgecolor="black", linewidth=0.8)

# ───────────────────────────────────────────────────────────────
# 6) Plot 1 – Logic Levels (top figure)
# ───────────────────────────────────────────────────────────────
plt.figure()
bars = plt.bar(range(len(file_names)), logic_vals, **bar_kwargs_logic)
plt.xticks(range(len(file_names)), file_names, rotation=45, ha="right")
plt.ylabel("Total Number of Logic Levels")
plt.title("Logic Levels per Report")

for bar in bars:                             # annotate bars
    h = bar.get_height()
    plt.annotate(f"{h}",
                 xy=(bar.get_x() + bar.get_width() / 2, h),
                 xytext=(0, 3), textcoords="offset points",
                 ha="center", va="bottom")

plt.tight_layout()

# ───────────────────────────────────────────────────────────────
# 7) Plot 2 – Path Delay (bottom figure)
# ───────────────────────────────────────────────────────────────
plt.figure()
bars = plt.bar(range(len(file_names)), delay_vals, **bar_kwargs_delay)
plt.xticks(range(len(file_names)), file_names, rotation=45, ha="right")
plt.ylabel("Total Path Delay (ns)")
plt.title("Path Delay per Report")

for bar in bars:                             # annotate bars
    h = bar.get_height()
    plt.annotate(f"{h:.2f}",
                 xy=(bar.get_x() + bar.get_width() / 2, h),
                 xytext=(0, 3), textcoords="offset points",
                 ha="center", va="bottom")

plt.tight_layout()

plt.show()
