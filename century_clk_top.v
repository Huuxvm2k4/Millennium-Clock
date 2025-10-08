module century_clock(
    input CLOCK_50,                     
    input [2:0] KEY,        // KEY[0]: chế độ điều chỉnh, KEY[1]: tăng, KEY[2]: giảm
    input [10:0] SW,   

    output [6:0] HEX0,     
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [6:0] HEX6,
    output [6:0] HEX7
);

wire rstn;
wire clk_1s;
wire display;
// wire [7:0] blink_enable;
wire set_enable;

// Set pin FPGA
assign rstn = SW[0]; // Reset
assign display = SW[1]; // Hiển thị hh/mm/ss hoặc dd/mm/yyyy
// assign blink_enable[7:0] = SW[9:2]; // Nháy từng led

assign set_enable = SW[10];

// Tin hieu trung gian
wire sec_done, min_done, hour_done, day_done, month_done;

wire [3:0] month_val;
wire [11:0] year_val;

wire [3:0] sec_tens, sec_units;
wire [3:0] min_tens, min_units;
wire [3:0] hr_tens, hr_units;
wire [3:0] d_tens, d_units;
wire [3:0] mon_tens, mon_units;
wire [3:0] yr_thousands, yr_hundreds, yr_tens, yr_units;

wire [6:0] second_unit;
wire [6:0] second_ten;
wire [6:0] minute_unit;
wire [6:0] minute_ten;
wire [6:0] hour_unit;
wire [6:0] hour_ten;
wire [6:0] day_unit;
wire [6:0] day_ten;
wire [6:0] month_unit;
wire [6:0] month_ten;
wire [6:0] year_unit;
wire [6:0] year_ten;
wire [6:0] year_hundred;
wire [6:0] year_thousand;


reg [25:0] blink_cnt;
reg blink_clk;
reg [2:0] set_mode;     // 1: giây, 2: phút, 3: giờ, 4: ngày, 5: tháng, 6: năm
wire [7:0] blink_signal;
wire [2:0] button;


// Xung clk blink 4Hz
always @(posedge CLOCK_50 or negedge rstn) begin
    if (!rstn) begin
        blink_cnt <= 0;
        blink_clk <= 0;
    end else if (blink_cnt >= 12_499_999) begin 
        blink_cnt <= 0;
        blink_clk <= ~blink_clk;
    end else begin
        blink_cnt <= blink_cnt + 1;
    end
end


assign blink_signal[0] = blink_enable[0] ? blink_clk : 1'b1;  // HEX0
assign blink_signal[1] = blink_enable[1] ? blink_clk : 1'b1;  // HEX1
assign blink_signal[2] = blink_enable[2] ? blink_clk : 1'b1;  // HEX2
assign blink_signal[3] = blink_enable[3] ? blink_clk : 1'b1;  // HEX3
assign blink_signal[4] = blink_enable[4] ? blink_clk : 1'b1;  // HEX4
assign blink_signal[5] = blink_enable[5] ? blink_clk : 1'b1;  // HEX5
assign blink_signal[6] = blink_enable[6] ? blink_clk : 1'b1;  // HEX6
assign blink_signal[7] = blink_enable[7] ? blink_clk : 1'b1;  // HEX7



// debouncing
debounce debounce_inst0 (
    .pb_1(~KEY[0]),
    .clk(CLOCK_50),
    .pb_out(button[0])
);
debounce debounce_inst1 (
    .pb_1(~KEY[1]),
    .clk(CLOCK_50),
    .pb_out(button[1])
);
debounce debounce_inst2 (
    .pb_1(~KEY[2]),
    .clk(CLOCK_50),
    .pb_out(button[2])
);



// // Trong 1 chu ky clk_1s neu co inc/dec thi gia tri se cap nhat tai suon duong clk_1s 
// always @(posedge CLOCK_50 or negedge rstn) begin
//     if (!rstn)
//         inc_pending <= 0;
//     else if (button[1])
//         inc_pending <= 1;          
//     else if (clk_1s)               
//         inc_pending <= 0;
// end

// always @(posedge CLOCK_50 or negedge rstn) begin
//     if (!rstn)
//         dec_pending <= 0;
//     else if (button[2])
//         dec_pending <= 1;          
//     else if (clk_1s)               
//         dec_pending <= 0;
// end

// 1: giây, 2: phút, 3: giờ, 4: ngày, 5: tháng, 6: năm
always @(set_enable, rstn, button[0]) begin
    if (!set_enable | rstn) begin
        set_mode = 1;
    end else begin
        if (button[0]) begin
            set_mode = set_mode + 1;
            if (set_mode == 8) set_mode = 1;
        end
    end
end


clock_1s clock_1s_inst(
    .clk(CLOCK_50),
    .rstn(rstn),
    .clk_1s(clk_1s)
);

second_counter sec_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .set_enable(set_enable),
    .set_mode((set_mode == 2)),
    .inc(button[1]),
    .dec(button[2]),
    .second_tens(sec_tens), 
    .second_units(sec_units),
    .second_done(sec_done)
);

minute_counter min_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .enable(sec_done),
    .set_mode(set_enable && (set_mode == 3)),
    .inc(button[1]),
    .dec(button[2]),
    .minute_tens(min_tens),
    .minute_units(min_units),
    .minute_done(min_done)
);

hour_counter hr_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .enable(min_done),
    .set_mode(set_enable && (set_mode == 4)),
    .inc(button[1]),
    .dec(button[2]),
    .hour_tens(hr_tens),
    .hour_units(hr_units),
    .hour_done(hour_done)
);

day_counter day_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .enable(hour_done),
    .set_mode(set_enable && (set_mode == 5)),
    .inc(button[1]),
    .dec(button[2]),
    .year(year_val),
    .month(month_val),
    .day_tens(d_tens),
    .day_units(d_units),
    .day_done(day_done)
);

month_counter month_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .enable(day_done),
    .set_mode(set_enable && (set_mode == 6)),
    .inc(button[1]),
    .dec(button[2]),
    .month(month_val),
    .month_tens(mon_tens),
    .month_units(mon_units),
    .month_done(month_done)
);

year_counter year_counter_inst(
    .clk_1s(clk_1s),
    .rstn(rstn),
    .enable(month_done),
    .set_mode(set_enable && (set_mode == 7)),
    .inc(button[1]),
    .dec(button[2]),
    .year(year_val),
    .year_thousands(yr_thousands),
    .year_hundreds(yr_hundreds),
    .year_tens(yr_tens),
    .year_units(yr_units)
);


assign HEX0 = blink_signal[0] ? (display ? second_unit : year_unit) : 7'b1111111;
assign HEX1 = blink_signal[1] ? (display ? second_ten : year_ten) : 7'b1111111;
assign HEX2 = blink_signal[2] ? (display ? minute_unit : year_hundred) : 7'b1111111;
assign HEX3 = blink_signal[3] ? (display ? minute_ten : year_thousand) : 7'b1111111;
assign HEX4 = blink_signal[4] ? (display ? hour_unit : month_unit) : 7'b1111111;
assign HEX5 = blink_signal[5] ? (display ? hour_ten : month_ten) : 7'b1111111;
assign HEX6 = blink_signal[6] ? (display ? 7'b1111111 : day_unit) : 7'b1111111;
assign HEX7 = blink_signal[7] ? (display ? 7'b1111111 : day_ten) : 7'b1111111;

BCD_to_7segment dut_seconds_unit(
    .rstn(rstn),
    .bcd(sec_units),
    .seg(second_unit)
);
BCD_to_7segment dut_seconds_ten (
    .rstn(rstn),
    .bcd(sec_tens),
    .seg(second_ten)
);

BCD_to_7segment dut_minutes_unit (
    .rstn(rstn),
    .bcd(min_units),
    .seg(minute_unit)
);

BCD_to_7segment dut_minutes_ten (
    .rstn(rstn),
    .bcd(min_tens),
    .seg(minute_ten)
);

BCD_to_7segment dut_hours_unit (
    .rstn(rstn),
    .bcd(hr_units),
    .seg(hour_unit)
);

BCD_to_7segment dut_hours_ten (
    .rstn(rstn),
    .bcd(hr_tens),
    .seg(hour_ten)
);

BCD_to_7segment dut_days_unit (
    .rstn(rstn),
    .bcd(d_units),
    .seg(day_unit)
);

BCD_to_7segment dut_days_ten (
    .rstn(rstn),
    .bcd(d_tens),
    .seg(day_ten)
);

BCD_to_7segment dut_months_unit (
    .rstn(rstn),
    .bcd(mon_units),
    .seg(month_unit)
);

BCD_to_7segment dut_months_ten (
    .rstn(rstn),
    .bcd(mon_tens),
    .seg(month_ten)
);

BCD_to_7segment dut_years_unit (
    .rstn(rstn),
    .bcd(yr_units),
    .seg(year_unit)
);

BCD_to_7segment dut_years_ten (
    .rstn(rstn),
    .bcd(yr_tens),
    .seg(year_ten)
);

BCD_to_7segment dut_years_hundred (
    .rstn(rstn),
    .bcd(yr_hundreds),
    .seg(year_hundred)
);

BCD_to_7segment dut_years_thousand (
    .rstn(rstn),
    .bcd(yr_thousands),
    .seg(year_thousand)
);

endmodule