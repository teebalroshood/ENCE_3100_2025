# Lab 3: Latches, Flip-Flops, and Registers

This lab explores the design and implementation of **latches, flip-flops, and registers** using Verilog HDL on the Quartus II platform.  
We simulate, synthesize, and test the circuits on the Altera DE2/DE2-115 FPGA board.

---

## 📌 Objectives
- Understand the behavior of RS latches, D latches, and flip-flops.  
- Learn to describe storage elements using **Verilog code**.  
- Verify designs using both **simulation** and **FPGA hardware testing**.  

---

## ⚙️ Lab Sections

### Part I – RS Latch
Implementation of a **gated RS latch** using Verilog. Simulation confirms correct latch behavior.  

![RS Latch Simulation](images/rs_latch.gif)

---

### Part II – Gated D Latch
Design and implementation of a **gated D latch** with preserved internal signals.  

![D Latch Simulation](images/d_latch.gif)

---

### Part III – Master-Slave D Flip-Flop
Construction of a **master-slave flip-flop** by cascading two gated D latches.  

![Master-Slave Flip-Flop](images/ms_flipflop.gif)

---

### Part IV – Latch vs Flip-Flops
Comparison between:  
- Gated D latch  
- Positive-edge triggered D flip-flop  
- Negative-edge triggered D flip-flop  

![Latch vs Flip-Flops](images/latch_vs_flops.gif)

---

### Part V – Register Storage
Circuit to store and display **16-bit numbers** on the 7-segment displays of the DE2 board.  
- `SW[15:0]` provide inputs A and B  
- `HEX7–HEX0` display stored hex values  

![Register Storage](images/register_storage.gif)

---

## 🛠️ Tools Used
- **Quartus II** (Intel/Altera FPGA design software)  
- **QSim (Quartus Simulator)**  
- **Altera DE2 / DE2-115 FPGA board**  

---

## ✅ Results
- RS latch, D latch, and flip-flops were successfully implemented.  
- Both **functional** and **timing simulations** matched expected outputs.  
- FPGA hardware tests confirmed correct operation.  
- Register circuit properly stored and displayed 16-bit hex values.

---

## 📚 Reference
Lab manual: *Lab 3 – Latches, Flip-Flops, and Registers*
