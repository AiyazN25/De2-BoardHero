module Global_Timer (clock,enable,reset,out); 
	input clock; 
	input enable;
	input reset;
	output reg [7:0]out;
	
	always @ (posedge clock, posedge reset)
	begin
		if (reset)
			out <= 0;
		else if (enable == 1'b1)
			out <= out + 1'b1;
	end
endmodule
