module RNG (clk, rst, enable, rnd);
	
	input clk;
	input rst;
	input enable;
	output reg [3:0]rnd;
	
	wire feedback;
	reg [12:0] random, random_next, random_done;
	reg [3:0] count, count_next;
	
	assign feedback = random[12] ^ random[3] ^ random[2] ^ random[0];
	
	always @ (posedge clk, posedge rst)
	begin
		if(rst)
		begin
			random <= 13'b1111010101111;
			count <= 0;
		end
		
		else if (count == 13)
		begin
			count = 0;
			random_done = random;
		end
		
		else
		begin
			random <= {random[11:0], feedback};
			count <= count + 1;
		end
	end
	
	always @(*)
	begin 
		if(enable)
			rnd <= random_done[12:9];
		else
			rnd <= rnd;
	end
endmodule
