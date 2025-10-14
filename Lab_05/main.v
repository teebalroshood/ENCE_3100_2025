
`default_nettype none

module main(
	input 				MAX10_CLK1_50,
	input 	[9:0] 	SW,
	input 	[1:0]		KEY,
	output 	[9:0] 	LEDR,
	output	[7:0]		HEX0,
	output	[7:0]		HEX1,
	output	[7:0]		HEX2,
	output	[7:0]		HEX3,
	output	[7:0]		HEX4,
	output	[7:0]		HEX5
);

	// Debounce module
	debounce u_db (
    .clk(MAX10_CLK1_50),
    .rst(1'b0),
    .btn_raw(KEY[0]),
    .btn_level(w_myClk),
    .btn_pressed(),
    .btn_released()
	);

	wire w_myClk;

	// Part I
	//******************
	/*
	
	reg_nbit REG0(
	.i_R(SW[7:0]),
	.i_clk(w_myClk),
	.i_rst(SW[9]),
	.o_Q(LEDR[7:0])
);
	
	
	wire [7:0] w_sum;
	
	// ALU - add
	accumulator_8bit Acc_8bit(
		.i_A(SW[7:0]),  //8bit
		.i_clk(w_myClk),
		.i_rst(SW[9]),
		.o_overflow(LEDR[8]),
		.o_S(w_sum) //8bit
	);
	
	//assign LEDR[7:0] = w_sum;
	
	// Display result in BCD
	
	wire [3:0] w_O, w_T, w_H;
	
	bin8_to_bcd u_b2b (
    .bin(w_sum),
    .bcd_hundreds(w_H),
    .bcd_tens(w_T),
    .bcd_ones(w_O)
	);
	
	// BCD to HEX decoders
	seg7Decoder SEG_O (w_O, HEX0);
	seg7Decoder SEG_T (w_T, HEX1);
	seg7Decoder SEG_H (w_H, HEX2);
	*/
	
	//******************
	
	// Part II
	//******************
	/*
	
	wire [7:0] w_sum;
	
	// ALU - add and sub
	accumulator_sub_8bit Acc__sub_8bit(
		.i_A(SW[7:0]),  		//8bit
		.i_addsub(SW[8]), 	// 1 - sub / 0 - add
		.i_clk(w_myClk),
		.i_rst(SW[9]),
		.o_overflow(LEDR[8]),
		.o_S(w_sum) 			//8bit
	);
	
	assign LEDR[7:0] = w_sum;
	
	// Display result in BCD
	
	wire [3:0] w_O, w_T, w_H;
	
	bin8_to_bcd u_b2b (
    .bin(w_sum),
    .bcd_hundreds(w_H),
    .bcd_tens(w_T),
    .bcd_ones(w_O)
	);
	
	// BCD to HEX decoders
	seg7Decoder SEG_O (w_O, HEX0);
	seg7Decoder SEG_T (w_T, HEX1);
	seg7Decoder SEG_H (w_H, HEX2);
	*/
	
	//******************
	
	// Part III
	//******************	

	/*
	assign HEX3 = 8'b11111111;  // B
	seg7Decoder SEG_A (SW[3:0], HEX4);  // A
	seg7Decoder SEG_B (SW[7:4], HEX5);  // B
	
	wire [7:0] w_Product;
	
	multiplier_4x4 MT_4by4 (
		.i_A(SW[3:0]),  // 4bits
		.i_B(SW[7:4]),  // 4bits
		.o_P(w_Product),  // 8bits
		.o_Overflow(LEDR[8])
	);
	
	assign LEDR[7:0] = w_Product;
	
	// Display result in BCD
	
	wire [3:0] w_O, w_T, w_H;
	
	bin8_to_bcd u_b2b (
    .bin(w_Product),
    .bcd_hundreds(w_H),
    .bcd_tens(w_T),
    .bcd_ones(w_O)
	);
	
	// BCD to HEX decoders
	seg7Decoder SEG_O (w_O, HEX0);
	seg7Decoder SEG_T (w_T, HEX1);
	seg7Decoder SEG_H (w_H, HEX2);
	*/
	
	//******************
	
	// Part IV
	//******************
	
	/*
	wire w_rst = SW[9];
	
	wire [7:0] w_Q_A, w_Q_B;
	
	// 8bit Register
	reg_nbit #(8) REG_A (
		.i_R(8'd100),
		.i_clk(w_myClk),
		.i_rst(w_rst),
		.o_Q(w_Q_A)
	);
	
	// 8bit Register
	reg_nbit #(8) REG_B (
		.i_R(SW[7:0]),
		.i_clk(w_myClk),
		.i_rst(w_rst),
		.o_Q(w_Q_B)
	);
	
	wire [15:0] w_Product;
	
	multiplier_8x8 MT_8by8 (
		.i_A(w_Q_A),  // 8bits
		.i_B(w_Q_B),  // 8bits
		.o_P(w_Product),  // 16bits
		.o_Overflow(LEDR[9])
	);
	
	assign LEDR[8:0] = w_Product[8:0]; // render only 9 bits
	
	wire [15:0] w_reg_Product;
	
	// 8bit Register
	reg_nbit #(16) REG_P (
		.i_R(w_Product),
		.i_clk(w_myClk),
		.i_rst(w_rst),
		.o_Q(w_reg_Product)
	);
	
	// Display result in BCD
	
	wire [3:0] w_O, w_T, w_H, w_TH, w_TTH;
	
	bin16_to_bcd u_b2b (
    .bin(w_reg_Product),
	 .bcd_ten_thousands(w_TTH),
	 .bcd_thousands(w_TH),
    .bcd_hundreds(w_H),
    .bcd_tens(w_T),
    .bcd_ones(w_O)
	);
	
	// BCD to HEX decoders
	seg7Decoder SEG_O (w_O, HEX0);
	seg7Decoder SEG_T (w_T, HEX1);
	seg7Decoder SEG_H (w_H, HEX2);
	seg7Decoder SEG_TH (w_TH, HEX3);
	seg7Decoder SEG_TTH (w_TTH, HEX4);
	
	assign HEX5 = 8'b11111111;
	*/
	
	//******************
	
	// Part V (Graduate students)
	//******************
	/*
	 wire w_rst = SW[9];              // active-high reset
   
    // Input Registers  (A = SW7-4 ,  B = SW3-0)
    wire [3:0] w_Q_A, w_Q_B;

    reg_nbit #(4) REG_A (
        .i_R(SW[7:4]),
        .i_clk(w_myClk),
        .i_rst(w_rst),
        .o_Q(w_Q_A)
    );

    reg_nbit #(4) REG_B (
        .i_R(SW[3:0]),
        .i_clk(w_myClk),
        .i_rst(w_rst),
        .o_Q(w_Q_B)
    );

    // 4×4 Adder-Tree Multiplier (same tree idea, smaller size)
    wire [7:0] w_Product;

    multiplier_4x4_addertree MT_4by4 (
        .i_A(w_Q_A),
        .i_B(w_Q_B),
        .o_P(w_Product),
        .o_Overflow(LEDR[9])
    );

    assign LEDR[8:0] = w_Product[7:0];  // binary product

    // Output Register
    wire [7:0] w_reg_Product;

    reg_nbit #(8) REG_P (
        .i_R(w_Product),
        .i_clk(w_myClk),
        .i_rst(w_rst),
        .o_Q(w_reg_Product)
    );

    // Binary-to-BCD & 7-Segment Display
    wire [3:0] w_O, w_T, w_H;

    bin8_to_bcd u_b2b (
        .bin(w_reg_Product),
        .bcd_hundreds(w_H),
        .bcd_tens(w_T),
        .bcd_ones(w_O)
    );

    seg7Decoder SEG_O (w_O, HEX0);
    seg7Decoder SEG_T (w_T, HEX1);
    seg7Decoder SEG_H (w_H, HEX2);
    assign HEX3 = 8'b11111111;
    assign HEX4 = 8'b11111111;
    assign HEX5 = 8'b11111111;
	*/
	//******************

endmodule

`default_nettype wire
