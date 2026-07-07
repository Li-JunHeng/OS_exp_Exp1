# Exp1 Verilog CPU Project

This repository contains the Verilog materials for the Exp1 CPU task. The tree is organized so the Mac-side simulation harness, Vivado board files, original handout archives, and reference documents are separated.

## Layout

```text
archives/       Original compressed handout files.
constraints/    Board and project XDC constraint files.
docs/           PDFs, PPTX, DOCX, schematic, and test screenshot.
memory/         COE/DAT/TXT memory initialization and instruction files.
scripts/        Local automation scripts.
src/cpu/        Editable CPU Verilog source from code.rar.
src/board/      Board-level top.v and inferred data RAM wrapper.
src/io/         IO helper modules from IO.rar.
src/ip/         EDF/IP wrapper modules from edf_file.rar.
tests/          Icarus Verilog smoke tests and legacy examples.
tools/asm2coe/  Assembly-to-COE helper from asm2coe.zip.
```

## Run

```sh
make test
```

The test flow uses `iverilog` to compile `src/cpu/` and `vvp` to simulate it. It runs both the original 8-instruction smoke case and the 37-instruction experiment case from `memory/Test_37_Instr8.dat`.

```sh
make top-syntax
```

This compiles the board-level `src/board/top.v` with the provided IO/IP stubs to catch Verilog syntax and port wiring errors before opening Vivado.

## Board Integration Notes

- `memory/Test_37_Instr8.txt` is the instruction reference named in the task.
- `memory/I_mem.coe` and `memory/D_mem.coe` are Vivado memory initialization files.
- `constraints/Nexys-A7-100T-Master.xdc` is the board-level pin constraint file.
- `constraints/icf.xdc` is the project-specific constraint file.
- `docs/测试.png` is the expected board test behavior reference.
- `src/io/` and `src/ip/` contain the provided IO and EDF submodules used when assembling the final `top.v`.
- `src/board/top.v` is the board-level assembly file. It connects the completed CPU, instruction memory, data RAM, MIO bus, LED GPIO, counter, multi-channel display selector, and seven-segment display.
- `scripts/vivado_sources.tcl` adds the intended Vivado source set. It deliberately excludes the provided `src/ip/SCPU.v`/`SCPU.edf` CPU black-box stub because this project uses the implemented `src/cpu/SCPU.v`.
- `results/README.md` contains the fastest board bring-up flow. The `results` submodule is self-contained, so it can also be cloned and used without this parent repository. On a Vivado machine, enter `results/` and run `00_setup_project.bat`, `01_build_bitstream.bat`, then `02_program_board.bat`.

## Add More Cases

1. Put the instruction hex file under `tests/programs/`.
2. Add the expected register snapshot under `tests/golden/`.
3. Add a `Case(...)` entry in `scripts/run_tests.py`.

Keep board-only files such as `.xdc` and Vivado IP out of this Mac-side harness. After `make test` passes, use Vivado for synthesis, implementation, bitstream generation, and on-board validation.
