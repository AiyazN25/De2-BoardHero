module decimal_score_count(clock, enable, reset, score1, score2);
	input enable;
	input reset;
	input clock;
	output reg [3:0] score1, score2;
	
	always@ (posedge clock)
	begin
		if (reset) begin
			score1 <= 0;
			score2 <= 0;
		end
		else if(score1 == 4'b1001) begin
			score1 <= 0;
			score2 <= score2 + 1'b1;
		end
		else if(enable == 1'b1) begin
			score1 <= score1 + 1'b1;
			score2 <= score2;
		end
		else begin
			score1 <= score1;
			score2 <= score2;
		end
	end
endmodule 

//Not yet implemented in toplevel.
//Counts up first four bits when enable signal sent.
//When first four bits reaches 10, sets first four bits to 0 and last four bits counts up one.
//No limit for second four bits though.
