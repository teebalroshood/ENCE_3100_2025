# Lab 5 – Adders, Subtractors, and Multipliers

## 🎯 Objective
The purpose of this laboratory exercise is to design and analyze arithmetic circuits that **add**, **subtract**, and **multiply** numbers using Verilog HDL.  
Each design will be simulated and implemented on an **Altera DE2/DE10-Lite FPGA board**.

---

## 🧩 Part I – 8-bit Ripple-Carry Adder

### 🔍 Description
Implements an 8-bit adder circuit that uses the Verilog `+` operator to add two 8-bit values.  
The output shows the sum and overflow result.

### 🧠 Concepts
- Ripple-Carry Adder
- Overflow detection
- Registering outputs with flip-flops

### ⚙️ Verilog Code
```verilog
module adder_8bit(
    input [7:0] A,
    input [7:0] B,
    output [7:0] Sum,
    output Carry
);
    assign {Carry, Sum} = A + B;
endmodule
```

### 🧪 Testing Setup
- `SW[7:0]` → Input A  
- `SW[15:8]` → Input B  
- `LEDR[7:0]` → Sum  
- `LEDR[8]` → Carry

---

## ➕➖ Part II – Adder/Subtractor

### 🔍 Description
Adds or subtracts two 8-bit numbers based on control signal `add_sub`.

### ⚙️ Verilog Code
```verilog
module add_sub_8bit(
    input [7:0] A,
    input [7:0] B,
    input add_sub, // 0 = add, 1 = subtract
    output [7:0] Result,
    output Carry
);
    wire [7:0] B_in;
    assign B_in = (add_sub) ? ~B + 1'b1 : B;
    assign {Carry, Result} = A + B_in;
endmodule
```

---

## ✖️ Part III – 4-bit Array Multiplier

### 🔍 Description
Implements a 4-bit array multiplier using AND gates and full adders.

### ⚙️ Verilog Code
```verilog
module multiplier_4bit(
    input [3:0] A,
    input [3:0] B,
    output [7:0] P
);
    wire [3:0] pp0 = A & {4{B[0]}};
    wire [3:0] pp1 = A & {4{B[1]}};
    wire [3:0] pp2 = A & {4{B[2]}};
    wire [3:0] pp3 = A & {4{B[3]}};

    assign P = (pp0) + (pp1 << 1) + (pp2 << 2) + (pp3 << 3);
endmodule
```

---

## 🧮 Part IV – 8x8 Registered Multiplier

### 🔍 Description
Implements an 8x8 multiplier with registered inputs and outputs.

### ⚙️ Verilog Code
```verilog
module registered_multiplier_8x8(
    input clk,
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] P
);
    reg [7:0] A_reg, B_reg;
    wire [15:0] mult_out;

    assign mult_out = A_reg * B_reg;

    always @(posedge clk) begin
        A_reg <= A;
        B_reg <= B;
        P <= mult_out;
    end
endmodule
```

---

## 🌳 Part V – Adder Tree Multiplier

### 🔍 Description
Implements an 8x8 multiplier using an adder tree structure for parallel summation.

### ⚙️ Verilog Code
```verilog
module adder_tree_multiplier_8x8(
    input clk,
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] P
);
    reg [7:0] A_reg, B_reg;
    wire [15:0] partial [7:0];

    integer i;
    always @(posedge clk) begin
        A_reg <= A;
        B_reg <= B;
    end

    // Generate partial products
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : pp
            assign partial[j] = (A_reg & {8{B_reg[j]}}) << j;
        end
    endgenerate

    // Adder tree (two-level reduction for simplicity)
    wire [15:0] sum1 = partial[0] + partial[1];
    wire [15:0] sum2 = partial[2] + partial[3];
    wire [15:0] sum3 = partial[4] + partial[5];
    wire [15:0] sum4 = partial[6] + partial[7];
    wire [15:0] sum5 = sum1 + sum2;
    wire [15:0] sum6 = sum3 + sum4;

    always @(posedge clk) begin
        P <= sum5 + sum6;
    end
endmodule
```

---

## 🧪 Testing and Verification
Perform functional and timing simulations for each design. Record outputs and overflow conditions.

| Part | Circuit | fmax (MHz) | Logic Elements | Verified on FPGA |
|------|----------|-------------|----------------|------------------|
| I | 8-bit Adder | | | |
| II | Adder/Subtractor | | | |
| III | 4-bit Multiplier | | | |
| IV | 8x8 Registered Multiplier | | | |
| V | 8x8 Adder Tree | | | |

---

## 🧾 Conclusion
- Increasing circuit complexity reduces maximum clock frequency.
- Registered designs improve stability.
- Adder tree structures enable faster multiplication.

---

## 🧰 Tools Used
- **Intel Quartus II / Quartus Prime (2021+)**
- **ModelSim** for simulation
- **Altera DE2/DE10-Lite FPGA Board**

---

## 📚 References
- Altera Laboratory Manual: *Adders, Subtractors, and Multipliers*
- *Digital Design: Principles and Practices* – John F. Wakerly
