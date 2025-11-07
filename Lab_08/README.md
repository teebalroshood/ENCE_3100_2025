# 4-Bit Micro-Instruction Based Accumulator System (FPGA)

This project implements a **complete micro-instruction-based datapath** using Verilog on an Intel MAX10 FPGA board (DE-10 Lite). The system includes a full processor-like architecture with accumulators, ALU, instruction decoding, program memory, and finite state machine control.

---

## System Explanation

This design performs sequential arithmetic and logic operations using:
- A **datapath** with accumulators and ALU
- A **control unit** (FSM) that sequences operations via micro-instructions
- **Program memory (ROM)** containing encoded instructions
- A **program counter** to track instruction fetch
- **Input/Output registers** for external communication

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│  Program Memory (ROM) ← Program Counter         │
├─────────────────────────────────────────────────┤
│  Instruction Register ← Decoded from ROM        │
├─────────────────────────────────────────────────┤
│  FSM Controller → Generates Micro-Control      │
│                   Signals Based on Instruction │
├─────────────────────────────────────────────────┤
│         DATAPATH (Shared Internal Bus)          │
│  Input Reg → Accumulator A → ALU → Output Reg │
│             Accumulator B ↑                     │
└─────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Accumulator A

**Purpose**: 4-bit register holding operand A for ALU operations

**Key Signals**:
- `LatchA` – Load value from internal bus when HIGH
- `EnableA` – Output value onto bus when HIGH
- `ClearA` – Reset accumulator (typically tied to reset)
- `IB_BUS` – Shared internal data bus (tri-state)
- `AluA` – Direct output to ALU (4-bit)

**Behavior**: On clock pulse with `LatchA=1`, captures data from bus. When `EnableA=1`, drives its stored value onto the bus.

**Implementation**:
```verilog
module Accumulator_A(
    input  wire        MainClock,
    input  wire        ClearA,
    input  wire        LatchA,
    input  wire        EnableA,
    inout  wire [3:0]  IB_BUS,
    output wire [3:0]  A,
    output wire [3:0]  AluA
);

    reg [3:0] regA = 4'b0000;

    // Latch data from bus
    always @(posedge MainClock or posedge ClearA) begin
        if (ClearA)
            regA <= 4'b0000;
        else if (LatchA)
            regA <= IB_BUS;
    end

    // Tri-state bus drive
    assign IB_BUS = (EnableA) ? regA : 4'bz;

    assign A = regA;
    assign AluA = regA;

endmodule
```

---

### 2. Accumulator B

**Purpose**: 4-bit register holding operand B for ALU operations

**Key Signals**:
- `LatchB` – Load value from internal bus when HIGH
- `EnableB` – Output value onto bus when HIGH
- `ClearB` – Reset accumulator
- `IB_BUS` – Shared internal data bus (tri-state)
- `AluB` – Direct output to ALU (4-bit)

**Behavior**: Identical to Accumulator A; enables dual-operand ALU operations.

**Implementation**:
```verilog
module Accumulator_B(
    input  wire        MainClock,
    input  wire        ClearB,
    input  wire        LatchB,
    input  wire        EnableB,
    inout  wire [3:0]  IB_BUS,
    output wire [3:0]  B,
    output wire [3:0]  AluB
);
    reg [3:0] regB = 4'b0000;

    // Latch input from bus
    always @(posedge MainClock or posedge ClearB) begin
        if (ClearB)
            regB <= 4'b0000;
        else if (LatchB)
            regB <= IB_BUS;
    end

    // Tri-state drive to the internal bus
    assign IB_BUS = (EnableB) ? regB : 4'bz;

    assign B     = regB;
    assign AluB  = regB;
endmodule
```

---

### 3. Arithmetic Logic Unit (ALU)

**Purpose**: Performs arithmetic and logic operations on inputs from Acc A and Acc B

**Key Signals**:
- `A` (4-bit) – Operand from Accumulator A
- `B` (4-bit) – Operand from Accumulator B
- `EnableALU` – Enable ALU output onto bus
- `AddSub` – Operation select (0 = Add, 1 = Subtract)
- `Carry` – Carry flag output
- `IB_ALU` – Tri-state output to internal bus

**Supported Operations**:
- **Addition** (`AddSub=0`): Result = A + B
- **Subtraction** (`AddSub=1`): Result = A - B
- **Carry Flag**: Set on overflow/borrow

**Behavior**: Combinational logic; result is valid immediately after inputs change. When `EnableALU=1`, drives result onto bus.

**Implementation**:
```verilog
module Arithmetic_Unit(
    input  wire        EnableALU,
    input  wire        AddSub,    // 0 = Add, 1 = Subtract
    input  wire [3:0]  A,
    input  wire [3:0]  B,
    output wire        Carry,
    inout  wire [3:0]  IB_ALU
);
    reg  [4:0] result;

    always @(*) begin
        if (AddSub)
            result = {1'b0, A} - {1'b0, B};
        else
            result = {1'b0, A} + {1'b0, B};
    end

    // Drive ALU result to bus only when enabled
    assign IB_ALU = (EnableALU) ? result[3:0] : 4'bz;
    assign Carry  = result[4];
endmodule
```

---

### 4. Input Register

**Purpose**: Captures external user input onto the shared bus

**Key Signals**:
- `EnableIN` – Drive user input onto bus when HIGH
- `DataIn` (4-bit) – User input from switches (SW[3:0])
- `IB_BUS` – Tri-state output to internal bus

**Behavior**: Combinational; when `EnableIN=1`, SW[3:0] is driven onto the internal bus.

**Implementation**:
```verilog
module InRegister(
    input  wire        EnableIN,
    input  wire [3:0]  DataIn,
    inout  wire [3:0]  IB_BUS
);
    assign IB_BUS = (EnableIN) ? DataIn : 4'bz;
endmodule
```

---

### 5. Output Register

**Purpose**: Latches and displays results on LEDs

**Key Signals**:
- `MainClock` – System clock
- `MainReset` – Synchronous reset
- `EnableOut` – Latch current bus value when HIGH
- `IB_BUS` – Shared internal data bus (input)
- `rOut` (4-bit) – Latched output (displays on LEDR[3:0])

**Behavior**: On clock pulse with `EnableOut=1`, captures data from bus and holds it for display.

**Implementation**:
```verilog
module OutRegister(
    input  wire        MainClock,
    input  wire        MainReset,
    input  wire        EnableOut,
    inout  wire [3:0]  IB_BUS,
    output reg  [3:0]  rOut
);
    always @(posedge MainClock or posedge MainReset) begin
        if (MainReset)
            rOut <= 4'b0000;
        else if (EnableOut)
            rOut <= IB_BUS;
    end
endmodule
```

---

### 6. Instruction Register

**Purpose**: Stores and decodes the current micro-instruction from ROM

**Key Signals**:
- `MainClock` – System clock
- `ClearInstr` – Reset instruction register
- `LatchInstr` – Load new instruction from ROM data (input `Data`)
- `EnableInstr` – Drive instruction field back onto bus (if needed)
- `Data` (4-bit) – Low nibble from ROM (data portion)
- `Instr` (4-bit) – High nibble from ROM (opcode portion)
- `ToInstr` (4-bit) – Output data bus
- `IB_BUS` – Shared internal data bus (tri-state)

**Behavior**: Decodes 8-bit ROM word into **Instr[3:0]** (opcode) and **Data[3:0]** (immediate data). Holds instruction until next `LatchInstr` pulse.

**Implementation**:
```verilog
module InstructionReg(
    input  wire        MainClock,
    input  wire        ClearInstr,
    input  wire        LatchInstr,
    input  wire        EnableInstr,
    input  wire [3:0]  Data,
    output reg  [3:0]  Instr,
    output wire [3:0]  ToInstr,
    inout  wire [3:0]  IB_BUS
);
    reg [3:0] regInstr = 4'b0000;

    always @(posedge MainClock or posedge ClearInstr) begin
        if (ClearInstr)
            regInstr <= 4'b0000;
        else if (LatchInstr)
            regInstr <= Data;
    end

    assign ToInstr = regInstr;
    assign IB_BUS
endmodule
```

---

### 7. Program Memory (ROM)

**Purpose**: Stores 8-bit micro-instructions indexed by program counter

**Key Signals**:
- `address` (3-bit) – Index from program counter (PC[2:0])
- `data` (8-bit) – Instruction word: `{Instr[3:0], Data[3:0]}`

**Format**:
```
Bits [7:4] → Instruction/Opcode (4-bit)
Bits [3:0] → Immediate Data (4-bit)
```

**Capacity**: 8 instruction words (3-bit address)

**Example Instructions** (dependent on FSM design):
- Load A with user input
- Load B with user input
- Add A + B, store in output
- Subtract A - B, store in output
- Branch / Loop

**Implementation**:
```verilog
module ROM_Nx8(
    input  wire [2:0] address,
    output reg  [7:0] data
);
    always @(*) begin
        case(address)
            3'd0: data = 8'b0000_0000; // Example instructions
            3'd1: data = 8'b0001_0001;
            3'd2: data = 8'b0010_0010;
            3'd3: data = 8'b0011_0011;
            3'd4: data = 8'b0100_0100;
            3'd5: data = 8'b0101_0101;
            3'd6: data = 8'b0110_0110;
            3'd7: data = 8'b0111_0111;
            default: data = 8'b0000_0000;
        endcase
    end
endmodule
```

---

### 8. Program Counter

**Purpose**: Tracks current instruction address and sequences through program

**Key Signals**:
- `MainClock` – System clock
- `EnableCount` – Increment counter on clock pulse
- `ClearCounter` – Reset to 0 (typically tied to reset)
- `Counter` (4-bit) – Current program address (only 3 bits used for ROM)

**Behavior**: On each clock pulse with `EnableCount=1`, increments by 1. Wraps at 8 (modulo 8 for 3-bit ROM addressing). Resets to 0 on `ClearCounter`.

**Implementation**:
```verilog
module ProgramCounter(
    input  wire        MainClock,
    input  wire        ClearCounter,
    input  wire        EnableCount,
    output reg  [3:0]  Counter
);
    always @(posedge MainClock or posedge ClearCounter) begin
        if (ClearCounter)
            Counter <= 4'b0000;
        else if (EnableCount)
            Counter <= Counter + 1'b1;
    end
endmodule
```

---

### 9. FSM Micro-Instruction Controller

**Purpose**: Central control unit; decodes instructions and generates control signals for all datapath elements

**Key Signals** (Inputs):
- `clk` – System clock
- `reset` – Synchronous reset
- `IB_BUS` – Internal bus (for conditional logic if needed)

**Control Outputs**:
- `LatchA`, `EnableA` – Accumulator A control
- `LatchB`, `EnableB` – Accumulator B control
- `EnableALU` – ALU output enable
- `AddSub` – ALU operation selector
- `EnableIN` – Input register control
- `EnableOut` – Output register control
- `LoadInstr`, `EnableInstr` – Instruction register control
- `ToInstr` (4-bit) – Data routed to instruction register
- `EnableCount` – Program counter control

**State Machine Flow**:
1. **FETCH** – Load instruction from ROM via program counter
2. **DECODE** – Set up control signals based on opcode
3. **EXECUTE** – Activate accumulators, ALU, and result latching
4. **STORE** – Latch result to output register or accumulator
5. **INCREMENT** – Advance program counter to next instruction

**Behavior**: Synchronous state machine; transitions on each clock cycle based on current state and instruction opcode.

**Implementation**:
```verilog
module FSM_MicroInstr #
(
    parameter N = 4
)
(
    input  wire              clk,
    input  wire              reset,
    input  wire [N-1:0]      IB_BUS,     // instruction bus (opcode)
    
    output reg               LatchA,
    output reg               EnableA,
    output reg               LatchB,
    output reg               EnableALU,
    output reg               AddSub,
    output reg               EnableIN,
    output reg               EnableOut,
    output reg               LoadInstr,
    output reg               EnableInstr,
    input  wire [N-1:0]      ToInstr,
    output reg               EnableCount
);

    //-----------------------------------------------------
    // State definitions
    //-----------------------------------------------------
    reg [2:0] state, next_state;

    localparam [2:0]
        IDLE    = 3'd0,
        PHASE_1 = 3'd1,  // FETCH
        PHASE_2 = 3'd2,  // DECODE
        PHASE_3 = 3'd3,  // EXECUTE 1
        PHASE_4 = 3'd4;  // EXECUTE 2 / WRITEBACK

    //-----------------------------------------------------
    // 1. Sequential State Register
    //-----------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    //-----------------------------------------------------
    // 2. Next-State Logic
    //-----------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    next_state = PHASE_1;
            PHASE_1: next_state = PHASE_2;
            PHASE_2: next_state = PHASE_3;
            PHASE_3: next_state = PHASE_4;
            PHASE_4: next_state = PHASE_1;
            default: next_state = IDLE;
        endcase
    end

    //-----------------------------------------------------
    // 3. Output Logic (Control Signals)
    //-----------------------------------------------------
    always @(*) begin
        // Default (everything off)
        LatchA      = 1'b0;
        EnableA     = 1'b0;
        LatchB      = 1'b0;
        EnableALU   = 1'b0;
        AddSub      = 1'b0;
        EnableIN    = 1'b0;
        EnableOut   = 1'b0;
        LoadInstr   = 1'b0;
        EnableInstr = 1'b0;
        EnableCount = 1'b0;

        case (state)
            //-------------------------------------------------
            // IDLE — wait for reset release
            //-------------------------------------------------
            IDLE: begin
                // do nothing
            end

            //-------------------------------------------------
            // FETCH — get instruction from ROM
            //-------------------------------------------------
            PHASE_1: begin
                LoadInstr   = 1'b1;  // latch ROM output into IR
                EnableCount = 1'b1;  // increment Program Counter
            end

            //-------------------------------------------------
            // DECODE — interpret opcode
            //-------------------------------------------------
            PHASE_2: begin
                EnableInstr = 1'b1;  // IR outputs ToInstr
            end

            //-------------------------------------------------
            // EXECUTE — perform operation
            //-------------------------------------------------
            PHASE_3: begin
                case (ToInstr)
                    //-------------------------------------------------
                    // LOAD A ← Input
                    //-------------------------------------------------
                    4'b0000: begin
                        EnableIN = 1'b1;  // drive bus with input switches
                        LatchA   = 1'b1;  // latch into A
                    end

                    //-------------------------------------------------
                    // LOAD B ← Input
                    //-------------------------------------------------
                    4'b0001: begin
                        EnableIN = 1'b1;
                        LatchB   = 1'b1;
                    end

                    //-------------------------------------------------
                    // OUT A → Output Register
                    //-------------------------------------------------
                    4'b0010: begin
                        EnableA   = 1'b1;   // put A onto bus
                        EnableOut = 1'b1;   // latch into output reg
                    end

                    //-------------------------------------------------
                    // ADD A ← A + B
                    //-------------------------------------------------
                    4'b0011: begin
                        EnableA   = 1'b0;   // disable A (avoid bus conflict)
                        EnableALU = 1'b1;   // ALU drives A+B onto bus
                        AddSub    = 1'b0;   // addition
                        LatchA    = 1'b1;   // latch result into A
                    end

                    //-------------------------------------------------
                    // SUB A ← A − B
                    //-------------------------------------------------
                    4'b0100: begin
                        EnableA   = 1'b0;   // disable A drive
                        EnableALU = 1'b1;   // ALU drives A−B onto bus
                        AddSub    = 1'b1;   // subtraction mode
                        LatchA    = 1'b1;   // latch result into A
                    end

                    default: begin
                        // NOP or undefined opcode — do nothing
                    end
                endcase
            end

            //-------------------------------------------------
            // EXECUTE FINAL — output stabilization
            //-------------------------------------------------
            PHASE_4: begin
                case (ToInstr)
                    4'b0010: begin
                        // keep output active one more cycle
                        EnableA   = 1'b1;
                        EnableOut = 1'b1;
                    end
                    default: begin
                        // all other instructions finish cleanly
                    end
                endcase
            end
        endcase
    end

endmodule
```

---

## Internal Bus (IB_BUS)

The **shared 4-bit internal bus** connects all datapath components via **tri-state logic**:

```
Drivers (tri-state enabled by control signals):
├─ Accumulator A (when EnableA = 1)
├─ Accumulator B (when EnableB = 1)
├─ ALU (when EnableALU = 1)
├─ Input Register (when EnableIN = 1)
└─ Instruction Register (when EnableInstr = 1)

Listeners (all capture when latch signal active):
├─ Accumulator A (captures on LatchA = 1)
├─ Accumulator B (captures on LatchB = 1)
└─ Output Register (captures on EnableOut = 1)
```

**Key Design Rule**: Only **one driver** can be enabled at a time to prevent bus contention.

---

## I/O Interface (DE-10 Lite)

| Signal | Direction | Bits | Purpose |
|--------|-----------|------|---------|
| MAX10_CLK1_50 | Input | 1 | 50 MHz system clock |
| SW[9:8] | Input | 2 | Reset (SW[8]) & Manual Clock (SW[9]) |
| SW[3:0] | Input | 4 | User data input |
| LEDR[9] | Output | 1 | Carry flag from ALU |
| LEDR[3:0] | Output | 4 | Output register data |
| HEX0 | Output | 8 | 7-seg display: Internal bus value |
| HEX1 | Output | 8 | 7-seg display: Accumulator A value |
| HEX2 | Output | 8 | 7-seg display: Accumulator B value |
| HEX4 | Output | 8 | 7-seg display: User input (SW[3:0]) |
| HEX5 | Output | 8 | 7-seg display: Output register value |

---

## Control Signal Timing Example

**Scenario**: Load input into Accumulator A, then add with Accumulator B

```
Cycle 1: EnableIN = 1  → SW[3:0] driven onto bus
         LatchA = 1    → Acc A captures from bus
         
Cycle 2: EnableA = 1   → Acc A driven onto bus
         LatchB = 1    → Acc B captures from bus (if already has value)
         
Cycle 3: EnableALU = 1 → ALU result (A + B) driven onto bus
         EnableOut = 1 → Output register captures result
         
Cycle 4: EnableCount = 1 → Program counter increments
```

---

## Design Notes

### Tri-State Bus Arbitration
- **Safe Floating Value**: When no driver is active, HEX0 displays `0000` (bus state sampled and converted)
- **Control FSM Responsibility**: Ensures mutually exclusive driver enables

### Clock & Reset
- **System Clock**: 50 MHz from MAX10_CLK1_50
- **Manual Clock**: Step-by-step control via debounced SW[9]
- **Reset**: Synchronous to debounced SW[8], clears all registers

### ALU Overflow
- **Carry Flag**: Output on LEDR[9]
- **Range**: 4-bit signed/unsigned arithmetic with overflow detection

---

## ROM Format Example

```verilog
// Example ROM contents (8 x 8-bit)
// {Instr[3:0], Data[3:0]}

ROM[0] = 8'b0001_0000  // Instr=1 (Load A), Data=0
ROM[1] = 8'b0010_0001  // Instr=2 (Load B), Data=1
ROM[2] = 8'b0011_0000  // Instr=3 (Add A+B), Data=0
ROM[3] = 8'b0100_0000  // Instr=4 (Store), Data=0
ROM[4] = 8'b1111_0000  // Instr=15 (Halt), Data=0
```
<!-- 
---

## Simulation / Testing Checklist

- [ ] Accumulator A: Loads only when `LatchA=1`, outputs when `EnableA=1`
- [ ] Accumulator B: Loads only when `LatchB=1`, outputs when `EnableB=1`
- [ ] ALU: Correctly computes A+B and A-B; carry flag toggles on overflow
- [ ] Input Register: User input appears on bus when `EnableIN=1`
- [ ] Output Register: Bus value latched to output on `EnableOut=1`
- [ ] Instruction Register: Decodes ROM word correctly; opcode and data separated
- [ ] Program Counter: Increments on `EnableCount=1`; wraps at 8
- [ ] ROM: Correct instruction words stored and retrieved at correct addresses
- [ ] FSM Controller: Generates correct micro-control sequence for each opcode
- [ ] Bus Conflicts: No tri-state collisions (only one enable at a time)
- [ ] Reset: All registers clear synchronously on reset pulse -->

---

## File Structure

| Component | File | Notes |
|-----------|------|-------|
| Top-level | `main.v` | Instantiates all modules; includes debounce logic |
| Acc A | `Accumulator_A.v` | 4-bit register with tri-state output |
| Acc B | `Accumulator_B.v` | 4-bit register with tri-state output |
| ALU | `Arithmetic_Unit.v` | Adder/subtractor with carry flag |
| Input | `InRegister.v` | Combinational tri-state driver |
| Output | `OutRegister.v` | 4-bit latch for display |
| Instruction | `InstructionReg.v` | Decodes ROM data into opcode + immediate |
| ROM | `ROM_Nx8.v` | 8x8-bit instruction memory |
| PC | `ProgramCounter.v` | 4-bit counter (3-bit used for ROM) |
| FSM | `FSM_MicroInstr.v` | Control state machine |

---
## 🎬 System Demo GIF  
![project-demo](./images/lab_08.GIF)
---

## Key Architectural Concepts Demonstrated

- **Register-Transfer Logic (RTL)** – Data movement between registers via bus
- **Tri-State Bus Communication** – Shared medium with multiple drivers
- **Accumulator-Based Datapath** – Operand storage in accumulators
- **Micro-Instruction Encoding** – ROM-based instruction storage
- **Finite State Machine Control** – Sequencing via state transitions
- **Input/Output Integration** – FPGA board I/O pins (switches, LEDs, 7-seg displays)

---

## Future Extensions

- Extend to 8-bit datapath
- Add instruction ROM & control FSM
- Support more ALU operations (AND, OR, XOR, CMP)

---

## Conclusion

This project demonstrates a **complete micro-programmed processor architecture** on FPGA, featuring a full datapath with accumulators, ALU, ROM-based instruction storage, and FSM-driven control. It bridges fundamental computer architecture theory with real hardware implementation on the Intel MAX10 DE-10 Lite board.