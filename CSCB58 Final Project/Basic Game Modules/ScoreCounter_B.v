module score_count(clock, enable, reset, score);
	input enable;
	input reset;
	input clock;
	output reg [7:0] score;
	
	always@ (posedge clock)
	begin
		if (reset)
			score <= 0;
		else if(enable == 1'b1)
			score <= score + 1'b1;
		else
			score <= score;
	end
endmodule
