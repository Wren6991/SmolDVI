module smoldvi_fpga (
	input wire                     clk_osc,

	output wire [1:0]              led,

	// {CK, D2, D1, D0}
	output wire [3:0]              dvi_p,
	output wire [3:0]              dvi_n

);


// Clock + Reset resources

wire clk_sys;
wire clk_lcd;
wire rst_n;
wire pll_lock;

// SB_HFOSC #(
//   .CLKHF_DIV ("0b10") // divide by 4 -> 12 MHz
// ) inthosc (
//   .CLKHFPU (1'b1),
//   .CLKHFEN (1'b1),
//   .CLKHF   (clk_sys)
// );

// pll_12_36 #(
// 	.ICE40_PAD (1)
// ) pll_lcd (
// 	.clock_in  (clk_osc),
// 	.clock_out (clk_lcd),
// 	.locked    (pll_lock)
// );

// fpga_reset #(
// 	.SHIFT (3),
// 	.COUNT (127)
// ) rstgen (
// 	.clk         (clk_sys),
// 	.force_rst_n (1'b1),
// 	.rst_n       (rst_n)
// );

blinky #(
	.CLK_HZ (12_000_000),
	.BLINK_HZ(1)
) blink (
	.clk   (clk_osc),
	.blink (led[0])
);


endmodule
