# Project README

## Project Title
*FPGA Alarm Clock*

---

## Overview
this project is to simulate an alarm clock using DE10-lite FPGA board
---

## Alarm Clock simulation

<img src="images/sim1.gif" alt="Simulation1" width="500"/>

<img src="images/sim2.gif" alt="Simulation1" width="500"/>

---

## Block Diagram
Below is a simple block diagram representation of the system:

```
     +---------------------+
     |      INPUTS         |
     | clk, reset, ...     |
     +----------+----------+
                |
                v
     +---------------------+
     |     MAIN MODULE     |
     | - State Logic       |
     | - Counters          |
     | - Outputs           |
     +----------+----------+
                |
                v
     +---------------------+
     |      OUTPUTS        |
     | HEX displays, LEDs  |
     +---------------------+
```

---

## Full Code

```verilog
`timescale 1ns / 1ps
`default_nettype none

module main(
    input  wire MAX10_CLK1_50,    // 50 MHz clock
    input  wire KEY0, KEY1,       // active-low buttons
    input  wire [1:0] SW,         // SW0 = increment, SW1 = decrement
    output wire [3:0] LEDR,       // LEDs for selected field
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
    output wire BuzzerOut          // Active buzzer on GPIO[35]
);

    // ===== Debounce Keys =====
    wire key0_db, key1_db;
    Debouncer D0(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY0), .btn_out(key0_db));
    Debouncer D1(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY1), .btn_out(key1_db));

    // ===== Rising Edge Detector for KEY1 =====
    reg key1_prev;
    wire key1_edge;
    always @(posedge MAX10_CLK1_50) key1_prev <= key1_db;
    assign key1_edge = key1_db & ~key1_prev; // 1-clock pulse per press

    // ===== Automatic Clock Counter =====
    wire [4:0] auto_hours;
    wire [5:0] auto_minutes;
    ClockCounter CC(
        .clk_50MHz(MAX10_CLK1_50), 
        .reset(key0_db),
        .hours(auto_hours), 
        .minutes(auto_minutes)
    );

    // ===== SystemAdjust =====
    wire [4:0] time_hours, alarm_hours;
    wire [5:0] time_minutes, alarm_minutes;
    wire [3:0] adj_hours_units, adj_minutes_units;
    wire [2:0] adj_hours_tens, adj_minutes_tens;
    wire [1:0] adjusted;

    SystemAdjust SA(
        .clk(MAX10_CLK1_50),
        .reset(key0_db),
        .key_cycle(key1_edge),
        .sw_inc(SW[0]),
        .sw_dec(SW[1]),
        .auto_hours(auto_hours),
        .auto_minutes(auto_minutes),
        .adj_hours_units(adj_hours_units),
        .adj_hours_tens(adj_hours_tens),
        .adj_minutes_units(adj_minutes_units),
        .adj_minutes_tens(adj_minutes_tens),
        .time_hours_out(time_hours),
        .time_minutes_out(time_minutes),
        .alarm_hours_out(alarm_hours),
        .alarm_minutes_out(alarm_minutes),
        .adjusted(adjusted),
        .LED(LEDR)
    );

    // ===== Buzzer =====
    wire buzzer_en = (time_hours == alarm_hours) && (time_minutes == alarm_minutes);
    Buzzer buz(
        .clk(MAX10_CLK1_50), 
        .en(buzzer_en), 
        .speaker(BuzzerOut)
    );

    // ===== HEX Displays =====
    Hex7Seg H0(.hex(adj_minutes_units), .seg(HEX0));
    Hex7Seg H1(.hex(adj_minutes_tens),  .seg(HEX1));
    Hex7Seg H2(.hex(adj_hours_units),   .seg(HEX2));
    Hex7Seg H3(.hex(adj_hours_tens),    .seg(HEX3));
    Hex7Seg H4(.hex(alarm_minutes[3:0]), .seg(HEX4));
    Hex7Seg H5(.hex(alarm_hours[3:0]),   .seg(HEX5));

endmodule
```
---
# Digital Clock & Alarm System — README

## Overview  
This project implements a simple digital clock system on the DE10-Lite FPGA.  
It includes:

- A real-time clock counter  
- Adjustable time settings  
- Adjustable alarm settings  
- Clean button handling (debouncing + edge detection)  
- 7-segment display output  
- A buzzer that activates when the time matches the alarm  

The goal of this README is to explain the entire design in a clear, human-like way.

---

# Code Explanation

Below is a simple, friendly explanation of each part of the Verilog code.

---

## Debouncing the Buttons  
Mechanical buttons do not produce clean on/off signals. When pressed, they bounce and cause rapid unintended transitions.

The two debouncer modules:

```
Debouncer D0(...)
Debouncer D1(...)
```

These convert the raw KEY0 and KEY1 inputs into stable, clean signals:

- `key0_db` — cleaned reset button  
- `key1_db` — cleaned mode-cycle button  

This ensures that the system reacts exactly once per press.

---

## Detecting Single Button Presses  
Even after debouncing, holding a button down keeps the signal high.  
To avoid repeated triggers, a one-clock-cycle edge detector is used:

```
always @(posedge MAX10_CLK1_50) key1_prev <= key1_db;
assign key1_edge = key1_db & ~key1_prev;
```

This detects the moment KEY1 goes from 0 → 1 and produces a **single pulse**.  
This pulse is used to cycle between adjustment modes (selecting hours/minutes for editing).

---

## Automatic Clock Counter  
A module named `ClockCounter` keeps real time:

```
ClockCounter CC(...)
```

It uses the 50 MHz clock to increment minutes and hours.  
It outputs:

- `auto_hours`  
- `auto_minutes`  

These represent the running time of the clock.  
They are used unless the user enters adjustment mode.

---

## SystemAdjust Module  
This is the central controller of the system:

```
SystemAdjust SA(...)
```

It manages:

### 1. Switching Between Modes  
Each press of KEY1 (after edge detection) moves through different adjustment modes:

- Hours tens  
- Hours units  
- Minutes tens  
- Minutes units  
- Alarm hours  
- Alarm minutes  

The currently selected mode is displayed using the LEDs.

---

### 2. Incrementing / Decrementing Values  
Two switches are used:

- `SW0` → increment  
- `SW1` → decrement  

Depending on the active mode, these change the selected digit.

---

### 3. Formatting Digits for 7-Segment Displays  
The module outputs digit values such as:

- `adj_hours_units`  
- `adj_hours_tens`  
- `adj_minutes_units`  
- `adj_minutes_tens`  

These are ready to be displayed directly by the HEX modules.

---

### 4. Managing Time Outputs  
The module outputs two sets of values:

1. **Current Time (adjustable)**  
   - `time_hours`  
   - `time_minutes`  

2. **Alarm Time**  
   - `alarm_hours`  
   - `alarm_minutes`  

These signals are used by both the display and the buzzer.

---

## Buzzer Logic  
The buzzer should activate when the current time matches the alarm time.

This logic checks for equality:

```
(time_hours == alarm_hours) && (time_minutes == alarm_minutes)
```

If true, the buzzer module produces a square wave on `BuzzerOut`.

---

## 7-Segment Display Drivers  
Each of the six HEX displays uses a decoder:

```
Hex7Seg H0(...)
Hex7Seg H1(...)
...
```

These convert a 4-bit number (0–9) into the correct pattern for the display.

The displays show:

- Adjusted hours/minutes  
- Alarm hours/minutes  

in a clean and readable format.

---

# Summary  
This project ties together several digital design concepts:

- Debouncing  
- Edge detection  
- Counters  
- Multiplexed data paths  
- Digit formatting  
- Simple alarm logic  
- FPGA 7-segment display control  

The result is a fully functional adjustable digital clock with an alarm and buzzer.
