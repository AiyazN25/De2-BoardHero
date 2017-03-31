module sec_clock3 (clock,stime, enable,reset,out);
	input clock;
	input reset;
	input enable;
	input [3:0] stime;
	output reg [3:0]out;
	
	always @ (posedge clock, posedge reset)
	begin
		if (reset)
			out <= stime;
		else if (enable == 1'b1)
			out <= out-1;
		else
			out <= out;
	end
	
endmodule
