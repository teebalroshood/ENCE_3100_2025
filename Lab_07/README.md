# Lab 07 --- FSM, 5-Second Counter, and 7-Segment Display

## 🎬 System Overview GIF

<img src="images/lab7.GIF" alt="lab07" width="500"/>

------------------------------------------------------------------------

## ✅ Finite State Machine (FSM) Explanation

The FSM controls the system behavior based on inputs and timing
conditions. It transitions between predefined states depending on the
current state, user input, and timing signals.

### FSM Core Concepts

  Feature           Description
  ----------------- ---------------------------------------------
  **States**        IDLE → COUNT → DONE
  **Reset**         Returns to IDLE
  **Start Input**   Moves system from IDLE → COUNT
  **Done Signal**   Indicates 5 seconds elapsed → moves to DONE

### FSM Operation Flow

    Reset → IDLE → (Start) → COUNT → (5 sec reached) → DONE

### Simplified Description

> The FSM decides **what the system should be doing next** based on time
> and button input.

------------------------------------------------------------------------

## ⏱️ 5-Second Counter Explanation

The counter generates a 5‑second delay using the 50 MHz FPGA clock.

### Breakdown

  Step            Description
  --------------- -----------------------------
  Clock Divider   Converts 50 MHz → 1 Hz
  5‑Counter       Counts 5 pulses (5 seconds)
  Done Signal     Goes high after 5 seconds

### Simple View

> Think of it as a **5‑second stopwatch** that tells the FSM when time
> is up.

------------------------------------------------------------------------

## 🧠 char2seg --- 7 Segment Decoder

The `char2seg` module converts a 4-bit input (0‑F) into 7‑segment
display signals.

Example: - Input: `4'hA` - Output: LED pattern showing **A** on HEX
display

------------------------------------------------------------------------

## 🧱 System Block Diagram

    +-----------------------+
    |         FSM           |
    | IDLE → COUNT → DONE   |
    +----------+------------+
               |
               v
    +----------+------------+
    |   5‑Second Counter    |
    | Clock Divide + Timer  |
    +----------+------------+
               |
               v
    +----------+------------+
    | 7‑Segment Display     |
    |     char2seg          |
    +-----------------------+

------------------------------------------------------------------------

## 📂 Files Included

  File             Purpose
  ---------------- ---------------------------
  `fsm.v`          Controls states
  `counter_5s.v`   Generates 5s timing pulse
  `char2seg.v`     7‑segment decoder

------------------------------------------------------------------------

## ✅ To‑Do / Insert Areas

-   [ ] Insert circuit GIF
-   [ ] Add Quartus pin assignment table
-   [ ] Insert timing waveforms screenshots

------------------------------------------------------------------------

## 🧪 Demo Instructions

1.  Program FPGA with Quartus `.sof` file\
2.  Press **Start Button** to begin counting\
3.  Observe 7‑segment display count and timeout

------------------------------------------------------------------------

## 👨‍💻 Author

Lab Report for **ENCE 3100 --- Digital Logic**
