module smoldvi_fpga (
	input wire                     clk_osc,

	output wire [1:0]              led,

	// {CK, D2, D1, D0}
	output wire [3:0]              dvi_p,
	output wire [3:0]              dvi_n

);

// Clock + Reset resources

wire clk_pix;
wire clk_bit;
wire rst_n_osc;
wire rst_n_pix
;wire rst_n_bit;
wire pll_lock;


pll_12_126 pll_bit (
	.clock_in  (clk_osc),
	.clock_out (clk_bit),
	.locked    (pll_lock)
);

fpga_reset #(
	.SHIFT (3),
	.COUNT (0)
) rstgen (
	.clk         (clk_bit),
	.force_rst_n (pll_lock),
	.rst_n       (rst_n_osc)
);

reset_sync reset_sync_bit (
	.clk       (clk_bit),
	.rst_n_in  (rst_n_osc),
	.rst_n_out (rst_n_bit)
);

reset_sync reset_sync_pix (
	.clk       (clk_pix),
	.rst_n_in  (rst_n_osc),
	.rst_n_out (rst_n_pix)
);


// Generate clk_pix from clk_bit with ring counter (hack)
(* keep = 1'b1 *) reg [4:0] bit_pix_div;
assign clk_pix = bit_pix_div[0];

always @ (posedge clk_bit or negedge rst_n_bit) begin
	if (!rst_n_bit) begin
		bit_pix_div <= 5'b11100;		
	end else begin
		bit_pix_div <= {bit_pix_div[3:0], bit_pix_div[4]};
	end
end


// blink blonk
blinky #(
	.CLK_HZ (12_000_000),
	.BLINK_HZ(1)
) blink (
	.clk   (clk_pix),
	.blink (led[0])
);

smoldvi_top inst_smoldvi_top (
		.clk_pix   (clk_pix),
		.rst_n_pix (rst_n_pix),
		.clk_bit   (clk_bit),
		.rst_n_bit (rst_n_bit),
		.dvi_p     (dvi_p),
		.dvi_n     (dvi_n)
	);


endmodule
