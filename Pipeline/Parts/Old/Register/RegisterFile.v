module registerfile (clock, rd1, rd2, rd3, wr1, wr2, wr1_data, wr2_data, wr1_enable, wr2_enable, rd1_out, rd2_out, rd3_out);
	
	input clock;

// read inputs and outputs //

	input rd1;
	input rd2;
	input rd3;

	output rd1_out;
	output rd2_out;
	output rd3_out;

// write inputs and outputs //
	
	input wr1;
	input wr2;
	input wr1_data;
	input wr2_data;
	input wr1_enable;
	input wr2_enable;
// Wires //

	wire rd1;
	wire rd2;
	wire rd3;
	wire rd1_out;
	wire rd2_out;
	wire rd3_out;
	wire wr1;
	wire wr2;
	wire wr1_data;
	wire wr2_enable;
	wire wr2_data;
	wire wr1_enable;

// Initials //
	/*
	initial rd1 = 1;
	initial rd2 = 1;
	initial rd3 = 1;
	initial wr1 = 1;
	initial wr2 = 1;
	initial wr1_enable = 0;
	initial wr2_enable = 0;
	initial wr2_data = 1;
	initial wr1_data = 1;
	*/

// Registers //
	/*reg rd1_out;
	reg rd2_out;
	reg rd3_out;*/
	
	reg [07:00] data [03:00]; 
/*
	reg [07:00] zero;
	reg [07:00] one;
	reg [07:00] two;
	reg [07:00] three;
*/

// Read logic //
	
		assign rd1_out = data[rd1];
		assign rd2_out = data[rd2];
		assign rd3_out = data[rd3];
	

/*
	if (rd1 == 0) begin
		rd1_out = zero;
	end
	if (rd1 == 1) begin
		rd1_out = one;
	end
	if (rd1 == 2) begin
		rd1_out = two;
	end
	if (rd1 == 3) begin
		rd1_out = three;
	end

	if (rd2 == 0) begin
		rd2_out = zero;
	end
	if (rd2 == 1) begin
		rd2_out = one;
	end
	if (rd2 == 2) begin
		rd2_out = two;
	end
	if (rd2 == 3) begin
		rd2_out = three;
	end

	if (rd3 == 0) begin
		rd3_out = zero;
	end
	if (rd3 == 1) begin
		rd3_out = one;
	end
	if (rd3 == 2) begin
		rd3_out = two;
	end
	if (rd3 == 3) begin
		rd3_out = three;
	end


*/



// Write logic //
	always @(posedge clock) begin

		if (wr1_enable == 1) begin
			data[wr1] = wr1_data;
		end

		if (wr2_enable == 1) begin
			data[wr2] = wr2_data;
		end
	end

endmodule