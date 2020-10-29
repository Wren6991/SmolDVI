// For CDC we need a 10:2 gearbox (pixel domain to DDR bit domain) with at
// least 20 bits of storage, preferably 40. However the standard gearbox in
// libfpga struggles to reach the 126 MHz half-bit-clock frequency on UP5k, so
// we create a faster gearbox which works as follows:
//
// - Pixel domain writes to successive chunks of a N*10-flop register as usual
//
// - These N*10 launch flops are overlaid with N*10 DFFEs (the sampling
//   register), in half-bit-clock domain, of which only 2 DFFEs are
//   enabled on each cycle
//
// - On each successive clock cycle, the next two sampling flops are enabled,
//   such that sampling runs around the sampling register at the same rate as
//   transitions run around the launching register
//
// - Because we have guaranteed spacing between *enabled* sampling flops, and
//   *transitioning* launch flops, no part of the sampling register should
//   become metastable
//
// - Once we are safely in the half-bit-clock domain, we can do a
//   pipelined one-hot mux to pull out the correct bit pair from the sampling
//   register, and pass this on to the DDR output regs in the IO tiles
//
// - The one-hot mask used for both DFFE enables and muxing can be generated
//   with a simple ring counter, rather than decoding from a binary counter.
//   This avoids any carry chain, and limits the fanout of each flop in the
//   counter to 3, no matter how large the CDC storage is.

`default_nettype none

module smoldvi_fast_gearbox #(
	parameter W_IN = 10,
	parameter W_OUT = 2,
	// You should set this by hand, it may be hugely pessimistic *or* optimistic:
	parameter STORAGE_SIZE = W_IN * W_OUT
) (
	input  wire            clk_in,
	input  wire            rst_n_in,
	input  wire [W_IN-1:0] din,

	input  wire            clk_out,
	input  wire            rst_n_out,
	output reg [W_OUT-1:0] dout
);

localparam N_IN = STORAGE_SIZE / W_IN;
localparam N_OUT = STORAGE_SIZE / W_OUT;

(* keep = 1'b1 *) reg [STORAGE_SIZE-1:0] launch_reg;
(* keep = 1'b1 *) reg [STORAGE_SIZE-1:0] capture_reg;

// ----------------------------------------------------------------------------
// Apply transitions to sections of launch register, in a circular manner,
// across successive clk_in cycles

(* keep = 1'b1 *) reg [STORAGE_SIZE-1:0] launch_reg;
reg [N_IN-1:0] wmask;

always @ (posedge clk_in or negedge rst_n_in) begin
	if (!rst_n_in) begin
		wmask <= {{N_IN-1{1'b0}}, 1'b1};
	end else begin
		wmask <= {wmask[N_IN-2:0], wmask[N_IN-1]};
	end
end

always @ (posedge clk_in) begin: wport
	integer i;
	for (i = 0; i < N_IN; i = i + 1) begin
		if (wmask[i])
			launch_reg[i * W_IN +: W_IN] <= din;
	end
end

// ----------------------------------------------------------------------------
// Apply enables to sections of capture register, in a circular manner, across
// successive clk_out cycles (hopefully staying distant from the transitions!)

(* keep = 1'b1 *) reg [STORAGE_SIZE-1:0] capture_reg;
reg [N_OUT-1:0] rmask;

always @ (posedge clk_out or negedge rst_n_out) begin: capture_proc
	if (!rst_n_out) begin
		rmask <= 10'b00001_00000; // FIXME general code to select antiphase point
	end else begin
		rmask <= {rmask[N_OUT-2:0], rmask[N_OUT-1]};
	end
end

always @ (posedge clk_out) begin: capture_proc
	integer i;
	for (i = 0; i < N_OUT; i = i + 1) begin
		if (rmask[i])
			capture_reg[i * W_OUT +: W_OUT] <= launch_reg[i * W_OUT +: W_OUT];
	end
end

// ----------------------------------------------------------------------------
// CDC done, now on to the muxing

wire [N_OUT-1:0] rmask_delayed = {rmask[0], rmask[N_OUT-1:1]};
reg [STORAGE_SIZE-1:0] captured_masked;

always @ (posedge clk_out) begin: output_mask
	integer i;
	for (i = 0; i < STORAGE_SIZE; i = i + 1) begin
		captured_masked[i] <= capture_reg[i] && rmask_delayed[i / W_OUT];
	end
end

// Do the OR reduction in one cycle. For 20 storage flops this is a 10:1
// reduction, which costs 2 LUT delays. Easiest way to reduce further is to add
// an empty pipe stage afterward and tell the tools to retime :) OR reductions
// are very retimable.

reg [W_OUT-1:0] muxed;

always @ (*) begin: output_mux
	integer i, j;
	for (i = 0; i < W_OUT; i = i + 1) begin
		muxed[i] = 1'b0;
		for (j = 0; j < N_OUT; j = j + 1) begin
			muxed[i] = muxed[i] || captured_masked[j * W_OUT + i];
		end
	end
end

always @ (posedge clk_out) begin
	dout <= muxed;
end

endmodule
