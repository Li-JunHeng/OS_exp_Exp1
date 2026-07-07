#!/usr/bin/env python3
from __future__ import annotations

import difflib
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD_DIR = ROOT / "build" / "sim"
RESULT_DIR = ROOT / "build" / "results"

VERILOG_SOURCES = [
    ROOT / "tests" / "smoke_tb.v",
    ROOT / "src" / "cpu" / "sccomp.v",
    ROOT / "src" / "cpu" / "SCPU.v",
    ROOT / "src" / "cpu" / "ctrl.v",
    ROOT / "src" / "cpu" / "alu.v",
    ROOT / "src" / "cpu" / "PC.v",
    ROOT / "src" / "cpu" / "NPC.v",
    ROOT / "src" / "cpu" / "EXT.v",
    ROOT / "src" / "cpu" / "RF.v",
    ROOT / "src" / "cpu" / "dm.v",
    ROOT / "src" / "cpu" / "im.v",
]


@dataclass(frozen=True)
class Case:
    name: str
    program: Path
    golden: Path
    stop_pc: str
    program_words: int
    max_cycles: int = 200


CASES = [
    Case(
        name="rv32i_8_instr",
        program=ROOT / "tests" / "programs" / "rv32i_8_instr.dat",
        golden=ROOT / "tests" / "golden" / "rv32i_8_instr.txt",
        stop_pc="00000048",
        program_words=15,
    )
]


def run(cmd: list[str], *, cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )


def require_tool(name: str) -> None:
    if not shutil.which(name):
        raise SystemExit(f"missing required tool: {name}")


def compile_sim() -> Path:
    BUILD_DIR.mkdir(parents=True, exist_ok=True)
    RESULT_DIR.mkdir(parents=True, exist_ok=True)
    out = BUILD_DIR / "smoke_tb.vvp"
    cmd = [
        "iverilog",
        "-g2012",
        "-Wall",
        "-I",
        str(ROOT / "src" / "cpu"),
        "-o",
        str(out),
        *map(str, VERILOG_SOURCES),
    ]
    proc = run(cmd)
    if proc.returncode != 0:
        print(proc.stdout, end="")
        raise SystemExit(f"compile failed with exit code {proc.returncode}")
    if proc.stdout.strip():
        print(proc.stdout, end="")
    return out


def normalize(text: str) -> list[str]:
    return [line.rstrip() for line in text.splitlines() if line.strip()]


def run_case(sim: Path, case: Case) -> bool:
    result = RESULT_DIR / f"{case.name}.txt"
    cmd = [
        "vvp",
        str(sim),
        f"+PROGRAM={case.program.relative_to(ROOT)}",
        f"+OUTPUT={result.relative_to(ROOT)}",
        f"+STOP_PC={case.stop_pc}",
        f"+PROGRAM_WORDS={case.program_words}",
        f"+MAX_CYCLES={case.max_cycles}",
    ]
    proc = run(cmd)
    if proc.stdout.strip():
        print(proc.stdout, end="")
    if proc.returncode != 0:
        print(f"[FAIL] {case.name}: simulation exited with {proc.returncode}")
        return False

    actual = normalize(result.read_text())
    expected = normalize(case.golden.read_text())
    if actual != expected:
        print(f"[FAIL] {case.name}: output differs from golden")
        for line in difflib.unified_diff(
            expected,
            actual,
            fromfile=str(case.golden.relative_to(ROOT)),
            tofile=str(result.relative_to(ROOT)),
            lineterm="",
        ):
            print(line)
        return False

    print(f"[PASS] {case.name}")
    return True


def main() -> int:
    require_tool("iverilog")
    require_tool("vvp")
    sim = compile_sim()
    ok = True
    for case in CASES:
        ok = run_case(sim, case) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
