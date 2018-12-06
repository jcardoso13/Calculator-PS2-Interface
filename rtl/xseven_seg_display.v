`timescale 1ns / 1ps



module xseven_seg_display(
    input clk, // clock source on Basys 3 FPGA
    input reset, // reset
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out,// cathode patterns of the 7-segment LED display
    
	 input dp, //point
     input display_sel,
	 input [15:0] displayed_number // number to be displayed

	 );
	 
	 reg [15:0] displayed_number1;
	 reg [15:0] cnt = 0;

    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter; // 20-bit for creating 10.5ms refresh period or 380Hz refresh rate
             // the first 2 MSB bits for creating 4 LED-activating signals with 2.6ms digit period
    wire [1:0] LED_activating_counter; 
                 // count     0    ->  1  ->  2  ->  3
              // activates    LED1    LED2   LED3   LED4
             // and repeat
				 
				 
/*				 
		always @(posedge clk)
    begin 
			if (cnt==16'hFFFF)
			begin
				cnt<=0;
				displayed_number1 <= displayed_number1+1;
			end
			else
				cnt<=cnt+1;
    end 		 
			*/
	 

    always @(posedge clk)
    begin 
			if (display_sel==1'b1)
			displayed_number1 = displayed_number;
			if (refresh_counter==20'hFFFFF)
					refresh_counter <= 0; 
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];
    // decoder to generate anode signals 
    always @(posedge clk)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = displayed_number1/4096;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = (displayed_number1 % 4096)/256;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = ((displayed_number1 % 4096)%256)/16;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = ((displayed_number1 % 4096)%256)%16;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b1000000; // "0"     
        4'b0001: LED_out = 7'b1111001; // "1" 
        4'b0010: LED_out = 7'b0100100; // "2" 
        4'b0011: LED_out = 7'b0110000; // "3" 
        4'b0100: LED_out = 7'b0011001; // "4" 
        4'b0101: LED_out = 7'b0010010; // "5" 
        4'b0110: LED_out = 7'b0000010; // "6" 
        4'b0111: LED_out = 7'b1111000; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0010000; // "9" 
        4'b1010: LED_out = 7'b0001000; // "A" 
        4'b1011: LED_out = 7'b0000011; // "B" 
        4'b1100: LED_out = 7'b1000110; // "C" 
        4'b1101: LED_out = 7'b0100001; // "D" 
        4'b1110: LED_out = 7'b0000110; // "E" 
        4'b1111: LED_out = 7'b0001110; // "F" 
        default: LED_out = 7'b1000000; // "0"
        endcase
    end
	 
endmodule 