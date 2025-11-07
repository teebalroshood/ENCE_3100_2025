# 🧠 **Lab Report: Finite State Machine (FSM) -- Chess Timer**

## 🔍 **Objective**

The purpose of this lab is to design and implement a **Finite State
Machine (FSM)** that controls a **two-player chess timer**.\
Each player's timer counts down while it's their turn. Pressing the
button switches control between players.\
When a player's time runs out, the system enters an **END** state.

## ⚙️ **Overview**

This FSM is a **Moore-type machine** implemented in **Verilog**, where
outputs depend only on the current state.\
It manages four major states: 1. **IDLE** -- system ready, both timers
are loaded\
2. **PLAYER1** -- Player 1's timer counts down\
3. **PLAYER2** -- Player 2's timer counts down\
4. **END** -- game ends when a timer reaches zero


## **Block Diagram**
<img src="images/block_diagram.png" alt="Block Diagram" width="500"/>

## **Board**
<img src="images/board.GIF" alt="Board" width="500"/>


## 🧩 **Module Declaration**

``` verilog
`default_nettype none

module FSM_ChessTimer(
    input clk,
    input reset,
    input [1:0] buttons,         // buttons[0] = Player 1, buttons[1] = Player 2
    input [9:0] counter_1,
    input [9:0] counter_2,
    output reg [1:0] load_counters,
    output reg [1:0] en_counters,
    output reg [1:0] state_displays
);
```

### Explanation

-   `clk` → System clock signal.\
-   `reset` → Resets the FSM to the initial state.\
-   `buttons` → Two buttons used by players to switch turns.\
-   `counter_1` and `counter_2` → Represent the time left for each
    player.\
-   `load_counters` → Used to load initial time values.\
-   `en_counters` → Enables counting for one player at a time.\
-   `state_displays` → Controls display output (e.g., "OG", "Pend").

## **Counters**
The chess timer system is built from several key modules. The FSM_ChessTimer acts as the "brain," while the counter modules handle the actual timekeeping.

### 1. One-Second Clock (counter_1s)
The main board provides a 50MHz clock (MAX10_CLK1_50)1, which is too fast for a human-scale timer. The counter_1s module is a clock divider that solves this.
- Purpose: To generate a single clock pulse (a "strobe") exactly once per second.

- Function: It uses a 26-bit register (counter) 2to count system clock cycles up to the DIVISOR value, which is set to 50,000,0003.

- Output: When the counter reaches DIVISOR - 1, it asserts the o_strobe signal high for one clock cycle and resets the counter to 04. This 1Hz o_strobe is wired to w_count in main.v 5 and used as the "clock" for the player timers.

    -  **The Math:** 
        1. The counter logic checks if the internal register `counter` has reached `DIVISOR - 1` (which is 49,999,999).
        2. The counter counts from 0 up to 49,999,999. This is a total of 50,000,000 distinct steps.
        3. The time for this count is calculated as:
        $$\text{Time}=\frac{\text{Cycles}}{\text{Frequency}}=\frac{50,000,000\text{ Cycles}}{50,000,000\text{ Cycles/s}}=1 \text{ Second}$$

### 2. Player Timers (counter_Nbits)
This is a generic, parameterized module used to store and decrement each player's time.
Purpose: To hold a player's remaining time and count down when enabled by the FSM.

- Instantiation: It is used twice in main.v: once for Counter_1 and once for Counter_2.

- N-bits: It is configured with the default parameter `N = 10` bits, allowing it to hold values from 0-1023.
Load: The `i_reset` port is used as a "load" signal.When high, it loads the `i_data` value into the counter. This is controlled by the FSM's `w_load_counters` output.

- Enable: The `i_enable` port allows the FSM to start or stop the countdown.

- Direction: The `i_dir` port is set to `1'b0` (down), which causes the counter to subtract 1 (`o_count <= o_count - 10'd`) on each 1-second clock tick.

- High Level Explanation
    - This module's input, `i_clk`, is connected to the 1-second `w_count` strobe from a separate module, `counter_1s`. Therefore, all its internal math operations happen only **once per second**.

    - **The Math (Range)**
        - The counter is parameterized with `N = 10` bits.
        - The counter can store any value from $\mathbf{0}$ to $\mathbf{1023}$.
    - **The Math (Loading)**
        - The `i_reset` port is used as a **"load" signal**.
        - When the FSM activates this signal, the counter loads the value from the `i_data` input.
        - In `main.v`, this value is hard-coded to `10'd5`.
        - **Operation:** $o\_count \le 5$. This sets the **start time to 5 seconds**.
    - **The Math (Counting Down)**
        - The module's direction is hard-coded by `i_dir=1`, which means **"count down"**.
        - When the FSM enables the counter `i_enable = 1` and the 1-second tick arrives, the counter performs this operation:
            $$\text{o\_count} = \text{o\_count} - 1$$

## 🔢 **State Encoding**

``` verilog
    localparam IDLE    = 2'b00;
    localparam PLAYER1 = 2'b01;
    localparam PLAYER2 = 2'b10;
    localparam END     = 2'b11;
```

  State Name   Binary Code   Description
  ------------ ------------- -----------------------
  IDLE         `00`          Wait for player input
  PLAYER1      `01`          Player 1's turn
  PLAYER2      `10`          Player 2's turn
  END          `11`          Game over

## 🔄 **1. State Register (Sequential Logic)**

``` verilog
    reg [1:0] state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end
```

This always block updates the current state on each clock cycle. When
reset is active, FSM goes back to IDLE.

## 🧠 **2. Next-State Logic (Combinational Logic)**

``` verilog
    always @(*) begin
        case (state)
            IDLE: begin
                if (buttons[0])
                    next_state = PLAYER1;
                else if (buttons[1])
                    next_state = PLAYER2;
                else
                    next_state = IDLE;
            end

            PLAYER1: begin
                if (counter_1 == 10'd0)
                    next_state = END;
                else if (buttons[1])
                    next_state = PLAYER2;
                else
                    next_state = PLAYER1;
            end

            PLAYER2: begin
                if (counter_2 == 10'd0)
                    next_state = END;
                else if (buttons[0])
                    next_state = PLAYER1;
                else
                    next_state = PLAYER2;
            end

            END: begin
                if (reset)
                    next_state = IDLE;
                else
                    next_state = END;
            end

            default: next_state = IDLE;
        endcase
    end
```

This block decides which state to go to next based on input conditions.

## 💡 **3. Output Logic (Combinational Logic)**

``` verilog
    always @(*) begin
        load_counters   = 2'b00;
        en_counters     = 2'b00;
        state_displays  = 2'b00;

        case (state)
            IDLE: begin
                load_counters   = 2'b11;
                en_counters     = 2'b00;
                state_displays  = 2'b00;
            end

            PLAYER1: begin
                en_counters     = 2'b01;
                state_displays  = 2'b01;
            end

            PLAYER2: begin
                en_counters     = 2'b10;
                state_displays  = 2'b01;
            end

            END: begin
                state_displays  = 2'b10;
            end
        endcase
    end
```

## 🧾 **State Diagram (Description)**

         +-------+
         | IDLE  |
         +-------+
           |  buttons[0]
           v
       +-----------+          +-----------+
       | PLAYER1   |<-------->|  PLAYER2  |
       +-----------+          +-----------+
           | counter_1==0          | counter_2==0
           v                       v
          +------ GAME END ------+
          |         END          |
          +----------------------+

## ✅ **Conclusion**

This FSM successfully models a two-player chess timer that alternates
turns, detects timeouts, and displays state status.
