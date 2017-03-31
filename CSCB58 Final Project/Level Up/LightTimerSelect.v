module light_timer_mux(select, timeselected);
	input [2:0]select;
	output reg [3:0]timeselected;
	
	always @(*)
	begin
		case(select)
			3'b000: timeselected = 4'b0100;
			3'b001: timeselected = 4'b0011;
			3'b010: timeselected = 4'b0010;
		endcase
	end
endmodule

//Depending on level, changes the amount of time player has to hit the switches.