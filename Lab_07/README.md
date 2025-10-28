# 🧠 UART Word Detector on DE10-Lite

> This project implements a UART communication system with an FSM word detector. It receives data from a UART connection, displays the received bytes on LEDs, and detects when the word **"hello"** is received, showing it on the seven-segment displays.

---

## 📸 Project Image
<img src="images/lab7.GIF" alt="lab07" width="500"/>
![Project Photo](./images/project_photo.jpg)
> *(Replace `project_photo.jpg` with your actual image.)*

---

## ⚙️ Hardware Used

- **DE10-Lite FPGA Board**  
- **MAX10 FPGA (50 MHz Clock)**  
- **UART Connection via GPIO[35:33]**  
- **Switches (SW[9:0])**  
- **LEDs (LEDR[9:0])**  
- **Seven Segment Displays (HEX0–HEX6)**

---

## 💻 Software Used

- **Intel Quartus Prime 2021 (or later)**  
- **ModelSim (optional for simulation)**

---

## 📜 Verilog Code

```verilog
`default_nettype none

module main(
    input        MAX10_CLK1_50,
    input  [9:0] SW,
    output [9:0] LEDR,
    inout  [35:0] GPIO,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6
);

    wire w_clk = MAX10_CLK1_50;

    // UART receiver signals
    wire RxD_data_ready;
    wire [7:0] RxD_data;
    reg  [7:0] GPout;

    // UART Receiver (115200 baud)
    async_receiver RX (
        .clk(w_clk),
        .RxD(GPIO[35]),
        .RxD_data_ready(RxD_data_ready),
        .RxD_data(RxD_data)
    );

    // UART Transmitter (echo back)
    async_transmitter TX (
        .clk(w_clk),
        .TxD(GPIO[33]),
        .TxD_start(RxD_data_ready),
        .TxD_data(RxD_data)
    );

    // Store received byte
    always @(posedge w_clk) begin
        if (RxD_data_ready)
            GPout <= RxD_data;
    end

    // Display received byte on LEDs
    assign LEDR[7:0] = GPout;

    // FSM word detector for "hello"
    FSM_Word_Detecter word_detector (
        .clk(w_clk),
        .reset(SW[9]),
        .RXD_data(GPout),
        .data_ready(RxD_data_ready),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4)
    );

    // Blank unused HEX displays
    assign HEX5 = 7'b1111111;
    assign HEX6 = 7'b1111111;

endmodule

`default_nettype wire
```

---

## 🧠 Explanation

### 🪐 Overview
This Verilog module connects the **UART communication** system with an **FSM-based word detector**.  
The design listens for incoming serial data through GPIO pins, echoes it back through UART, displays the ASCII value on LEDs, and uses an FSM to detect specific words (like `"hello"`).

---

### ⚡ UART Receiver (`async_receiver`)
- Receives serial data from `GPIO[35]`.
- Converts serial data into 8-bit parallel bytes.
- Sets `RxD_data_ready` high when a full byte is received.

### ⚙️ UART Transmitter (`async_transmitter`)
- Sends the received data back through `GPIO[33]`.
- Starts transmission when `RxD_data_ready` is high (creating an “echo” effect).

### 💾 Data Storage and LEDs
```verilog
always @(posedge w_clk) begin
    if (RxD_data_ready)
        GPout <= RxD_data;
end
assign LEDR[7:0] = GPout;
```
- Each received byte is stored in `GPout`.
- The value is shown on the 8 lower LEDs (LEDR[7:0]) as binary representation.

### 🔤 FSM Word Detector
The FSM module (`FSM_Word_Detecter`) checks each received byte.  
When it detects the sequence of characters **‘h’ → ‘e’ → ‘l’ → ‘l’ → ‘o’**, it displays **HELLO** on the seven-segment displays (HEX0–HEX4).

### 🔲 Seven Segment Displays
- `HEX0–HEX4` show the detected letters.
- `HEX5` and `HEX6` are turned off using all segments high (`7'b1111111`).

---

## 🧩 Block Diagram

![Block Diagram](./images/block_diagram.png)

---

## 🏁 How to Run

1. Open **Quartus Prime** and create a new project.  
2. Add all Verilog source files (`main.v`, `async_receiver.v`, `async_transmitter.v`, `FSM_Word_Detecter.v`).  
3. Assign pins to match the **DE10-Lite** board.  
4. Compile the design.  
5. Connect a USB-to-UART cable to GPIO pins (35 for RX, 33 for TX).  
6. Send characters using a terminal program (e.g., PuTTY).  
7. Observe LEDs and HEX displays for the word detection.

---

## 📂 File Structure

```
uart_word_detector/
│
├── src/                    # Verilog source files
├── images/                 # Photos and diagrams
├── simulation/             
└── README.md
```

---

## ✨ Author

**Your Name**  
*Lab: UART and FSM Word Detection*  
📅 *Date: YYYY-MM-DD*

---

## 📸 Example Photo Section

![Example Board](./images/example_board.jpg)
> *(Include an image of your DE10-Lite board setup here.)*
