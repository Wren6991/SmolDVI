module smoldvi_tmds_encode (
	input  wire       clk,
	input  wire       rst_n,

	input  wire [1:0] c,
	input  wire [7:0] d,
	input  wire       den,

	output reg  [9:0] q
);

reg [9:0] sym0, sym1;

always @ (*) begin
	case (d[7:2])
		0 : begin sym0 = 10'h100; sym1 = 10'h1ff; end
		1 : begin sym0 = 10'h1fc; sym1 = 10'h103; end
		2 : begin sym0 = 10'h1f8; sym1 = 10'h107; end
		3 : begin sym0 = 10'h104; sym1 = 10'h1fb; end
		4 : begin sym0 = 10'h1f0; sym1 = 10'h10f; end
		5 : begin sym0 = 10'h10c; sym1 = 10'h1f3; end
		6 : begin sym0 = 10'h108; sym1 = 10'h1f7; end
		7 : begin sym0 = 10'h1f4; sym1 = 10'h10b; end
		8 : begin sym0 = 10'h1e0; sym1 = 10'h11f; end
		9 : begin sym0 = 10'h11c; sym1 = 10'h1e3; end
		10: begin sym0 = 10'h118; sym1 = 10'h1e7; end
		11: begin sym0 = 10'h1e4; sym1 = 10'h11b; end
		12: begin sym0 = 10'h110; sym1 = 10'h1ef; end
		13: begin sym0 = 10'h1ec; sym1 = 10'h113; end
		14: begin sym0 = 10'h1e8; sym1 = 10'h117; end
		15: begin sym0 = 10'h241; sym1 = 10'h2be; end
		16: begin sym0 = 10'h1c0; sym1 = 10'h13f; end
		17: begin sym0 = 10'h13c; sym1 = 10'h1c3; end
		18: begin sym0 = 10'h138; sym1 = 10'h1c7; end
		19: begin sym0 = 10'h1c4; sym1 = 10'h13b; end
		20: begin sym0 = 10'h130; sym1 = 10'h1cf; end
		21: begin sym0 = 10'h1cc; sym1 = 10'h133; end
		22: begin sym0 = 10'h1c8; sym1 = 10'h137; end
		23: begin sym0 = 10'h261; sym1 = 10'h29e; end
		24: begin sym0 = 10'h120; sym1 = 10'h1df; end
		25: begin sym0 = 10'h1dc; sym1 = 10'h123; end
		26: begin sym0 = 10'h1d8; sym1 = 10'h127; end
		27: begin sym0 = 10'h271; sym1 = 10'h28e; end
		28: begin sym0 = 10'h1d0; sym1 = 10'h12f; end
		29: begin sym0 = 10'h279; sym1 = 10'h286; end
		30: begin sym0 = 10'h27d; sym1 = 10'h282; end
		31: begin sym0 = 10'h281; sym1 = 10'h27e; end
		32: begin sym0 = 10'h180; sym1 = 10'h17f; end
		33: begin sym0 = 10'h17c; sym1 = 10'h183; end
		34: begin sym0 = 10'h178; sym1 = 10'h187; end
		35: begin sym0 = 10'h184; sym1 = 10'h17b; end
		36: begin sym0 = 10'h170; sym1 = 10'h18f; end
		37: begin sym0 = 10'h18c; sym1 = 10'h173; end
		38: begin sym0 = 10'h188; sym1 = 10'h177; end
		39: begin sym0 = 10'h221; sym1 = 10'h2de; end
		40: begin sym0 = 10'h160; sym1 = 10'h19f; end
		41: begin sym0 = 10'h19c; sym1 = 10'h163; end
		42: begin sym0 = 10'h198; sym1 = 10'h167; end
		43: begin sym0 = 10'h231; sym1 = 10'h2ce; end
		44: begin sym0 = 10'h190; sym1 = 10'h16f; end
		45: begin sym0 = 10'h239; sym1 = 10'h2c6; end
		46: begin sym0 = 10'h23d; sym1 = 10'h2c2; end
		47: begin sym0 = 10'h2c1; sym1 = 10'h23e; end
		48: begin sym0 = 10'h140; sym1 = 10'h1bf; end
		49: begin sym0 = 10'h1bc; sym1 = 10'h143; end
		50: begin sym0 = 10'h1b8; sym1 = 10'h147; end
		51: begin sym0 = 10'h211; sym1 = 10'h2ee; end
		52: begin sym0 = 10'h1b0; sym1 = 10'h14f; end
		53: begin sym0 = 10'h219; sym1 = 10'h2e6; end
		54: begin sym0 = 10'h21d; sym1 = 10'h2e2; end
		55: begin sym0 = 10'h2e1; sym1 = 10'h21e; end
		56: begin sym0 = 10'h1a0; sym1 = 10'h15f; end
		57: begin sym0 = 10'h209; sym1 = 10'h2f6; end
		58: begin sym0 = 10'h20d; sym1 = 10'h2f2; end
		59: begin sym0 = 10'h2f1; sym1 = 10'h20e; end
		60: begin sym0 = 10'h205; sym1 = 10'h2fa; end
		61: begin sym0 = 10'h2f9; sym1 = 10'h206; end
		62: begin sym0 = 10'h2fd; sym1 = 10'h202; end
		63: begin sym0 = 10'h201; sym1 = 10'h2fe; end
	endcase
end

reg [9:0] q_next;
reg       use_q_next;

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		q <= 10'd0;
		q_next <= 10'd0;
	end else begin
		if (den) begin
			q <= use_q_next ? q_next : sym0;
			q_next <= sym1;
			use_q_next <= !use_q_next;
		end else begin
			use_q_next <= 1'b0;
			case (c)
				2'b00: q <= 10'b1101010100;
				2'b01: q <= 10'b0010101011;
				2'b10: q <= 10'b0101010100;
				2'b11: q <= 10'b1010101011;
			endcase
		end
	end
end

endmodule
