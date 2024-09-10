/*
Name: Ellie Sundheim (esundheim@hmc.edu)
Date: 9/9/24
This file contains code to turn on a 7 segment LED display given a hex digit from 0-F (redone after lab 2)
*/

module lab1_es(input logic[3:0] s,
		output logic[2:0] led,
		output logic[6:0] seg);
	//removed clk from input list because we're using the osicllator instead			
	logic reset = 0;					
	oscillator myOsc(clk);
    	leds myLeds (clk, s, led);
	seven_seg_disp myDisplay(s, seg);
	
endmodule			

module leds(input logic clk,
	    input logic reset,
            input logic [3:0] s,
            output logic [2:0] led);

    //assign combinational leds			
	assign led[0] = s[0] ^ s[1];
	assign led[1] = s[2] & s[3];
	
	//assign blinking led with a counter(2.4Hz)
	logic [24:0] counter;

	always_ff @(posedge clk, posedge reset) begin
		if (reset) counter <= 0;
		else counter <= counter + 1;
   end
  
   // Assign LED output 
   // 2^23 is roughly 8 million, we wanted to divide by 10 million, close enough
   assign led[2] = counter[24];
   endmodule


// internal oscillator
module oscillator(output logic clk);

	logic int_osc;
  
	// Internal high-speed oscillator (div 2'b01 makes it oscillate at 24Mhz)
	HSOSC #(.CLKHF_DIV(2'b01)) 
         hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

    assign clk = int_osc;
  
endmodule		
				
module seven_seg_disp(input logic[3:0] s,
						output logic[6:0] seg);
	always_comb
	begin
		case(s[3:0])
			// select which segments need to light up based on which hex munber is input (seg = 7'b 6543210)
			4'b0000: seg = 7'b0111111;
			4'b0001: seg = 7'b0000110;
			4'b0010: seg = 7'b1011011;
			4'b0011: seg = 7'b1001111;
			4'b0100: seg = 7'b1100110;
			4'b0101: seg = 7'b1101101;
			4'b0110: seg = 7'b1111101;
			4'b0111: seg = 7'b0000111;
			
			4'b1000: seg = 7'b1111111;
			4'b1001: seg = 7'b1100111;
			4'b1010: seg = 7'b1110111;
			4'b1011: seg = 7'b1111100;
			4'b1100: seg = 7'b1011000;
			4'b1101: seg = 7'b1011110;
			4'b1110: seg = 7'b1111001;
			4'b1111: seg = 7'b1110001;
			default: seg = 7'b0000000;
		endcase
		//flip the bits because segment leds are actually active low
		seg = ~seg;
	end 

endmodule
				


// testbench settings
`timescale 1ns/1ns
`default_nettype none
`define N_TV 8

//testbench
module testbench();
	logic clk, reset;
	logic [3:0] s;
	logic [4:0] led;
	logic [6:0] seg;
	
	
	//instantiate test modules
	//top dut(s1, s2, led, anode1_en, seg);
	oscillator myOsc(clk);
	leds myLeds (clk, reset, s, led);
	seven_seg_disp myDisplay(s, seg);

		
		
	// At the start of the simulation:
	//  - Pulse the reset line (if applicable)
 initial
   begin
     reset = 0; #12; reset = 1; #27; reset = 0;
	 
     //test for oscillator: just look and see if clk is pulsing
     //test for seven_seg_disp : check against truth table
     s = 4'b0000; #10;
     s = 4'b0001; #10;
     s = 4'b0010; #10;
     s = 4'b0011; #10;
     s = 4'b0100; #10;
     s = 4'b0101; #10;
     s = 4'b0110; #10;
     s = 4'b0111; #10;
     s = 4'b1000; #10; //8
     s = 4'b1001; #10;
     s = 4'b1010; #10;
     s = 4'b1011; #10;
     s = 4'b1100; #10;
     s = 4'b1101; #10;
     s = 4'b1110; #10;
     s = 4'b1111; #10;

     //test for led
     s = 4'b0001; #10; //led[0] should be on
     s = 4'b0010; #10; //led[0] should be on
     s = 4'b0011; #10; //led[0] should be off
     s = 4'b0000; #10; //led[0] should be off
     s = 4'b1100; #10; //led[1] should be on
     s = 4'b0100; #10; //led[1] should be off
     s = 4'b1000; #10; //led[1] should be off

	 
   end
  
endmodule