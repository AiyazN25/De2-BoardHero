module toplevel (CLOCK_50, SW, KEY, LEDR, LEDG, HEX0, HEX1, HEX3, HEX4, HEX5, HEX6);
	input CLOCK_50;
	input [17:0] SW;
	input [3:0] KEY;
	output [17:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0, HEX1, HEX3, HEX4, HEX5, HEX6;
	
	wire [15:0] lights1, lights2, lights3, lightsout;		//Light pattern - Goes from lightselector to FSM and LEDs
	wire [3:0] lives;		//Life count	- Goes from lifecounter to FSM and HEX
	wire [7:0] globaltimer;		//Global timer 	- Goes from globaltimer in FSM to HEX
	wire [3:0] lighttimer;		//3sec timer	- Goes from 3sectimer in FSM to Hex
	wire [7:0] score;		//Score Counter	- Goes from scorecounter to HEX
	wire lifeloss;			//Life decrease enabler		- Goes from FSM to lifecounter
	wire random_enable;		//Random number change enabler	- Goes from FSM to RNG
	wire lights_off;		//Turns lights off		- Goes from FSM to lightselector
	wire score_enable;		//Increase score by one enabler	- Goes from FSM to scorecounter
	wire [3:0] random_number1, random_number2, random_number3;	//Generated Random Number	- Goes from RNG to lightselector
	wire [3:0]lifehex;	//Cheat Add 1 to life send to hex.
	wire [4:0] state;
	wire [1:0] select;
	
	assign lifehex = lives + 1'b1;
	
	
	GameFSM game(CLOCK_50, SW[16], SW[17], lightsout, SW[15:0], lives, score, globaltimer, lighttimer, lifeloss, random_enable, lights_off, score_enable, state, select);
	RNG	random1(CLOCK_50, SW[16], random_enable, random_number1);
	RNG2	random2(CLOCK_50, SW[16], random_enable, random_number2);
	RNG3	random3(CLOCK_50, SW[16], random_enable, random_number3);
			
	light_mux lightselect1(random_number1, lights_off, lights1),
				 lightselect2(random_number2, lights_off, lights2),
				 lightselect3(random_number3, lights_off, lights3);
	LifeCounter life(CLOCK_50,lifeloss, SW[16], lives);

	
	LightAdder	la(lights1,lights2,lights3,select,lightsout);
	
	decimal_score_count dsc(CLOCK_50, score_enable, SW[16], score[3:0], score[7:4]);
	
	hex_decoder		gametime1(globaltimer[3:0], HEX0),
				gametime2(globaltimer[7:4], HEX1),
				lighttime(lighttimer, HEX3),
				scount1(score[3:0], HEX4),
				scount2(score[7:4], HEX5),
				lifecount(lifehex, HEX6);
	
	assign LEDR[15:0] = lightsout;
	assign LEDG[7:5] = (lives == 4'b0010) ? 3'b111 : (lives == 4'b0001) ? 3'b011 : (lives == 4'b0000) ? 3'b001 : 3'b000;
	assign LEDG[4:0] = state;
endmodule
