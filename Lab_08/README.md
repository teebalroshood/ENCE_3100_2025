# Lab Report: FSM Microinstruction System

## Overview
This project focuses on designing and implementing a Finite State Machine (FSM) on the DE10-Lite FPGA board. The system demonstrates how an FSM can control a sequence of microinstructions that respond to user input through switches and buttons. The outputs are shown on LEDs and 7-segment displays. 

The purpose of this lab is to show how digital systems make decisions based on internal states and external inputs. Each part of the design works together — from clock signals and reset circuits to display modules — to form a complete working FSM-based controller.

---

## FSM Explanation
A Finite State Machine (FSM) is a digital logic circuit that moves between different states depending on inputs and clock signals. Each state represents a specific condition or step in the circuit’s operation. The FSM updates its state every clock pulse, and it can reset back to the starting state when the reset switch is pressed.

In this design, the FSM uses debounced signals from physical switches. Real mechanical switches tend to produce noise and bouncing, which can cause multiple unwanted transitions. To solve this, debounce modules are added. These modules clean up the signal, ensuring that only one clean pulse is generated for each press.

When the system runs, the FSM checks inputs such as button presses or switch changes. It then transitions to the correct next state and updates the outputs accordingly. LEDs and 7-segment displays show the results of these state changes in real-time, making it easy to visualize the FSM behavior.

In short, this FSM acts like a small control unit. It waits for the user to give input, processes that input according to its state diagram, and outputs the correct signals. The combination of debounce logic, timing control, and display feedback demonstrates how FSMs can coordinate multiple parts of a digital system.

## 🎬 System Overview GIF

<img src="images/lab_08.GIF" alt="lab08" width="500"/>


---
## Block Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│  Program Memory (ROM) ← Program Counter         │
├─────────────────────────────────────────────────┤
│  Instruction Register ← Decoded from ROM        │
├─────────────────────────────────────────────────┤
│  FSM Controller → Generates Micro-Control      │
│                   Signals Based on Instruction │
├─────────────────────────────────────────────────┤
│         DATAPATH (Shared Internal Bus)          │
│  Input Reg → Accumulator A → ALU → Output Reg │
│             Accumulator B ↑                     │
└─────────────────────────────────────────────────┘



## Verilog Code

```verilog
`timescale 1ns / 1ps
`default_nettype none

module main(
    input        MAX10_CLK1_50,
    input  [1:0] KEY,
    input  [9:0] SW,
    inout  [35:0] GPIO,
    output [9:0] LEDR,
    output [7:0] HEX0,
    output [7:0] HEX1,
    output [7:0] HEX2,
    output [7:0] HEX4,
    output [7:0] HEX5
);

    localparam N = 4;

    // ================================================================
    // 1. Debounced Reset & Step Clock
    // ================================================================
    wire w_reset_raw = SW[8];
    wire w_clock_raw = SW[9];
    wire w_reset;
    wire w_clock_step;

    debounce_reset db_reset(
        .clk(MAX10_CLK1_50),
        .sw_in(w_reset_raw),
        .reset_clean(w_reset)
    );

    debounce_clock db_clock(
        .clk(MAX10_CLK1_50),
        .sw_in(w_clock_raw),
        .step_pulse(w_clock_step)
    );

    wire w_clock = w_clock_step;

    // ================================================================
    // 2. User I/O
    // ================================================================
    wire [N-1:0] w_user_input = SW[3:0];

    wire w_carry;
    assign LEDR[9] = w_carry;

    wire [N-1:0] w_rOut;
    assign LEDR[3:0] = w_rOut;

    // ================================================================
    // 3. Internal Bus
    // ================================================================
    wire [N-1:0] w_IB_BUS;

    // ================================================================
    // 4. FSM Control Signals
    // ================================================================
    wire w_LatchA, w_EnableA;
    wire w_LatchB, w_EnableB;
    wire w_EnableALU, w_AddSub;
    wire w_EnableIN, w_EnableOut;
    wire w_LoadInstr, w_EnableInstr;
    wire [N-1:0] w_ToInstr;
    wire w_EnableCount;

    // ================================================================
    // 5. Accumulator A
    // ================================================================
    wire [N-1:0] w_AluA;
    Accumulator_A AccA(
        .MainClock(w_clock),
        .ClearA(w_reset),
        .LatchA(w_LatchA),
        .EnableA(w_EnableA),
        .IB_BUS(w_IB_BUS),
        .A(),
        .AluA(w_AluA)
    );
    seg7Decoder SEG1(.i_bin(w_AluA), .o_HEX(HEX1));

    // ================================================================
    // 6. Accumulator B
    // ================================================================
    wire [N-1:0] w_AluB;
    Accumulator_B AccB(
        .MainClock(w_clock),
        .ClearB(w_reset),
        .LatchB(w_LatchB),
        .EnableB(w_EnableB),
        .IB_BUS(w_IB_BUS),
        .B(),
        .AluB(w_AluB)
    );
    seg7Decoder SEG2(.i_bin(w_AluB), .o_HEX(HEX2));

    // ================================================================
    // 7. Arithmetic Unit (ALU)
    // ================================================================
    Arithmetic_Unit ALU(
        .EnableALU(w_EnableALU),
        .AddSub(w_AddSub),
        .A(w_AluA),
        .B(w_AluB),
        .Carry(w_carry),
        .IB_ALU(w_IB_BUS)
    );

    // ================================================================
    // 8. Input Register
    // ================================================================
    InRegister InReg(
        .EnableIN(w_EnableIN),
        .DataIn(w_user_input),
        .IB_BUS(w_IB_BUS)
    );
    seg7Decoder SEG4(.i_bin(w_user_input), .o_HEX(HEX4));

    // ================================================================
    // 9. Output Register
    // ================================================================
    OutRegister OutReg(
        .MainClock(w_clock),
        .MainReset(w_reset),
        .EnableOut(w_EnableOut),
        .IB_BUS(w_IB_BUS),
        .rOut(w_rOut)
    );
    seg7Decoder SEG5(.i_bin(w_rOut), .o_HEX(HEX5));

    // ================================================================
    // 10. Instruction Register
    // ================================================================
    wire [N-1:0] w_data;
    wire [N-1:0] w_instruction;
    InstructionReg InstrReg(
        .MainClock(w_clock),
        .ClearInstr(w_reset),
        .LatchInstr(w_LoadInstr),
        .EnableInstr(w_EnableInstr),
        .Data(w_data),
        .Instr(w_instruction),
        .ToInstr(w_ToInstr),
        .IB_BUS(w_IB_BUS)
    );

    // ================================================================
    // 11. Program Counter & ROM
    // ================================================================
    wire [N-1:0] w_counter;
    ProgramCounter ProgCounter(
        .MainClock(w_clock),
        .EnableCount(w_EnableCount),
        .ClearCounter(w_reset),
        .Counter(w_counter)
    );

    wire [7:0] w_rom_data;
    ROM_Nx8 ROM(
        .address(w_counter[2:0]),
        .data(w_rom_data)
    );

    assign {w_instruction, w_data} = w_rom_data;

    // ================================================================
    // 12. FSM Controller
    // ================================================================
    FSM_MicroInstr Controller(
        .clk(w_clock),
        .reset(w_reset),
        .IB_BUS(w_IB_BUS),
        .LatchA(w_LatchA),
        .EnableA(w_EnableA),
        .LatchB(w_LatchB),
        .EnableALU(w_EnableALU),
        .AddSub(w_AddSub),
        .EnableIN(w_EnableIN),
        .EnableOut(w_EnableOut),
        .LoadInstr(w_LoadInstr),
        .EnableInstr(w_EnableInstr),
        .ToInstr(w_ToInstr),
        .EnableCount(w_EnableCount)
    );

    // ================================================================
    // 13. Bus Display (safe copy)
    // ================================================================
    wire [N-1:0] w_bus_display = (w_IB_BUS === 4'bzzzz) ? 4'b0000 : w_IB_BUS;
    seg7Decoder SEG0(.i_bin(w_bus_display), .o_HEX(HEX0));

    // ================================================================
    // 14. UART Debugger
    // ================================================================
    wire uart_tx_signal;          // declare TX wire
    assign GPIO[33] = uart_tx_signal;  // TX pin out
    // GPIO[35] reserved for RX

    UART_Debugger uart_dbg (
        .clk_fast(MAX10_CLK1_50),
		  .clk_step(w_clock),    // ✅ connect your manual step clock
        .A(w_AluA),
        .B(w_AluB),
        .BUS(w_IB_BUS),
        .CARRY(w_carry),
        .uart_tx(uart_tx_signal)
    );

endmodule

// ================================================================
//  DEBOUNCE MODULES
// ================================================================
module debounce_reset (
    input  wire clk,
    input  wire sw_in,
    output reg  reset_clean
);
    reg [19:0] count;
    reg sw_sync;
    always @(posedge clk) begin
        sw_sync <= sw_in;
        if (sw_sync == reset_clean)
            count <= 0;
        else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin
                reset_clean <= sw_sync;
                count <= 0;
            end
        end
    end
endmodule

module debounce_clock (
    input  wire clk,
    input  wire sw_in,
    output reg  step_pulse
);
    reg [19:0] count;
    reg sw_sync, sw_stable, sw_prev;
    always @(posedge clk) begin
        sw_sync <= sw_in;
        if (sw_sync == sw_stable)
            count <= 0;
        else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin
                sw_stable <= sw_sync;
                count <= 0;
            end
        end
        step_pulse <= sw_stable & ~sw_prev;
        sw_prev <= sw_stable;
    end
endmodule

`default_nettype wire

```

---

## Module Breakdown

### 1. Debounce Modules
The debounce modules (`debounce_reset` and `debounce_clock`) filter the noise from switches. When you press a button, the contact might bounce rapidly between on and off before settling. Without debouncing, the FSM might read these bounces as multiple signals. These modules clean up the signals so that each press is counted only once.

### 2. Clock and Reset Control
The design uses a step clock generated from one of the switches. This clock signal drives the FSM so that state transitions only occur on clean rising edges. The reset signal initializes the FSM to a known starting state, which helps avoid undefined conditions.

### 3. FSM Core
Inside the FSM module, the logic defines different states and transitions. Each state determines what happens next depending on inputs. This part is where the behavior of the system is decided — when to move forward, when to hold, and when to reset.

### 4. Output Display
The FSM outputs are connected to LEDs and 7-segment displays. The LEDs give a simple binary visual output, while the displays show numerical or character information. This makes it easier to understand what the FSM is doing at each step.

---

## How to Run the Design

1. Open the project in **Intel Quartus Prime**.
2. Assign the proper FPGA pins for switches, keys, LEDs, and 7-segment displays based on your board pinout.
3. Compile the design and program it into the **DE10-Lite FPGA**.
4. Use the switches to simulate different inputs for the FSM.
5. Observe how the FSM responds on the LEDs and displays.

---

## Summary
This project demonstrates a complete FSM design on hardware. It shows how to handle real-world input signals, control timing with debouncing and clocks, and visualize results using output devices. Through this lab, we can better understand how digital systems process information in defined steps — just like a small, predictable computer.
