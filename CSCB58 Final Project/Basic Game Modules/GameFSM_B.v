module GameFSM (clk, reset, game_start, light_pattern, switch_pattern, life_count, score, Global_out, Sec3_out, life_enable, random_enable, lights_off, score_enable, state_light, select);
	input clk;
	input reset;
	input game_start;			//Game Start Signal
	input [15:0]light_pattern;	//Pattern of lights (From Light Select)
	input [15:0]switch_pattern;	//Pattern of Input
	input [3:0] life_count;		//Life count (From Life Counter)
	input [7:0] score;
	output [7:0]Global_out;		//Global Timer goes to HEX
	output [3:0]Sec3_out;		//3 Second Timer goes to HEX
	output reg life_enable;			//If on, life counter - 1. Goes to Life module.
	output reg random_enable;		//If on, allows RNG to switch numbers. Goes to RNG module.
	output reg lights_off;			//If on, turns lights off. Goes to Light Select module.
	output reg score_enable;		//If on, raises score by one. Goes to Score module.
	output reg [4:0] state_light;	
	output reg [1:0] select;
	
	wire global_half, global_sec, short_half, short_sec; //Global and 3, 1 and 0.5 second impulses.
	wire [3:0] out3;									 //3 second timer ran out signal.
	wire [3:0] stime;
	reg global_reset, short_reset;						 //Global and 3 second timer reset.
	reg global_enable, short_enable;					 //Global and 3 second timer enable.
	reg [2:0] state, next_state;
	reg global_timer_enable;
	reg [2:0] timeselect;
	
	
	assign Sec3_out = out3; //Assign 3second module to output.
	
	//States
	localparam
		idle = 4'b1000,
		get_random = 4'b0000,
		light_on = 4'b0001,
		switch_off = 4'b0101,
		dummy = 4'b0111,
		scoreplus = 4'b0100,
		loselife = 4'b0011,
		game_over = 4'b0010;
	
	//State Changes
	always @ (posedge clk)
	begin
		if(reset)
			state <= idle;
		else
			state <= next_state;
	end
	
	//Timer Modules
	sec_clock1 global(clk, global_enable, reset, global_half, global_sec),
			   short (clk, short_enable, short_reset, short_half, short_sec);
	Global_Timer gt (clk, global_sec, reset, Global_out);
	sec_clock3 s3 (clk, stime, short_sec, short_reset, out3);
	
	light_timer_mux ltm(timeselect, stime);
	
	//State Change Logic (State Table)
	always @ (*)
	begin
		case (state)
			idle: next_state = (game_start) ? get_random : idle; 
			//Waiting for game to start. Starts on switch, to game state.
			get_random: next_state = (reset) ? idle : (global_half) ? light_on : get_random;
			// Delays for new random number (3sec counter resets). Switches back to game on global half seconds.
			light_on: next_state = (reset) ? idle : (light_pattern == switch_pattern) ? switch_off : (out3 == 0) ? loselife : light_on;
			// Light turns on. If lights match switches, go to switches off state. If 3 seconds run out, go to lose life.
			switch_off: next_state = (reset) ? idle: (switch_pattern == 16'b0) ? scoreplus : (out3 == 0) ? dummy : switch_off;
			// Player must turn switches off (3sec counter continues). If switches off, go to score state. If 3 seconds run out, go to dummy then lose life.
			dummy: next_state = (reset) ? idle: loselife;
			// Dummy State to prevent bad connections.
			scoreplus: next_state = (reset) ? idle : get_random;
			// Score + 1. Go to new random/delay state.
			loselife: next_state = (reset) ? idle : (life_count == 0) ? game_over : get_random;
			// Player fails input. Loses a life. If life count is zero go to game over. Otherwise go to new random/delay state.
			game_over: next_state = (reset) ? idle : game_over;
			// Game Over. Stays until reset is hit.
			default: next_state = idle;
		endcase
	end
	
	//Output Logic Table
	always @ (*)
	begin

		
		case (state)
			idle: begin
				global_enable = 1'b0;	//Turn off global timer
				short_enable = 1'b0;	//Turn off 3sec timer 
				short_reset = 1'b1;		//Keep 3sec timer at 0
				life_enable = 1'b0;		//Don't reduce lives
				lights_off = 1'b1;		//Keep lights off
				random_enable = 1'b1;	//Allow RNG to change
				score_enable = 1'b0;		//Score remains
				global_timer_enable = 1'b0;
				state_light = 5'b00001;
				end
			get_random: begin
					if (score >= 8'b0011_0001) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b11;
					timeselect = 3'b010;
					end
					else if (score >= 8'b0010_0110 && score <= 8'b0011_0000) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b11;
					timeselect = 3'b001;
					end
					else if (score >= 8'b0010_0001 && score <= 8'b0010_0101) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b01;
					timeselect = 3'b010;
					end
					else if (score >= 8'b0001_0110 && score <= 8'b0010_0000) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b00;
					timeselect = 3'b010;
					end
					else if (score >= 8'b0001_0001 && score <= 8'b0001_0101) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b01;
					timeselect = 3'b001;
					end
					else if (score >= 8'b0000_0101 && score <= 8'b0001_0000) begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b00;
					timeselect = 3'b001;
					end
					else begin
					global_enable = 1'b1;	//Turn on global timer
					short_enable = 1'b0;	//3sec timer turns off
					short_reset = 1'b1;		//Reset 3sec timer at 0
					life_enable = 1'b0;		//Don't reduce lives
					lights_off = 1'b1;		//Keep lights off
					random_enable = 1'b0;	//Allow RNG to change
					score_enable = 1'b0;		//Score remains
					global_timer_enable = global_sec;
					state_light = 5'b00010;
					select = 2'b00;
					timeselect = 3'b000;
					end
				end
			light_on: begin
				global_enable = 1'b1;	//Global timer stays on
				short_enable = 1'b1;	//3sec timer starts
				short_reset = 1'b0;		//Allow 3sec timer to go
				life_enable = 1'b0;		//Don't reduce lives
				lights_off = 1'b0;		//Turn a light on
				random_enable = 1'b0;	//Freeze random number
				score_enable = 1'b0;		//Score remains
				global_timer_enable = global_sec;
				state_light = 5'b00011;
				end
			switch_off: begin
				global_enable = 1'b1;	//Global timer stays on
				short_enable = 1'b1;	//3sec timer continues
				short_reset = 1'b0;		//Allow 3sec timer to go
				life_enable = 1'b0;		//Don't reduce lives
				lights_off = 1'b1;		//Turn lights off
				random_enable = 1'b1;	//Allow RNG to change
				score_enable = 1'b0;		//Score remains
				global_timer_enable = global_sec;
				state_light = 5'b00100;
				end
			scoreplus: begin
				global_enable = 1'b1;	//Global timer stays on
				short_enable = 1'b0;	//3sec timer turns off
				short_reset = 1'b1;		//Reset 3sec timer to 0
				life_enable = 1'b0;		//Don't reduce lives
				lights_off = 1'b1;		//Turn lights off
				random_enable = 1'b1;	//Allow RNG to change
				score_enable = 1'b1;		//Increase score by 1
				global_timer_enable = global_sec;
				state_light = 5'b00101;
				end
			loselife: begin
				global_enable = 1'b1;	//Global timer stays on
				short_enable = 1'b0;	//3sec timer turns off
				short_reset = 1'b1;		//Reset 3sec timer at 0
				life_enable = 1'b1;		//Reduce lives
				lights_off = 1'b1;		//Keep lights off
				random_enable = 1'b1;	//Allow RNG to change
				score_enable = 1'b0;		//Score remains
				global_timer_enable = global_sec;
				state_light = 5'b00110;
				end
			game_over: begin
				global_enable = 1'b0;	//Global timer stops
				short_enable = 1'b0;	//3sec timer stays off
				short_reset = 1'b1;		//Keep 3sec timer at 0
				life_enable = 1'b0;		//Don't reduce lives
				lights_off = 1'b1;		//Keep lights off
				random_enable = 1'b1;	//Allow RNG to change
				score_enable = 1'b0;		//Score remains
				global_timer_enable = 1'b0;
				state_light = 5'b00111;
				end
		endcase
	end
endmodule

