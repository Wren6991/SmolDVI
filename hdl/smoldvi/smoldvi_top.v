// Example top-level file for smoldvi

module smoldvi_top (
	// Full-rate pixel clock, half-rate bit clock. Must have exact 1:5 frequency
	// ratio, and a common root oscillator
	input wire        clk_pix,
	input wire        rst_n_pix,
	input wire        clk_bit,
	input wire        rst_n_bit,

	// {CK, D2, D1, D0}
	output wire [3:0] dvi_p,
	output wire [3:0] dvi_n
);

wire rgb_rdy;
wire [9:0] tmds0;
wire [9:0] tmds1;
wire [9:0] tmds2;

reg [9:0] x_ctr;
reg [8:0] y_ctr;
reg [7:0] frame_ctr;

always @ (posedge clk_pix or negedge rst_n_pix) begin
	if (!rst_n_pix) begin
		x_ctr <= 10'h0;
		y_ctr <= 9'h0;
		frame_ctr <= 8'h0;
	end else if (rgb_rdy) begin
		if (x_ctr == 10'd639) begin
			x_ctr <= 10'h0;
			if (y_ctr == 9'd479) begin
				y_ctr <= 9'h0;
				frame_ctr <= frame_ctr + 1'b1;
			end else begin
				y_ctr <= y_ctr + 1'b1;
			end
		end else begin
			x_ctr <= x_ctr + 1'b1;
		end
	end
end

dvi_tx_parallel #(
	.H_SYNC_POLARITY (1'b0),
	.H_FRONT_PORCH   (16),
	.H_SYNC_WIDTH    (96),
	.H_BACK_PORCH    (48),
	.H_ACTIVE_PIXELS (640),
	.V_SYNC_POLARITY (1'b0),
	.V_FRONT_PORCH   (10),
	.V_SYNC_WIDTH    (2),
	.V_BACK_PORCH    (33),
	.V_ACTIVE_LINES  (480)
) dvi (
	.clk     (clk_pix),
	.rst_n   (rst_n_pix),
	.en      (1'b1),
	.r       (x_ctr),
	.g       (y_ctr),
	.b       (frame_ctr),
	.rgb_rdy (rgb_rdy),
	.tmds2   (tmds2),
	.tmds1   (tmds1),
	.tmds0   (tmds0)
);

dvi_serialiser ser_d0 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds0),
	.qp        (dvi_p[0]),
	.qn        (dvi_n[0])
);

dvi_serialiser ser_d1 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds1),
	.qp        (dvi_p[1]),
	.qn        (dvi_n[1])
);

dvi_serialiser ser_d2 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds2),
	.qp        (dvi_p[2]),
	.qn        (dvi_n[2])
);

dvi_serialiser ser_ck (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (10'b1111100000),
	.qp        (dvi_p[3]),
	.qn        (dvi_n[3])
);

endmodule
