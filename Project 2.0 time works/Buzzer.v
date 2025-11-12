`timescale 1ns / 1ps
`default_nettype none

module Buzzer(
    input  wire clk,       // 50MHz clock from DE10-Lite
    input  wire en,        // enable buzzer (1 = ON)
    output reg  speaker    // buzzer output
);

    // Generate 440Hz tone: clk = 50MHz
    parameter clkdivider = 100000000 / 440 / 2;

    reg [23:0] tone = 0;
    always @(posedge clk)
        tone <= tone + 1;

    reg [14:0] counter = 0;
    always @(posedge clk) begin
        if (counter == 0)
            counter <= (tone[23] ? clkdivider-1 : clkdivider/2-1);
        else
            counter <= counter - 1;
    end

    always @(posedge clk) begin
        if (!en)
            speaker <= 1'b0;
        else if (counter == 0)
            speaker <= ~speaker;
    end

endmodule

`default_nettype wire
