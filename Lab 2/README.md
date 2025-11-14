# Lab 02 – Digital Clock System (README)
---

## Block Diagram
```
[ MAX10_CLK1_50 ] ───────────┐
                             │
                        +---------+
                        |         |
                        | Debounce|
                        |  Unit   |
                        +---------+
                             │
                KEY0, KEY1 --┘
                             │
                        +-------------+
                        | Rising Edge |
                        |  Detector   |
                        +-------------+
                             │
                        +--------------+
                        | ClockCounter |
                        +--------------+
                             │
                   +--------------------+
                   |    SystemAdjust    |
                   +--------------------+
                             │
       ┌─────────────── Outputs ────────────────┐
       │                                         │
   [ Time Values ]                         [ LEDR ]
   [ Alarm Values ]                        [ HEX0–HEX5 ]
                                           [ BuzzerOut ]
       │                                         │
                        +--------------+
                        |    Buzzer    |
                        +--------------+
```

---

## Explanation of the System

### 1. Clock and Inputs
The design begins by using the 50 MHz clock provided by the MAX10 FPGA board. Two push‑buttons (KEY0 and KEY1) are used for resetting the system and cycling through adjustment modes. Two switches (SW0 and SW1) control increment and decrement operations when adjusting time or alarm settings.

### 2. Debouncing
Mechanical buttons tend to “bounce” when pressed, causing multiple unwanted transitions.  
Two debouncer modules clean the signals from KEY0 and KEY1 so the FPGA sees a single stable transition for each press.

### 3. Rising Edge Detector
KEY1 is used to cycle through different adjustment modes.  
To ensure the system only reacts once per press, a rising‑edge detector compares the current debounced key state to the previous one and outputs a single‑cycle pulse.

### 4. Automatic Clock Counter
The `ClockCounter` module runs continuously from the 50 MHz system clock. It keeps track of hours and minutes and sends this running time into the adjustment system.

### 5. SystemAdjust Module
This is the main logic that manages:
- Time display values  
- Alarm display values  
- Increment/decrement logic  
- LEDs that show which field is selected  

It receives the automatic clock time and the adjustment inputs and outputs formatted time and alarm digits suitable for the 7‑segment displays.

### 6. Buzzer
The buzzer is enabled whenever the current time matches the alarm time.  
A small tone‑generation circuit inside the `Buzzer` module produces the square‑wave signal required to drive the external active buzzer.

### 7. 7‑Segment Display Decoding
Each time or alarm digit is fed into a separate `Hex7Seg` module, which converts the numeric value (0–9) into the appropriate 7‑segment pattern.

---

## Main Verilog Code
```verilog
`timescale 1ns / 1ps
`default_nettype none

module main(
    input  wire MAX10_CLK1_50,
    input  wire KEY0, KEY1,
    input  wire [1:0] SW,
    output wire [3:0] LEDR,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output wire BuzzerOut
);

    wire key0_db, key1_db;
    Debouncer D0(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY0), .btn_out(key0_db));
    Debouncer D1(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY1), .btn_out(key1_db));

    reg key1_prev;
    wire key1_edge;
    always @(posedge MAX10_CLK1_50) key1_prev <= key1_db;
    assign key1_edge = key1_db & ~key1_prev;

    wire [4:0] auto_hours;
    wire [5:0] auto_minutes;
    ClockCounter CC(
        .clk_50MHz(MAX10_CLK1_50),
        .reset(key0_db),
        .hours(auto_hours),
        .minutes(auto_minutes)
    );

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

    wire buzzer_en = (time_hours == alarm_hours) && (time_minutes == alarm_minutes);
    Buzzer buz(
        .clk(MAX10_CLK1_50),
        .en(buzzer_en),
        .speaker(BuzzerOut)
    );

    Hex7Seg H0(.hex(adj_minutes_units), .seg(HEX0));
    Hex7Seg H1(.hex(adj_minutes_tens),  .seg(HEX1));
    Hex7Seg H2(.hex(adj_hours_units),   .seg(HEX2));
    Hex7Seg H3(.hex(adj_hours_tens),    .seg(HEX3));
    Hex7Seg H4(.hex(alarm_minutes[3:0]), .seg(HEX4));
    Hex7Seg H5(.hex(alarm_hours[3:0]),   .seg(HEX5));

endmodule
```

---

