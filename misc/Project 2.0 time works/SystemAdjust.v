`timescale 1ns / 1ps
`default_nettype none

module SystemAdjust(
    input  wire clk,
    input  wire reset,
    input  wire key_cycle,    // single-clock pulse
    input  wire sw_inc,
    input  wire sw_dec,
    input  wire [4:0] auto_hours,
    input  wire [5:0] auto_minutes,
    output reg  [3:0] adj_minutes_units,
    output reg  [3:0] adj_hours_units,
    output reg  [2:0] adj_minutes_tens,
    output reg  [2:0] adj_hours_tens,
    output reg  [1:0] adjusted, 
    output reg  [4:0] time_hours_out,
    output reg  [5:0] time_minutes_out,
    output reg  [4:0] alarm_hours_out,
    output reg  [5:0] alarm_minutes_out,
    output reg  [3:0] LED
);

    // ===== FSM states =====
    localparam TIME_H  = 2'b00;
    localparam TIME_M  = 2'b01;
    localparam ALARM_H = 2'b10;
    localparam ALARM_M = 2'b11;

    reg [1:0] state;
    reg sw_inc_last, sw_dec_last;

    // ===== Time / Alarm registers =====
    reg [4:0] time_hours;
    reg [5:0] time_minutes;
    reg [4:0] alarm_hours = 5'd6;
    reg [5:0] alarm_minutes = 6'd0;

    // ===== FSM: Cycle fields =====
    always @(posedge clk or posedge reset) begin
        if(reset)
            state <= TIME_H;
        else if(key_cycle) begin
            case(state)
                TIME_H:  state <= TIME_M;
                TIME_M:  state <= ALARM_H;
                ALARM_H: state <= ALARM_M;
                ALARM_M: state <= TIME_H;
            endcase
        end
    end

    // ===== Increment / Decrement or Automatic Clock =====
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            time_hours   <= 5'd12;
            time_minutes <= 6'd0;
            sw_inc_last  <= 1'b0;
            sw_dec_last  <= 1'b0;
        end else begin
            if(sw_inc && !sw_inc_last) begin
                case(state)
                    TIME_H:  time_hours   <= (time_hours==23)?0:time_hours+1;
                    TIME_M:  time_minutes <= (time_minutes==59)?0:time_minutes+1;
                    ALARM_H: alarm_hours  <= (alarm_hours==23)?0:alarm_hours+1;
                    ALARM_M: alarm_minutes<= (alarm_minutes==59)?0:alarm_minutes+1;
                endcase
            end
            if(sw_dec && !sw_dec_last) begin
                case(state)
                    TIME_H:  time_hours   <= (time_hours==0)?23:time_hours-1;
                    TIME_M:  time_minutes <= (time_minutes==0)?59:time_minutes-1;
                    ALARM_H: alarm_hours  <= (alarm_hours==0)?23:alarm_hours-1;
                    ALARM_M: alarm_minutes<= (alarm_minutes==0)?59:alarm_minutes-1;
                endcase
            end

            // Automatic clock update if not adjusting
            if(state != TIME_H && state != TIME_M) begin
                time_hours   <= auto_hours;
                time_minutes <= auto_minutes;
            end

            sw_inc_last <= sw_inc;
            sw_dec_last <= sw_dec;
        end
    end

    // ===== Outputs =====
    always @(*) begin
        case(state)
            TIME_H:  LED = 4'b1000;
            TIME_M:  LED = 4'b0100;
            ALARM_H: LED = 4'b0010;
            ALARM_M: LED = 4'b0001;
        endcase

        adj_hours_tens    = time_hours / 10;
        adj_hours_units   = time_hours % 10;
        adj_minutes_tens  = time_minutes / 10;
        adj_minutes_units = time_minutes % 10;

        time_hours_out    = time_hours;
        time_minutes_out  = time_minutes;
        alarm_hours_out   = alarm_hours;
        alarm_minutes_out = alarm_minutes;

        adjusted[1] = 1'b1;
        adjusted[0] = 1'b1;
    end

endmodule
`default_nettype wire
