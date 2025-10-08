module year_counter(
    input clk_1s,             
    input rstn,         
    input enable,
    input set_enable,           
    input set_mode,         
    input inc,              
    input dec,              
    output reg [11:0] year, 
    output [3:0] year_thousands,  
    output [3:0] year_hundreds,   
    output [3:0] year_tens,       
    output [3:0] year_units       
);
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 
wire tick = set_enable ? (inc_pulse | dec_pulse) : enable;

assign year_thousands = 4'd2;  
// assign year_hundreds = 4'd0;   
// assign year_tens = (year >= 2090) ? 9 :
//                    (year >= 2080) ? 8 :
//                    (year >= 2070) ? 7 :
//                    (year >= 2060) ? 6 :
//                    (year >= 2050) ? 5 :
//                    (year >= 2040) ? 4 :
//                    (year >= 2030) ? 3 :
//                    (year >= 2020) ? 2 : 0;
// assign year_units = year - ((year_tens * 10) + 2000);

// Tram
wire [9:0] hundreds = year - 2000;
assign year_hundreds =     (hundreds >= 900) ? 9 :
                           (hundreds >= 800) ? 8 :
                           (hundreds >= 700) ? 7 :
                           (hundreds >= 600) ? 6 :
                           (hundreds >= 500) ? 5 :
                           (hundreds >= 400) ? 4 :
                           (hundreds >= 300) ? 3 :
                           (hundreds >= 200) ? 2 :
                           (hundreds >= 100) ? 1 : 0;
// Chuc
wire [9:0] tens = hundreds - (year_hundreds * 100);
assign year_tens =     (tens >= 90) ? 9 :
                       (tens >= 80) ? 8 :
                       (tens >= 70) ? 7 :
                       (tens >= 60) ? 6 :
                       (tens >= 50) ? 5 :
                       (tens >= 40) ? 4 :
                       (tens >= 30) ? 3 :
                       (tens >= 20) ? 2 :
                       (tens >= 10) ? 1 : 0;
// Don vi
assign year_units = tens - year_tens * 10;

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        year <= 2025;
    end else if (set_enable && set_mode) begin
        // Chế độ setting
        if (inc_pulse) begin
            year <= (year >= 2999) ? 2025 : year + 1; 
        end else if (dec_pulse) begin
            year <= (year == 2025) ? 2999 : year - 1; 
        end
    end else if (!set_mode && !set_enable) begin
        // Chế độ đếm bình thường
        if (year >= 2999) begin
            year <= 2025; 
        end else begin
            year <= year + 1;
        end
    end
end
endmodule