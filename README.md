# Laboratory Exercise 2 – Numbers and Displays

## Course Info
- **Course:** [Insert course name/code]  
- **Instructor:** [Insert instructor name]  
- **Date:** [Insert submission date]  
- **Student Name:** [Insert your name]  

---

## Objective
This lab explores the design of combinational circuits in Verilog that perform:
- Binary-to-decimal number conversion  
- Binary-coded decimal (BCD) addition  
- Ripple-carry addition  
- Displaying results on 7-segment displays  

---

## Equipment & Tools
- Altera/Intel DE2 FPGA board  
- Quartus II software  
- Verilog HDL  

---

## Part I – 7-Segment Display
**Goal:** Display switch values (`SW15–0`) onto `HEX3–HEX0`.  
- Implemented using Boolean expressions (`assign` statements only).  
- Inputs above `1001` treated as "don’t cares".  

**Implementation Screenshot:**  
![](images/part1.png)  

**Testing:**  
- Switch inputs `0000–1001` verified correct decimal output.  
- Inputs `1010–1111` ignored as per spec.  

---

## Part II – Binary to Decimal Converter
**Goal:** Convert 4-bit binary `V = v3v2v1v0` into two-digit decimal.  
- Used comparator, multiplexers, and "Circuit A".  
- Verified with simulation and FPGA implementation.  

**Diagram:**  
![](images/part2_block.png)  

**Testing Table:**  
| Input (Binary) | Output (Decimal) | HEX1 | HEX0 |
|----------------|------------------|------|------|
| 0000 | 00 | 0 | 0 |
| 1001 | 09 | 0 | 9 |
| 1010 | 10 | 1 | 0 |
| 1111 | 15 | 1 | 5 |

---

## Part III – Ripple-Carry Adder
**Goal:** Build a 4-bit adder using full adders.  
- Inputs: `SW7–0` for operands A and B, `SW8` for Cin.  
- Outputs: Sum (HEX displays) and carry-out.  

**Circuit Design:**  
![](images/part3_rtl.png)  

---

## Part IV – BCD Adder
**Goal:** Add two BCD digits (A, B + Cin).  
- Implemented using ripple-carry adder from Part III.  
- Displayed result in BCD form.  
- Error check added for invalid inputs (>9).  

---

## Part V – Two-Digit BCD Adder
**Goal:** Add two 2-digit BCD numbers (`A1A0 + B1B0`).  
- Output: Three-digit BCD result (`S2S1S0`).  
- Used two instances of the Part IV adder.  

---

## Part VI – Algorithmic BCD Adder
**Goal:** Implement two-digit BCD adder using **if-else algorithm**.  
- Compared RTL structure with Part V.  
- Observed Quartus optimizations.  

---

## Part VII – Graduate Requirement
**Goal:** Convert 6-bit binary input into 2-digit BCD.  
- Input: `SW5–0`  
- Output: `HEX1–HEX0`  

---

## Results & Discussion
- **Observations:** [Write about what worked well, challenges, differences between Boolean and algorithmic approaches]  
- **Testing Evidence:** [Insert photos/screenshots of FPGA showing working outputs for each part]  

---

## Conclusion
- Successfully implemented multiple combinational circuits in Verilog.  
- Gained experience with binary-to-decimal conversion, ripple-carry adders, and BCD arithmetic.  
- Compared structural and algorithmic design styles in Verilog.  

---

## Appendix
- **Verilog Code:** [Paste final main.v code here or link to source files]  
- **Simulation Waveforms:** [Insert screenshots]  
- **FPGA Pin Assignments:** [Attach CSV or table]  
