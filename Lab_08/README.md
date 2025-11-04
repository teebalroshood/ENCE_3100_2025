![Block Diagram](./images/lab_08.GIF)

# 4-Bit Accumulator System (FPGA)

This project implements a **4-bit accumulator-based datapath** using Verilog.  
The system includes:

- Two 4-bit Accumulators (A and B)
- An Arithmetic Unit
- A top-level control module
- Shared internal data bus
- Latching & enable control

---

## 🎬 System Explanation GIF  
> _Insert demo GIF below (waveforms / FPGA screenshot / block animation)_

![project-demo](path/to/your.gif)

---

## 🧠 High-Level Overview

This design performs arithmetic operations using a pair of accumulators and an ALU.  
A shared bus moves data between modules, and control signals determine when each register loads or outputs data.

### 🏗 Block Diagram

- **Accumulator A** → holds operand A  
- **Accumulator B** → holds operand B  
- **Arithmetic Unit** → performs add/sub/logic on A and B  
- **Top module** → connects datapath + control  

---

## 📦 File Structure

| File | Purpose |
|------|--------|
| `Accumulator_A.v` | 4-bit accumulator register (A) |
| `Accumulator_B.v` | 4-bit accumulator register (B) |
| `Arithmetic_Unit.v` | ALU performing operations |
| `main.v` | Top-level module wiring everything |

---

## 🔁 Accumulator A (Register + Bus Interface)

### ✅ Function  
Stores a 4-bit value and can place its output on the internal bus.

### 🧩 Key Behavior
| Control Signal | Function |
|----------------|---------|
| `LatchA` | Load new value from bus |
| `EnableA` | Output value onto bus |
| `ClearA` | Reset accumulator |

### 📄 Code Snippet
```verilog
module Accumulator_A(
    input  wire MainClock,
    input  wire ClearA,
    input  wire LatchA,
    input  wire EnableA,
    inout  wire [3:0] IB_BUS,
    output wire [3:0] A,
    output wire [3:0] AluA
);

// ✅ paste your full logic here

endmodule
```

---

## 🔁 Accumulator B

Same behavior as Accumulator A, but stores operand **B**.

```verilog
module Accumulator_B(
    input  wire MainClock,
    input  wire ClearB,
    input  wire LatchB,
    input  wire EnableB,
    inout  wire [3:0] IB_BUS,
    output wire [3:0] B,
    output wire [3:0] AluB
);

// ✅ paste your full logic here

endmodule
```

---

## ➕ Arithmetic Unit (ALU)

### ✅ Function  
Takes inputs from Accumulator A & B and computes:

- Addition
- Subtraction
- Pass-through
- Logic operations (if implemented)

### 📄 Code Snippet
```verilog
module Arithmetic_Unit(
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [1:0] ALU_Sel,  // operation select
    output wire [3:0] Result
);

// ✅ your ALU operations here

endmodule
```

---

## 🏠 `main.v` — Top-Level Integration

Controls the datapath, bus, and clock.

```verilog
module main(
    input  wire MainClock,
    input  wire Reset,
    inout  wire [3:0] IB_BUS
);

// ✅ instantiate accumulators + ALU here

endmodule
```

---

## 🧪 Simulation / Testing

### ✅ What to Verify
- Each accumulator loads only when `LatchX=1`
- Bus conflict protection (only one Enable at a time)
- ALU produces correct results
- Reset clears registers

---

## 🛠 FPGA Notes

| Item | Info |
|------|-----|
| Board | Intel / DE-10 Lite |
| Clock | 50 MHz internal |
| Simulation | ModelSim / Questa |

---

## 📚 Future Work
- Extend to 8-bit datapath
- Add instruction ROM & control FSM
- Support more ALU operations (AND, OR, XOR, CMP)

---

## 🎯 Conclusion

This project demonstrates **fundamental computer architecture concepts**:

- Register-Transfer logic
- Shared bus communication
- Accumulator-based arithmetic datapath

