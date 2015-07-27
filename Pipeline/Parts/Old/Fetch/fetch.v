module theclock;
	initial clock = 1;
	reg clock;
	always begin
		#1 clock = ~ clock;
	end
endmodule

module fetch(clock); /*memory address register (MA), 
                       memory data register    (fetchoutput), 
                       an accumulator          (AC), 
                       an instruction register (IR), 
                       a program counter       (PC).
                       */
	input clock;
	wire clock;
	reg [0:15] AC, fetchoutput, IR;
	reg [0:9]  MA, PC;
	reg [0:15] instruction_memory [0:1048575];
	initial begin
		$readmemh ("instructionmemory.list", instruction_memory);
	end
	always @(posedge clock) begin
		// instruction fetch
		MA <= PC;
		fetchoutput <= instruction_memory[MA];
		// memory read
		IR <= fetchoutput;
		PC <= PC + 1;
		end
endmodule
