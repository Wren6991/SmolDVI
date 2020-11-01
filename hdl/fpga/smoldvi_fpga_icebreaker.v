`default_nettype none

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
wire rst_n_por;
wire rst_n_pix;
wire rst_n_bit;
wire pll_lock;


pll_12_126 #(
	.ICE40_PAD (1)
) pll_bit (
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
	.rst_n       (rst_n_por)
);

reset_sync reset_sync_bit (
	.clk       (clk_bit),
	.rst_n_in  (rst_n_por),
	.rst_n_out (rst_n_bit)
);

reset_sync reset_sync_pix (
	.clk       (clk_pix),
	.rst_n_in  (rst_n_por),
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

// DVI instantiation + test pattern

wire rgb_rdy;
reg [9:0] x_ctr;
reg [8:0] y_ctr;
reg [7:0] frame_ctr;

always @ (posedge clk_pix or negedge rst_n_pix) begin
	if (!rst_n_pix) begin
		x_ctr <= 10'h0;
		y_ctr <= 9'h0;
		frame_ctr <= 8'h0;
	end else if (rgb_rdy) begin
		if (x_ctr == 10'd638) begin
			x_ctr <= 10'h0;
			if (y_ctr == 9'd479) begin
				y_ctr <= 9'h0;
				frame_ctr <= frame_ctr + 1'b1;
			end else begin
				y_ctr <= y_ctr + 1'b1;
			end
		end else begin
			// Note x advances by 2 because of pixel doubling
			x_ctr <= x_ctr + 2'h2;
		end
	end
end

smoldvi inst_smoldvi (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_bit   (clk_bit),
	.rst_n_bit (rst_n_bit),

	.en        (1'b1),

	.r         (x_ctr + frame_ctr),
	.g         (y_ctr + 2 * frame_ctr),
	.b         (frame_ctr),
	.rgb_rdy   (rgb_rdy),

	.dvi_p     (dvi_p),
	.dvi_n     (dvi_n)
);


endmodule
