module decimal_global_timer(clock, enable, reset, out1, out2);
	input clock; 
	input enable;
	input reset;
	output reg [3:0]out1, out2;
	
	always @ (posedge clock)
	begin
		if (reset) begin
			out1 <= 0;
			out2 <= 0;
		end
		else if (out1 <= 4'b1001) begin
			out1 <= 0;
			out2 <= out2 + 1'b1;
		end
		else if (enable == 1'b1) begin
			out1 <= out1 + 1'b1;
			out2 <= out2;
		end
		else begin
			out1 <= out1;
			out2 <= out2;
		end
	end
endmodule 

//Not yet implementedin toplevel.
//Counts up first four bits when enable signal sent.
//When first four bits reaches 10, sets first four bits to 0 and last four bits counts up one.
//No limit for second four bits.

//Not sure if both else if conditions will take place at the same time.
//If not, then first four bits may stop at 'A'(10) before switching to 0 on the next second count.
