# SPI Master Controller Using Verilog HDL

## About the Project

This project is about designing an SPI Master Controller using Verilog HDL.

The main aim of this project is to understand how SPI communication works and how a Master can send and receive data from a Slave device.

The controller uses a Finite State Machine (FSM) to control the data transfer process.

## Features

- 8-bit data transmission and reception.
- MSB-first data transfer.
- FSM-based design.
- Configurable CPOL and CPHA.
- Supports configuration for all four SPI modes.
- Clock divider for generating SPI clock.
- Busy and Done signals to indicate transfer status.

## SPI Modes

SPI has four different modes based on CPOL and CPHA.

| Mode | CPOL | CPHA |
|---|---|---|
| Mode 0 | 0 | 0 |
| Mode 1 | 0 | 1 |
| Mode 2 | 1 | 0 |
| Mode 3 | 1 | 1 |

## FSM States

The controller has three states:

1. **IDLE:** Waits for the start signal.
2. **TRANSFER:** Sends and receives 8-bit data.
3. **FINISH:** Completes the transfer and sets the Done signal.

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- VS Code

## Simulation

The project was simulated using Icarus Verilog and the output waveforms were checked using GTKWave.

The testbench includes three test cases:

| Test | Master Data | Slave Data |
|---|---|---|
| 1 | A5 | 3C |
| 2 | 55 | 96 |
| 3 | F0 | 0F |

### Simulation Waveform

![SPI Master Simulation](sim/spi_master_waveforms_combined.png)

## Project Structure

```text
spi-master-rtl-gds/
│
├── rtl/
│   └── spi_master.v
│
├── tb/
│   └── spi_master_tb.v
│
├── sim/
│   └── spi_master_waveforms_combined.png
│
└── README.md
```

## Future Improvements

- Test all four SPI modes.
- Perform RTL synthesis.
- Check timing and area reports.
- Complete the RTL-to-GDS flow.

  
