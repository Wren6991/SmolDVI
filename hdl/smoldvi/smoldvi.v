module smoldvi #(
	// Defaults are for 640x480p 60 Hz (from CEA 861D).
	// All horizontal timings are in pixels.
	// All vertical timings are in scanlines.
	parameter H_SYNC_POLARITY   = 1'b0, // 0 for active-low pulse
	parameter H_FRONT_PORCH     = 16,
	parameter H_SYNC_WIDTH      = 96,
	parameter H_BACK_PORCH      = 48,
	parameter H_ACTIVE_PIXELS   = 640,

	parameter V_SYNC_POLARITY   = 1'b0, // 0 for active-low pulse
	parameter V_FRONT_PORCH     = 10,
	parameter V_SYNC_WIDTH      = 2,
	parameter V_BACK_PORCH      = 33,
	parameter V_ACTIVE_LINES    = 480,

	parameter RGB_BITS = 6              // 1 to 7 bits, inclusive
) (
	// Full-rate pixel clock, half-rate bit clock. Must have exact 1:5 frequency
	// ratio, and a common root oscillator
	input wire                 clk_pix,
	input wire                 rst_n_pix,
	input wire                 clk_bit,
	input wire                 rst_n_bit,

	input wire                 en,

	input  wire [RGB_BITS-1:0] r,
	input  wire [RGB_BITS-1:0] g,
	input  wire [RGB_BITS-1:0] b,
	output wire                rgb_rdy,

	// {CK, D2, D1, D0}
	output wire [3:0]          dvi_p,
	output wire [3:0]          dvi_n
);


wire hsync;
wire vsync;
wire den;

reg den_prev;
reg rgb_rdy_prev;
assign rgb_rdy = den && den_prev && !rgb_rdy_prev;

always @ (posedge clk_pix or negedge rst_n_pix) begin
	if (!rst_n_pix) begin
		den_prev <= 1'b0;
		rgb_rdy_prev <= 1'b0;		
	end else begin
		den_prev <= den;
		rgb_rdy_prev <= rgb_rdy;
	end
end

smoldvi_timing #(
	.H_SYNC_POLARITY (H_SYNC_POLARITY),
	.H_FRONT_PORCH   (H_FRONT_PORCH),
	.H_SYNC_WIDTH    (H_SYNC_WIDTH),
	.H_BACK_PORCH    (H_BACK_PORCH),
	.H_ACTIVE_PIXELS (H_ACTIVE_PIXELS),

	.V_SYNC_POLARITY (V_SYNC_POLARITY),
	.V_FRONT_PORCH   (V_FRONT_PORCH),
	.V_SYNC_WIDTH    (V_SYNC_WIDTH),
	.V_BACK_PORCH    (V_BACK_PORCH),
	.V_ACTIVE_LINES  (V_ACTIVE_LINES)
) inst_dvi_timing (
	.clk   (clk_pix),
	.rst_n (rst_n_pix),
	.en    (en),

	.vsync (vsync),
	.hsync (hsync),
	.den   (den)
);

localparam [8-RGB_BITS-1:0] RGB_PAD = {8-RGB_BITS{1'b0}};

wire [9:0] tmds0;
wire [9:0] tmds1;
wire [9:0] tmds2;

smoldvi_tmds_encode tmds0_encoder (
	.clk   (clk_pix),
	.rst_n (rst_n_pix),
	.c     ({vsync, hsync}),
	.d     ({b, RGB_PAD}),
	.den   (den),
	.q     (tmds0)
);

smoldvi_tmds_encode tmds1_encoder (
	.clk   (clk_pix),
	.rst_n (rst_n_pix),
	.c     (2'b00),
	.d     ({g, RGB_PAD}),
	.den   (den),
	.q     (tmds1)
);

smoldvi_tmds_encode tmds2_encoder (
	.clk   (clk_pix),
	.rst_n (rst_n_pix),
	.c     (2'b00),
	.d     ({r, RGB_PAD}),
	.den   (den),
	.q     (tmds2)
);

smoldvi_serialiser ser_d0 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds0),
	.qp        (dvi_p[0]),
	.qn        (dvi_n[0])
);

smoldvi_serialiser ser_d1 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds1),
	.qp        (dvi_p[1]),
	.qn        (dvi_n[1])
);

smoldvi_serialiser ser_d2 (
	.clk_pix   (clk_pix),
	.rst_n_pix (rst_n_pix),
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.d         (tmds2),
	.qp        (dvi_p[2]),
	.qn        (dvi_n[2])
);

smoldvi_clock_driver ser_ck (
	.clk_x5    (clk_bit),
	.rst_n_x5  (rst_n_bit),

	.qp        (dvi_p[3]),
	.qn        (dvi_n[3])
);

endmodule
