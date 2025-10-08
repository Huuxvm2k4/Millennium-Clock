module minute_counter(
    input clk_1s,           
    input rstn,          
    input enable, 
    input set_enable,          
    input set_mode,         // Chế độ setting
    input inc,              // Tăng giá trị (trong chế độ setting)
    input dec,              // Giảm giá trị (trong chế độ setting)
    output [3:0] minute_tens,   
    output [3:0] minute_units,  
    output reg minute_done      
);
reg [5:0] minute;
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 

assign minute_tens = (minute >=50) ? 5 : ((minute >= 40) ? 4 :((minute >= 30) ? 3 :((minute >= 20)? 2 : ((minute >= 10) ? 1 :0))));
assign minute_units = minute - (minute_tens * 10);

wire tick = (!set_enable) ? enable : (inc_pulse | dec_pulse);

always @(posedge enable or negedge rstn) begin
    if (!rstn) begin
        minute_done <= 0;
    end else begin
        minute_done <= (minute == 59 && clk_1s);
    end
end

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        minute <= 0;
    end else if (set_enable && set_mode) begin
        // Chế độ setting
        if (inc_pulse) begin
            minute <= (minute >= 59) ? 0 : minute + 1;
        end else if (dec_pulse) begin
            minute <= (minute == 0) ? 59 : minute - 1;
        end
    end else if (!set_mode && !set_enable) begin
        if (minute == 59) begin
            minute <= 0;
        end else begin
            minute <= minute + 1;
        end
    end
end

endmodule


