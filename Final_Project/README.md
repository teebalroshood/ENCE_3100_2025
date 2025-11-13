# Project README

## Project Title
*FPGA Alarm Clock*

---

## Overview
This README explains the full Verilog project in a clear, simple, human-like way. It includes detailed explanations for each part of the code, a block diagram, and placeholders for two GIFs you will add later.

---

## GIF Placeholder 1
*(Insert your first GIF here)*
<img src="images/sim1.gif" alt="Simulation1" width="500"/>

<img src="images/sim2.gif" alt="Simulation1" width="500"/>

---

## Block Diagram
Below is a simple block diagram representation of the system. You may replace it with a proper graphic later:

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
Paste your full project code below so the report is self-contained:

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

## Line-by-Line Explanation
Below is a human-like explanation for each major section. Replace or expand depending on the actual code you paste.

### 1. `default_nettype none`
This line forces Verilog to require every signal to be explicitly declared. It helps you avoid accidental wires created by typos.

### 2. Module Declaration
Here the module begins and defines all inputs, outputs, and bidirectional pins. This section describes exactly what signals enter and exit the FPGA.

### 3. Clock Wiring
If the code generates or divides clocks, this part sets up internal timing used for counters or FSM transitions.

### 4. State Machine
If your project uses an FSM, this section will:
- Define named states
- Implement state transitions
- Handle conditions like button presses, counters, or switches

Each state will typically control what the system displays or how it behaves.

### 5. Counters
If your project includes counters, here you would find:
- A clock-driven counter that increments or decrements
- Reset conditions
- Any timing-related behavior

### 6. Output Logic
This is where values get sent to HEX displays, LEDs, GPIO pins, etc. It may include 7‑segment encoding or output formatting.

### 7. Always Blocks
These run on either clock edges or signal changes. This is where the main behavior of the project comes together.

---

## GIF Placeholder 2
*(Insert your second GIF here)*

---

## Conclusion
This README gives structure to your report and explains how the code works step-by-step. Add your exact Verilog code and I will automatically help you generate the full detailed explanation if you want.

