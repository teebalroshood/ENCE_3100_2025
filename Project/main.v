`timescale 1ns / 1ps
`default_nettype none

module main(
    input  wire MAX10_CLK1_50,    // 50 MHz clock
    input  wire KEY0, KEY1,       // active-low buttons
    input  wire [1:0] SW,         // SW0 = increment, SW1 = decrement
    output wire [3:0] LEDR,
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output wire BuzzerOut
);

    // ===== Debounce Keys =====
    wire key0_db, key1_db;
    Debouncer D0(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY0), .btn_out(key0_db));
    Debouncer D1(.clk(MAX10_CLK1_50), .rst(1'b0), .btn_in(~KEY1), .btn_out(key1_db));

    // ===== Rising Edge Detector for KEY1 =====
    reg key1_prev;
    wire key1_edge;
    always @(posedge MAX10_CLK1_50) key1_prev <= key1_db;
    assign key1_edge = key1_db & ~key1_prev;  // 1-clock pulse per press

    // ===== Internal wires =====
    wire [4:0] time_hours, alarm_hours;
    wire [5:0] time_minutes, alarm_minutes;
    wire [3:0] adj_hours_units, adj_minutes_units;
    wire [2:0] adj_hours_tens, adj_minutes_tens;
    wire [1:0] adjusted;

    // ===== SystemAdjust =====
    SystemAdjust SA(
        .clk(MAX10_CLK1_50),
        .reset(key0_db),       // KEY0 = reset
        .key_cycle(key1_edge), // KEY1 = cycle field (edge)
        .sw_inc(SW[0]),        // increment
        .sw_dec(SW[1]),        // decrement
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
    Buzzer buz(.clk(MAX10_CLK1_50), .en(buzzer_en), .speaker(BuzzerOut));

    // ===== HEX Displays =====
    Hex7Seg H0(.hex(adj_minutes_units),   .seg(HEX0));
    Hex7Seg H1(.hex(adj_minutes_tens),    .seg(HEX1));
    Hex7Seg H2(.hex(adj_hours_units),     .seg(HEX2));
    Hex7Seg H3(.hex(adj_hours_tens),      .seg(HEX3));
    Hex7Seg H4(.hex(alarm_minutes[3:0]), .seg(HEX4));
    Hex7Seg H5(.hex(alarm_hours[3:0]),   .seg(HEX5));

endmodule
