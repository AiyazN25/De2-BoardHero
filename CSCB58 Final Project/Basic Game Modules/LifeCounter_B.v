module LifeCounter(clock,lose_life, reset, lives);
	input clock;
	input lose_life;
	input reset;
	output reg [3:0]lives;
	
	always@(posedge clock)
	begin
		if(reset)
			lives <= 4'b0010;
		else if(lose_life)
			lives <= lives - 1'b1;
		else
			lives <= lives;
	end
endmodule
