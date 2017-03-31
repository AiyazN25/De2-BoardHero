module LightAdder(L1, L2, L3, select, out);
	input [16:0] L1, L2, L3;
	input [1:0] select;
	output reg [15:0] out;
	
	reg [16:0] temp;
	
	always @ (*)
	begin
		case(select[1:0])
			2'b00: temp = L1;
			2'b01: temp = L1 + L2;
			2'b11: temp = L1 + L2 + L3;
			default: temp = L1;
		endcase
	end
	
	always @ (*)
	begin
		if (temp >= 17'b10000000000000000)
			out = temp[16:1];
		else
			out = temp[15:0];
	end
endmodule 

//Depending on level, adds light patterns together so that more lights turn on.