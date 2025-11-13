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


Line-by-Line Explanation

Below is a simple, human‑friendly explanation of how the entire code works. The goal is to make it feel natural and easy to understand.

Top of File

timescale 1ns / 1ps – Tells the simulator how to treat delays.

default_nettype none – Forces you to explicitly declare every wire and reg. This prevents bugs caused by typos.

Module Inputs and Outputs

The module is named main, and it has:

A 50 MHz clock (main timing source)

Two push buttons (KEY0 = reset, KEY1 = mode cycle)

Two switches (SW0 = increment, SW1 = decrement)

LEDs to show what field you're adjusting

Six HEX displays

A buzzer output that activates when the alarm matches the clock

Debouncing the Buttons

Physical buttons bounce (they rapidly toggle between 0 and 1 when pressed). So we clean the signal:

Debouncer D0(...)
Debouncer D1(...)

These give us two clean signals: key0_db and key1_db.

Detecting a Rising Edge

We only want KEY1 to trigger once per press, not continuously.

always @(posedge MAX10_CLK1_50) key1_prev <= key1_db;
assign key1_edge = key1_db & ~key1_prev;

This generates a 1‑clock‑long pulse each time KEY1 is pressed.

Automatic Clock Counter

This is your live running clock.

ClockCounter CC(...)

It outputs:

auto_hours

auto_minutes

This keeps time automatically in the background.

SystemAdjust Module

This is the “brains” of the design. It manages:

Adjusting the current time

Adjusting the alarm time

Selecting which field you’re editing (hours tens, hours units, minutes tens, etc.)

Updating the LEDs to show your selection

Sending data to the 7‑seg displays

Inputs:

Cleaned button presses

Increment/decrement switches

The auto‑running time

Outputs:

Adjusted hours and minutes

Alarm settings

The values for each 7‑segment digit

LED indicators

This module cycles through adjustment modes using KEY1. SW0/SW1 then change the selected value.

Buzzer Logic

This line checks:

(time_hours == alarm_hours) && (time_minutes == alarm_minutes)

If both match, the buzzer turns on.

The buzzer module receives buzzer_en and outputs a square wave.

HEX Display Drivers

Each 7‑segment display uses a hex‑to‑7‑seg module:

Hex7Seg H0(...)
Hex7Seg H1(...)
...

You are showing:

Current adjusted time (hours & minutes)

Alarm time (hours & minutes)

The display is updated in real‑time as the user adjusts values.