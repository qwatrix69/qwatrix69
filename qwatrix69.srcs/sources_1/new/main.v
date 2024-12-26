`timescale 1ns / 1ps

module main(
    input clk_1,
    input clk_2,
    output [7:0] leds,
    input [4:0] btns,
    output LCD_DB4_LS,
    output LCD_DB5_LS,
    output LCD_DB6_LS,
    output LCD_DB7_LS,
    output LCD_E_LS,
    output LCD_RS_LS,
    output LCD_RW_LS
);

wire buf_out, out, CLKOUT0, o, o1;

IBUFDS #( 
  .DIFF_TERM("FALSE"),       // Differential Termination
  .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
  .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
) IBUFDS_inst (
  .O(buf_out),  // Buffer output
  .I(clk_1),  // Diff_p buffer input (connect directly to top-level port)
  .IB(clk_2) // Diff_n buffer input (connect directly to top-level port)
);

BUFG BUFG_inst ( 
  .O(out), // 1-bit output: Clock output
  .I(buf_out)  // 1-bit input: Clock input
);
    
   MMCME2_BASE #( 
      .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F(5),     // Multiply value for all CLKOUT (2.000-64.000).
      .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD(5.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      .CLKOUT1_DIVIDE(12),
      .CLKOUT2_DIVIDE(24),
      .CLKOUT3_DIVIDE(48),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      .CLKOUT6_DIVIDE(1),
      .CLKOUT0_DIVIDE_F(12),    // Divide amount for CLKOUT0 (1.000-128.000).
      // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      .CLKOUT6_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(18.75),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLKOUT6_PHASE(0.0),
      .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .DIVCLK_DIVIDE(1),         // Master division value (1-106)
      .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
      .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   MMCME2_BASE_inst (
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
      .CLKOUT0(CLKOUT0),     // 1-bit output: CLKOUT0
      .CLKOUT0B(CLKOUT0B),   // 1-bit output: Inverted CLKOUT0
      .CLKOUT1(CLKOUT1),     // 1-bit output: CLKOUT1
      .CLKOUT1B(CLKOUT1B),   // 1-bit output: Inverted CLKOUT1
      .CLKOUT2(CLKOUT2),     // 1-bit output: CLKOUT2
      .CLKOUT2B(CLKOUT2B),   // 1-bit output: Inverted CLKOUT2
      .CLKOUT3(CLKOUT3),     // 1-bit output: CLKOUT3
      .CLKOUT3B(CLKOUT3B),   // 1-bit output: Inverted CLKOUT3
      .CLKOUT4(CLKOUT4),     // 1-bit output: CLKOUT4
      .CLKOUT5(CLKOUT5),     // 1-bit output: CLKOUT5
      .CLKOUT6(CLKOUT6),     // 1-bit output: CLKOUT6
      // Feedback Clocks: 1-bit (each) output: Clock feedback ports
      .CLKFBOUT(CLKFBOUT),   // 1-bit output: Feedback clock
      .CLKFBOUTB(CLKFBOUTB), // 1-bit output: Inverted CLKFBOUT
      // Status Ports: 1-bit (each) output: MMCM status ports
      .LOCKED(LOCKED),       // 1-bit output: LOCK
      // Clock Inputs: 1-bit (each) input: Clock input
      .CLKIN1(out),       // 1-bit input: Clock
      // Control Ports: 1-bit (each) input: MMCM control ports
      .PWRDWN(0),       // 1-bit input: Power-down
      .RST(0),             // 1-bit input: Reset
      // Feedback Clocks: 1-bit (each) input: Clock feedback ports
      .CLKFBIN(CLKFBOUT)      // 1-bit input: Feedback clock
   );

wire [4:0] LED;
wire slow_clk;

counter uut_c(
    .CLKOUT0(CLKOUT0),
    .out_c(LED),
    .slow_clk(slow_clk)
);

wire [4:0] deb_btns;
debounce uut_deb (
  .btns(btns),
  .clk(CLKOUT0),
  .slow_clk(slow_clk),
  .deb_btns(deb_btns)
);

wire [7:0] temp2;
fsm uut_f (
  .btns(deb_btns),
  .clk(CLKOUT0),
  .led(temp2)
);

wire [1:0] temp1;
main_lab1 uut( 
.X(LED[0]), 
.Y(LED[1]),     
.Z(LED[2]), 
.K(LED[3]),     
.L(LED[4]), 
.O1(temp1[0]),     
.O2(temp1[1]) 
); 

reg [7:0] fsm_leds;
wire lab_choice;
reg choice = 0;


always @(posedge CLKOUT0) begin
  if (deb_btns[4])
    choice = ~choice;
end

always @(*) begin 
  if (choice) 
    fsm_leds <= temp2;
  else 
  begin
    fsm_leds[4:0] <= LED;
    fsm_leds[5] <= temp1[0];
    fsm_leds[6] <= temp1[1];
    fsm_leds[7] <= 1'b0;
  end
end

wire [7:0] data;
   wire wr_en;
   wire show_on_disp;
   lcd162_text lcd162_text_inst (
    .clk(CLKOUT0),
    .i_cnt(LED),
    .i_r_lab2({temp1[1], temp1[0]}),
    .i_st(temp2),
    .data(data),
    .o_data_wr(wr_en),
    .o_show_on_disp(show_on_disp)
   );
   
   
   wire [3:0] lcd; 
   wire lcd_e, lcd_rs, lcd_rw;
   lcd162_st#(.cycles_per_us(86)) lcd162_st_inst
   (
    .clk(CLKOUT0),
    .data(data),
    .data_wr(wr_en),
    .show_on_disp(show_on_disp),
    .D(lcd),
    .E(lcd_e),
    .RS(lcd_rs),
    .RW(lcd_rw)
   );

assign leds = fsm_leds;

   assign LCD_DB4_LS =  lcd[0];
   assign LCD_DB5_LS =  lcd[1];
   assign LCD_DB6_LS =  lcd[2];
   assign LCD_DB7_LS =  lcd[3];
   assign LCD_E_LS =  lcd_e;
   assign LCD_RS_LS =  lcd_rs;
   assign LCD_RW_LS =  lcd_rw;

endmodule 

module counter(
    input CLKOUT0,
    output [4:0] out_c,
    output slow_clk
);
    reg [27:0] cnt = 0;
    reg [27:0] cnt_4 = 0;
    reg [4:0] cnt_2 = 0;
    reg cnt_3 = 0;

    always @(posedge CLKOUT0) begin
        if (cnt == 86000000) begin
              cnt <= 0;
              cnt_2 <= cnt_2 + 1;
        end
        else cnt <= cnt + 1;
        if (cnt_4 == 8600000) begin
          cnt_4 <= 0;
          cnt_3 <= ~cnt_3;
        end 
        else cnt_4 <= cnt_4 + 1;
    end
assign out_c = cnt_2;
assign slow_clk = cnt_3;
endmodule

module main_lab1( 
    input X, Y, Z, K, L,
    output O1, O2
    ); 
    assign O1 = X && (!Y) && Z && (K ^ L); 
    parameter I0 = 4'ha; 
    parameter I1 = 4'hc; 
     
    wire O_LUT1, O_LUT2, O_LUT3; 
     
    LUT2 #( 
      .INIT(I0 ^ I1)  // Specify LUT Contents 
    ) LUT1_inst ( 
      .O(O_LUT1),   // LUT general output 
      .I0(K), // LUT input 
      .I1(L)  // LUT input 
    ); 
     
    LUT2 #( 
      .INIT(I0 & (~I1))  // Specify LUT Contents 
    ) LUT2_inst ( 
      .O(O_LUT2),   // LUT general output 
      .I0(X), // LUT input 
      .I1(Y)  // LUT input 
    ); 
     
    LUT2 #( 
      .INIT(I0 & I1)  // Specify LUT Contents 
    ) LUT3_inst ( 
      .O(O_LUT3),   // LUT general output 
      .I0(O_LUT2), // LUT input 
      .I1(Z)  // LUT input 
    ); 
     
    LUT2 #( 
      .INIT(I0 & I1)  // Specify LUT Contents 
) LUT4_inst ( 
.O(O2),   
// LUT general output 
.I0(O_LUT3), // LUT input 
.I1(O_LUT1)  // LUT input 
); 
endmodule


module debounce (
  input clk,
  input slow_clk,
  input [4:0] btns,
  output [4:0] deb_btns
);

    reg [4:0] r_btn_reg = 0;
    reg [4:0] r_btn1_reg = 0;
    reg [4:0] r_btn2_reg = 0;
    reg r_slow_clk;
    
    always @(posedge clk)
    begin
        r_slow_clk <= slow_clk;
        if ((r_slow_clk ^ slow_clk) & (slow_clk == 1'b1))
        begin
            r_btn_reg <= btns;
            r_btn1_reg <= r_btn_reg; 
        end
        r_btn2_reg <= r_btn1_reg;
    end 
    assign deb_btns = r_btn1_reg & ~r_btn2_reg;
endmodule


module fsm (
  input [3:0] btns,
  input clk,
  output [7:0] led
);

  parameter state0 = 8'b00001111;
  parameter state1 = 8'b11110000;
  parameter state2 = 8'b10101010;
  parameter state3 = 8'b11100111;
  parameter state4 = 8'b00110011;

  parameter btn1 = 4'b0001;
  parameter btn2 = 4'b0010;
  parameter btn3 = 4'b0100;
  parameter btn4 = 4'b1000;
  parameter bnt5 = 5'b10000;

  reg[7:0] state_on_leds = state0;
  

  always @(posedge clk) begin
    case (state_on_leds)
      state0: begin
        if (btns == btn1)
          state_on_leds = state1;
      end
      state1: begin
        if (btns == btn2)
          state_on_leds = state2;
      end
      state2: begin
        if (btns == btn2)
          state_on_leds = state3;
      end
      state3: begin
        if (btns == btn1)
          state_on_leds = state1;
        else if (btns == btn3)
          state_on_leds = state4;
        else if (btns == btn4)
          state_on_leds = state0;
      end
      state4: begin 
        if (btns == btn1)
          state_on_leds = state0;
      end
  endcase
  end

assign led = state_on_leds;
endmodule

module lcd162_text(
    input clk,
    input [4:0] i_cnt,
    input i_r_lab2,
    input [7:0] i_st,
    output [7:0] data,
    output o_data_wr,
    output o_show_on_disp
    );
    reg [7:0] text_buf [31:0];
    reg [4:0] text_index = 0;
    
    reg data_wr_reg = 0;
    reg show_on_disp_reg = 0;
    
    initial begin
        text_buf[0] <= " ";
        text_buf[1] <= " ";
        text_buf[2] <= " ";
        text_buf[3] <= " ";
        
        text_buf[4] <= " ";
        text_buf[5] <= " ";
        text_buf[6] <= " ";
        text_buf[7] <= " ";
        
        text_buf[8] <= " ";
        text_buf[9] <= " ";
        text_buf[10] <= " ";
        text_buf[11] <= " ";
        
        text_buf[12] <= " ";
        text_buf[13] <= " ";
        text_buf[14] <= " ";
        text_buf[15] <= " ";
        
        text_buf[16] <= " ";
        text_buf[17] <= " ";
        text_buf[18] <= " ";
        text_buf[19] <= " ";
        
        text_buf[20] <= " ";
        text_buf[21] <= " ";
        text_buf[22] <= " ";
        text_buf[23] <= " ";
        
        text_buf[24] <= " ";
        text_buf[25] <= " ";
        text_buf[26] <= " ";
        text_buf[27] <= " ";
        
        text_buf[28] <= " ";
        text_buf[29] <= " ";
        text_buf[30] <= " ";
        text_buf[31] <= " ";     
    end
    reg [7:0] name_buf [15:0];
    reg [3:0] cur_char = 0;
    reg [4:0] num_symbol = 15; 
    
    initial begin
        name_buf[0] <= "A";
        name_buf[1] <= "B";
        name_buf[2] <= "C";
        name_buf[3] <= "D";
        
        name_buf[4] <= "E";
        name_buf[5] <= "F";
        name_buf[6] <= "G";
        name_buf[7] <= "H";
        
        name_buf[8] <= "I";
        name_buf[9] <= "J";
        name_buf[10] <= "K";
        name_buf[11] <= "L";
        
        name_buf[12] <= "1";
        name_buf[13] <= "2";
        name_buf[14] <= "3";
        name_buf[15] <= "4";
    end
    
    parameter S_WAIT = 0;
    parameter S_WR = 1;
    parameter S_UPD = 2;
    parameter S_PAUSE = 3;
    reg [1:0] cur_st = S_PAUSE;
    reg [31:0] r_wait = 0;
    
    assign data = text_buf[text_index];
    assign o_show_on_disp = (cur_st == 2);
    assign o_data_wr = (cur_st == 1);
    
    always @(posedge clk) begin 
        case(cur_st)
            S_WAIT:
            begin
                show_on_disp_reg <= 0;
                data_wr_reg <= 1;
                cur_st <= S_WR;
            end
            S_WR:
            begin
                if (text_index == 31) 
                begin
                    if (num_symbol == 15)
                        num_symbol <=0;
                    else
                        num_symbol <= num_symbol + 1;
                    data_wr_reg <= 0;
                    show_on_disp_reg <= 1;
                    text_index <= 0;
                    cur_st <= S_UPD;
                end
                else
                    text_index <= text_index + 1;  
            end
            S_UPD:
            begin
                //first line
                text_buf[0] <= "S";
                text_buf[1] <= "T";
                text_buf[2] <= ":";
                case (i_st)                        
                    8'b00001111: text_buf[3] <= "1"; 
                    8'b11110000: text_buf[3] <= "2"; 
                    8'b10101010: text_buf[3] <= "3"; 
                    8'b11100111: text_buf[3] <= "4"; 
                    8'b00110011: text_buf[3] <= "5"; 
                    
                    default: text_buf[3] <= " ";
                endcase
                text_buf[4] <= " ";
                text_buf[5] <= "L";
                text_buf[6] <= "2";
                text_buf[7] <= ":";
                text_buf[8] <= i_r_lab2 + 48;
                text_buf[9] <= " ";
                text_buf[10] <= "C";
                text_buf[11] <= "N";
                text_buf[12] <= "T";
                text_buf[13] <= ":";    
                if (i_cnt < 10) begin
                    text_buf[14] <= "0";
                    text_buf[15] <= i_cnt + 48; // add zero
                end else begin
                    text_buf[14] <= (i_cnt / 10) + 48; // first
                    text_buf[15] <= (i_cnt % 10) + 48; // second
                end
                //second line 
                 
                text_buf[16] <= (num_symbol >= 0) ? name_buf[0] : " ";
                text_buf[17] <= (num_symbol >= 1) ? name_buf[1] : " ";
                text_buf[18] <= (num_symbol >= 2) ? name_buf[2] : " ";
                text_buf[19] <= (num_symbol >= 3) ? name_buf[3] : " ";
                
                text_buf[20] <= (num_symbol >= 4) ? name_buf[4] : " ";
                text_buf[21] <= (num_symbol >= 5) ? name_buf[5] : " "; 
                text_buf[22] <= (num_symbol >= 6) ? name_buf[6] : " ";
                text_buf[23] <= (num_symbol >= 7) ? name_buf[7] : " ";
                
                text_buf[24] <= (num_symbol >= 8) ? name_buf[8] : " ";
                text_buf[25] <= (num_symbol >= 9) ? name_buf[9] : " "; 
                text_buf[26] <= (num_symbol >= 10) ? name_buf[10] : " ";
                text_buf[27] <= (num_symbol >= 11) ? name_buf[11] : " ";
                
                text_buf[28] <= (num_symbol >= 12) ? name_buf[12] : " ";
                text_buf[29] <= (num_symbol >= 13) ? name_buf[13] : " "; 
                text_buf[30] <= (num_symbol >= 14) ? name_buf[14] : " ";
                text_buf[31] <= (num_symbol >= 15) ? name_buf[15] : " ";
                
                cur_st <= S_PAUSE;
            end
            S_PAUSE:
            begin
                if(r_wait == 86000000/2) 
                begin
                    r_wait <= 0;
                    cur_st <= S_WAIT;
                 end
                 else
                    r_wait <= r_wait + 1;
            end
        endcase
    end    
endmodule