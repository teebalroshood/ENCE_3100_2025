# 🔢 Lab 4 – Verilog Counters (DE10-Lite Implementation)

**Course:** Digital Logic Design  
**Lab Objective:** Design and implement various types of counters using Verilog HDL and test them on an FPGA board.  
**Reference:** Adapted from *Laboratory Exercise 4: Counters (Altera DE2 Series)*

![Project Overview](images/lab4_overview.png)
> *(Insert an image or diagram showing your FPGA board or overall circuit design.)*

---

## 📘 Table of Contents
- [Overview](#overview)
- [Part I – 8-bit T Flip-Flop Counter](#part-i--8-bit-t-flip-flop-counter)
- [Part II – Register-based Counter](#part-ii--register-based-counter)
- [Part III – LPM Counter](#part-iii--lpm-counter)
- [Part IV – One-Second HEX Display Counter](#part-iv--one-second-hex-display-counter)
- [Part V – Scrolling “HELLO” Display](#part-v--scrolling-hello-display)
- [Preparation](#preparation)
- [Results](#results)
- [Team Information](#team-information)

---

## 🧩 Overview

This lab explores the design of **synchronous and asynchronous counters** using **Verilog HDL**, emphasizing their implementation on an **FPGA (DE10-Lite)**.

Students will:
- Create and simulate different types of counters.
- Display count values on HEX displays.
- Compare circuit implementations (manual design, register-based, and LPM).

![Counter Concept](images/counter_concept.png)
> *(Insert a conceptual diagram showing counter operation or timing.)*

---

## ⚙️ Part I – 8-bit T Flip-Flop Counter

Design an **8-bit synchronous counter** built from **T flip-flops**, similar to Figure 1 in the lab handout.

**Steps:**
1. Create a `t_flipflop` module in Verilog.
2. Instantiate it 8 times in a top-level counter module.
3. Connect:
   - `KEY0` → Clock input  
   - `SW1` → Enable  
   - `SW0` → Clear  
   - `HEX1-0` → Display hexadecimal output
4. Compile and record:
   - Logic Elements (LEs)
   - Maximum frequency (Fmax)
5. Download and test on the DE10-Lite.

![8-bit Counter Diagram](images/part1.GIF)
> *(Insert schematic or Quartus block diagram screenshot.)*
<img src="images/Part_1.GIF" alt="part1" width="500"/>
---

## 🧮 Part II – Register-based Counter

Implement a **16-bit counter** using a register and simple increment statement:

```verilog
Q <= Q + 1;
```

**Tasks:**
- Compare logic usage (LEs) and Fmax with Part I.
- Visualize the synthesized structure using **RTL Viewer**.
- Discuss differences between structural (flip-flop) and behavioral (register-based) designs.

![RTL Comparison](images/part2_rtl.png)
> *(Insert RTL schematic comparison image.)*
<img src="images/Part_2.GIF" alt="part2" width="500"/>
---

## 🧰 Part III – LPM Counter

Use a **Library of Parameterized Modules (LPM)** component to create a 16-bit counter.

**Requirements:**
- Enable and synchronous clear signals.
- Compare this version with the previous designs regarding structure and performance.

![LPM Wizard Setup](images/part3_lpm.png)
> *(Insert screenshot of Quartus LPM Counter setup window.)*
<img src="images/Part_3.GIF" alt="part3" width="500"/>

---

## ⏱️ Part IV – One-Second HEX Display Counter

Create a circuit that **flashes digits 0–9** on `HEX0`:
- Each digit stays for **about one second**.
- Use a counter incremented by the **50 MHz clock**.
- All flip-flops must be clocked by the **same 50 MHz source** (no derived clocks).

![One-Second Counter](images/part4_one_sec_counter.png)
> *(Insert simulation waveform or HEX display photo showing digits changing.)*
<img src="img/Part_4.GIF" alt="part4" width="500"/>

---

## 💡 Part V – Scrolling “HELLO” Display

Display **“HELLO”** on `HEX7–HEX0` in a **ticker-tape fashion**:
- Shift letters left every ~1 second.
- Use Table 1 from the lab to define display patterns.

| Clock Cycle | Display Pattern |
|--------------|-----------------|
| 0–3 | H E L L O |
| 4 | E L L O H |
| 5 | L L O H E |
| 6 | L O H E L |
| 7 | O H E L L |
| 8 | H E L L O |

![HELLO Animation](images/part5_hello_scroll.png)
> *(Insert GIF or sequence showing scrolling text.)*
<img src="images/Part_5.GIF" alt="part5" width="500"/>

---

## 🧠 Preparation

Before lab:
- Write Verilog code for Parts I–III.
- Simulate Part I.
- Reuse HEX display module from previous labs.

![Preparation Screenshot](images/preparation.png)
> *(Insert Quartus project or simulation setup image.)*

---

## 📊 Results

| Part | LEs Used | Fmax (MHz) | Notes |
|------|-----------|-------------|-------|
| I |  |  |  |
| II |  |  |  |
| III |  |  |  |
| IV |  |  |  |
| V |  |  |  |

![Results Graph](images/results.png)
> *(Insert chart or summary screenshots here.)*

---

## 👥 Team Information

| Name | Role | Contact |
|------|------|----------|
| Your Name | Verilog Developer | your.email@example.com |
| Lab Partner | Simulation Engineer | partner.email@example.com |

![Team Photo](images/team_photo.png)
> *(Add team or project photo if desired.)*

---

## 📚 License

This project is based on educational material © Altera Corporation (2011).  
All derivative Verilog designs © Your Institution / Team.

---

> 📝 **Tip:** Keep all screenshots in an `images/` folder and use relative paths like  
> `![Title](images/example.png)` for proper linking on GitHub.
