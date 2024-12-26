module TB();
    wire [7:0] leds_tb;
	reg [4:0] btns;
    reg clk = 0;
    main uut(
	.clk_1(clk),
	.clk_2(~clk),
	.leds(leds_tb),
	.btns(btns)
);

/*initial begin
        clk = 0;
        forever #5 clk = ~ clk;
    end
 initial begin
        btns = 4'b0000;
        // 1
        btns[0] = 1;
        #1000;
        btns[0] = 0;
		#10;
        btns[1] = 1;
        #1000;
        btns[1] = 0;
		#10
        btns[1] = 1;
        #1000;
        btns[1] = 0;
		#10; 
        btns[0] = 1; 
        #1000;
        btns[0] = 0; 
		#10;

        // 2
        btns[0] = 1;
        #10;
        btns[0] = 0;
		#10;
        btns[1] = 1;
        #10;
        btns[1] = 0;
		#10
        btns[1] = 1;
        #10;
        btns[1] = 0;
		#10; 
        btns[2] = 1; 
        #10;
        btns[2] = 0;
		#10;
		btns[0] = 1;
		#10;
		btns[0] = 0; 
		#10;

		btns = 4'b0000;
        // 3
        btns[0] = 1;
        #10;
        btns[0] = 0;
		#10;
        btns[1] = 1;
        #10;
        btns[1] = 0;
		#10
        btns[1] = 1;
        #10;
        btns[1] = 0;
		#10; 
        btns[3] = 1; 
        #10;
        btns[3] = 0;
    end */
always #2.5 clk <= clk + 1;
endmodule
