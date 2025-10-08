module day_counter(
    input clk_1s,           
    input rstn,         
    input enable,
    input set_enable,            
    input set_mode,        
    input inc,              
    input dec,              
    input [3:0] month,     
    input [11:0] year,       
    output [3:0] day_tens,  
    output [3:0] day_units, 
    output reg day_done        
);

reg [4:0] day;
reg [4:0] days_in_month;
reg is_leap;
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 

// assign is_leap = (year[1:0] == 0);
assign day_tens = (day >= 30) ? 3 : ((day >= 20) ? 2 : ((day >= 10) ? 1 :0));
assign day_units = day - day_tens * 10;

wire tick = (!set_mode) ? enable : (inc_pulse | dec_pulse);

// Kiểm tra năm nhuận
// Năm chia hết cho 4 nhưng không chia hết cho 100.
// Hoặc năm chia hết cho 400.
always @(year) begin
    if (year >= 2000 && year <= 2999) begin
        case (year)
            2000, 2400, 2800: is_leap = 1; // Chia hết cho 400
            2100, 2200, 2300, 2500, 2600, 2700, 2900: is_leap = 0; // Chia hết cho 100 nhưng không chia hết cho 400
            default: begin
                is_leap = (year[1:0] == 0);
            end
        endcase
    end
    else begin
        is_leap = 0;
    end
end

// Tinh ngay trong thang
always @(month, is_leap) begin
    days_in_month = 31;
    case (month)
        1, 3, 5, 7, 8, 10, 12: days_in_month = 31;
        4, 6, 9, 11: days_in_month = 30;
        2: days_in_month = is_leap ? 29 : 28;
        default: days_in_month = 31;
    endcase
end

always @(posedge enable or negedge rstn) begin
    if (!rstn) begin
        day_done <= 0;
    end else begin
        day_done <= (day == days_in_month && clk_1s);
    end
end

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        day <= 1;
    end else if (set_enable && set_mode) begin
        // Chế độ setting
        if (inc_pulse) begin
            day <= (day >= days_in_month) ? 1 : day + 1;
        end else if (dec_pulse) begin
            day <= (day == 1) ? days_in_month : day - 1;
        end
    end else if (!set_enable) begin
        if (day == days_in_month) begin
            day <= 1;
        end else begin
            day <= day + 1;
        end
    end
end


endmodule