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

```text
1,936 combinational functions
1,024 dedicated logic registers
1,024 total registers
118 pins
8 embedded 9-bit multiplier elements
Fmax: 60.11 MHz
``` 
