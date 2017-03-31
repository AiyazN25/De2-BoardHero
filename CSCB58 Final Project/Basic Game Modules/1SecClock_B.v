module sec_clock1 (clock,enable,reset,halfsec,sec);
	input clock;
	input reset;
	input enable;
	output halfsec;
	output sec;
	
	reg [25:0] count;
	
	always @ (posedge clock, posedge reset)
	begin
		if (reset)
			count <= 0;
		else if (count == 26'b10111110101111000001111111)
			count <= 0;
		else if (enable == 1'b1)
			count <= count + 1'b1;
	end
	
	assign halfsec = (count == 26'b01011111010111100000111111) ? 1 : 0;
	assign sec = (count == 26'b0) ? 1 : 0;
endmodule
