# VHDL Register File and ALU

A structural VHDL design that combines a 32-register file, two hierarchical 32-to-1 multiplexers, a 5-to-32 write decoder, and an arithmetic logic unit (ALU).

The design uses an 18-bit instruction format:

```text
17          15 14           10 9             5 4             0
+-------------+---------------+---------------+---------------+
| function    | source A      | source B      | destination   |
| 3 bits      | 5 bits        | 5 bits        | 5 bits        |
+-------------+---------------+---------------+---------------+
```

## Repository Structure

```text
vhdl-register-file-alu/
├── .gitignore
├── README.md
├── Waveform.vwf
├── alu.vhd
├── alu_tb.vhd
├── data_register.vhd
├── decoder_5_to_32.vhd
├── mux_2_to_1.vhd
├── mux_4_to_1.vhd
├── mux_32_to_1.vhd
├── register_array.vhd
├── register_file_alu.qpf
├── register_file_alu.qsf
├── register_file_alu.vhd
└── register_file_alu_tb.vhd
```

## Architecture

### Register array

The register file contains 32 registers of `DATA_WIDTH` bits.

On reset:

- register 5 loads `register_5_initial_value`;
- register 23 loads `register_23_initial_value`;
- every other register loads zero.

When `write_enable = '1'`, the 5-to-32 decoder enables the destination register selected by `instruction(4 downto 0)`.

The reset behavior is preserved from the provided design. The external initial values should be stable before reset is asserted.

### Read path

Two independent hierarchical 32-to-1 multiplexers read the source registers selected by:

```text
source A: instruction(14 downto 10)
source B: instruction(9 downto 5)
```

Each 32-to-1 multiplexer is intentionally built from:

- eight 4-to-1 multiplexers;
- two 4-to-1 multiplexers;
- one 2-to-1 multiplexer.

This preserves the architecture shown in the provided report.

### ALU function codes

| Function code | Operation | Overflow output |
| --- | --- | --- |
| `000` | Unsigned addition | Carry-out |
| `001` | Unsigned subtraction | Borrow indicator |
| `010` | Unsigned multiplication | Upper truncated bits are nonzero |
| `011` | Bitwise AND | `0` |
| `100` | Bitwise OR | `0` |
| `101` | Bitwise NOT of operand A | `0` |
| `110` | Unsupported | `1` |
| `111` | Unsupported | `1` |

For multiplication, only the low `DATA_WIDTH` bits are returned in `result`.

## Main Corrections

- Renamed Portuguese files, entities, architectures, ports, signals, instances, comments, and technical labels to English.
- Replaced component declarations with explicit entity instantiation so cross-file references are easier to verify.
- Added safe handling for non-binary decoder addresses. An address containing `X`, `U`, `Z`, or another non-binary simulation value no longer risks enabling an unintended register.
- Changed the 2-to-1 multiplexer so an invalid simulation select value produces zeros rather than silently selecting input B.
- Rewrote subtraction overflow handling explicitly as an unsigned borrow test.
- Preserved the original hierarchical 32-to-1 multiplexer implementation and register-file behavior.
- Updated the provided `Waveform.vwf` to use the renamed English top-level signals.
- Added `alu_tb.vhd` and `register_file_alu_tb.vhd`.
- Added a clean Quartus QSF because the original ZIP did not contain one.

## Quartus Project Limitation

The provided ZIP contained `banco_registradores.qpf` but **did not contain the corresponding `.qsf`**.

Because of that, the following information cannot be verified from the supplied project files:

- exact FPGA part number and speed grade;
- board pin assignments;
- timing constraints.

The utilization report in the supplied PDF shows the resources of the device used for the original build, but that is not enough to reconstruct the exact hardware configuration safely.

`register_file_alu.qsf` therefore contains the source-file list, top-level entity, and waveform reference, but intentionally does not invent a device assignment.

Before compiling for an FPGA in Quartus, select the correct device for the assignment:

```text
Assignments -> Device
```

and add any required pin assignments or timing constraints.

## GHDL Compilation and Simulation

If GHDL is installed, run these commands from the repository root.

### Analyze the design

```text
ghdl -a --std=08 data_register.vhd
ghdl -a --std=08 decoder_5_to_32.vhd
ghdl -a --std=08 mux_2_to_1.vhd
ghdl -a --std=08 mux_4_to_1.vhd
ghdl -a --std=08 mux_32_to_1.vhd
ghdl -a --std=08 register_array.vhd
ghdl -a --std=08 alu.vhd
ghdl -a --std=08 register_file_alu.vhd
```

### Run the ALU testbench

```text
ghdl -a --std=08 alu_tb.vhd
ghdl -e --std=08 alu_tb
ghdl -r --std=08 alu_tb --assert-level=error
```

Expected final note:

```text
ALU testbench completed successfully.
```

### Run the complete register-file/ALU testbench

```text
ghdl -a --std=08 register_file_alu_tb.vhd
ghdl -e --std=08 register_file_alu_tb
ghdl -r --std=08 register_file_alu_tb --assert-level=error
```

Expected final note:

```text
Register-file/ALU testbench completed successfully.
```

These expected messages are testbench expectations, not claims that the tests already passed on the target machine.

## Quartus

Open:

```text
register_file_alu.qpf
```

Then select the correct device before compiling.

After the device is configured, compilation can be started in the GUI with:

```text
Processing -> Start Compilation
```

or from a terminal with:

```text
quartus_sh --flow compile register_file_alu
```

Do not use the command-line Quartus compilation until the target device has been configured.

## Provided Report

The supplied PDF was reviewed as a reference. It shows the original design hierarchy, waveform, area, and frequency results.

The report lists the original implementation as using:

```text
1,936 combinational functions
1,024 dedicated logic registers
1,024 total registers
118 pins
8 embedded 9-bit multiplier elements
Fmax: 60.11 MHz
```

Those figures belong to the original project and do **not** verify this cleaned and renamed repository.

The Portuguese PDF itself is not included in this cleaned repository because project documentation is being standardized to English. Keep the original report separately if it is required for submission.

## Verification Status

The corrected repository was statically checked for:

- missing referenced entities;
- stale Portuguese entity/file references;
- QSF source-file references;
- Waveform signal references after the top-level rename;
- 32-to-1 multiplexer selection mapping;
- decoder one-hot behavior;
- ALU arithmetic and overflow behavior;
- instruction-field mapping;
- register-file reset and write-path logic.

GHDL and Quartus are not installed in the review environment. Therefore, actual VHDL analysis, elaboration, simulation, Quartus synthesis, timing analysis, and FPGA execution still need to be performed locally.

## Suggested Commit Message

```text
refactor: standardize register file and ALU VHDL project
```
