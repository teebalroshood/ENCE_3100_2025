# Lab 4 Report

## Simulation  
<img src="/images/Part_1.GIF" width="400">

<img src="/images/Part_2.GIF" width="400">

<img src="/images/Part_3.GIF" width="400">

<img src="/images/Part_4.GIF" width="400">


## Introduction
This lab focuses on building different types of counters on the DE10‑Lite FPGA board and displaying their outputs on the 7‑segment HEX displays. Each part of the assignment adds a new feature, starting from a basic T flip‑flop counter and ending with more advanced timing and display control.

Below is the full report with explanations and block diagrams to help visualize the data flow.

---

# **Block Diagram – High-Level System**
```
        +-------------------------+
        |      MAX10 FPGA        |
        |                         |
        |   +-----------------+   |
 SW --->|-->|   Counter(s)    |---|--> LEDR
        |   +-----------------+   |
        |             |           |
        |        +---------+      |
        |        |  HEX    |------|--> HEX Displays
        |        |Decoder  |      |
 KEY -->|--------+---------+      |
        +-------------------------+
```
This diagram shows the general structure used in all parts: inputs (KEY, SW) control a counter, and the results are displayed on the LEDs and HEX displays.

---

# **Part I — 8‑bit T Flip‑Flop Counter**
This part creates a simple 8‑bit counter using eight T‑flip‑flops connected in a chain.

## **Block Diagram – T‑FF Counter**
```
      Clock
        |
        v
   +---------+     +---------+     +---------+
   |  TFF0   | --> |  TFF1   | --> |  TFF2   | --> ... (8 bits)
   +---------+     +---------+     +---------+
        |              |               |
       Q[0]           Q[1]           Q[2] ... Q[7]
```
Each T‑flip‑flop toggles when T=1. The least significant stage toggles every clock, and each stage after toggles when all previous bits are 1. This creates a binary counter.

## **Explanation**
- `KEY[0]` is treated as a clock input. Because DE10‑Lite buttons are active‑low, the clock is inverted.
- `SW[1]` enables counting.
- `SW[0]` acts as a synchronous clear.
- The 8‑bit output is split into two 4‑bit nibbles and sent to two 7‑segment decoders (HEX1 and HEX0).
- LEDs mirror the count.

---

# **Part II — Shift Register Display**
In this part, the output of a shift register is displayed on two HEX displays.

## **Block Diagram – Shift Register**
```
        Clock
          |
          v
  +--------------+
  | Shift Reg    |
  |  (8 bits)    |
  +--------------+
       |     |
     Q[3:0] Q[7:4]
       |     |
   HEX0    HEX1
```

## **Explanation**
- Instead of counting, this circuit shifts bits left or right.
- The user controls shifting using switches.
- The HEX displays show the lower and upper halves of the register.

---

# **Part III — LPM Counter**
Altera/Intel provides an LPM (Library of Parameterized Modules) counter, which simplifies creating counters.

## **Block Diagram – LPM Counter**
```
       +-------------------+
Clock-->|   LPM Counter    |---> 8-bit Output
Clear-->|                   |
       +-------------------+
             |      |
           Q[3:0] Q[7:4]
             |      |
          HEX0    HEX1
```

## **Explanation**
- This version uses the vendor‑provided LPM Counter.
- Clear and enable signals come from switches.
- The output is again sent to two 7‑segment decoders.
- This reduces manual flip‑flop wiring.

---

# **Part IV — One‑Second Counter and Mod‑10 Display**
This part introduces a time‑based counter.

## **Block Diagram – 1 Hz Tick + Digit Counter**
```
         +------------------+
Clock --->| 1 Hz Generator  |----> tick
         +------------------+
                    |
                    v
             +--------------+
             | Digit 0–9    |
             |   Counter    |
             +--------------+
                    |
                    v
                seg7Decoder
                    |
                    v
                  HEX0
```

## **Explanation**
- A 26‑bit counter divides the 50 MHz system clock down to 1 Hz.
- The output tick increments a digit register every second.
- The digit automatically resets to 0 after reaching 9.
- The digit appears on HEX0.

---

# **Part V — Scrolling "HELLO" Display**
This is the final and most advanced part, combining a tick generator, indexing logic, and letter decoding.

## **Block Diagram – HELLO Scroller**
```
                +-------------+
Clock ---------->| 1 Hz Tick  |----+
                +-------------+    |
                                     v
          Message ROM (HELLO coded as 0,1,2,2,3)
        +----------------------------------------+
        | msg[0] msg[1] msg[2] msg[3] msg[4]     |
        +----------------------------------------+
                     ^
                     |
                 index i
                     |
         +-----------------------+
         |  Scrolling Logic      |
         | selects msg[i]        |
         | and msg[i+1]         |
         +-----------------------+
             |             |
             v             v
        seg7_letter    seg7_letter
             |             |
           HEX1         HEX0
```

## **Explanation**
- A 1 Hz tick is used to scroll letters forward one position every second.
- The word **"HELLO"** is stored in a 5‑element array using numeric codes.
- An index `i` cycles from 0 to 4.
- The display shows two characters at a time:
  - Left letter → `msg[i]`
  - Right letter → `msg[i+1]` (wraps around)
- `seg7_letter` converts the letter codes into segment signals for HEX0 and HEX1.

---

# **Conclusion**
This lab walks through several important FPGA concepts:
- Building counters from flip‑flops
- Using shift registers
- Working with LPM modules
- Designing clock division for timing
- Displaying values using 7‑segment decoders
- Creating animation through index‑based scrolling

Each section builds on the previous one, leading to the final "HELLO" scroller, which combines timing, indexing, and display control.

If you want to add the full code or insert a GIF demonstration, I can include those as well.

