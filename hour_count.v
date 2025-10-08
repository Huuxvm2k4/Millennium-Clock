module hour_counter(
    input clk_1s,           
    input rstn,          
    input enable,
    input set_enable,            
    input set_mode,         // Chế độ setting
    input inc,              // Tăng giá trị (trong chế độ setting)
    input dec,              // Giảm giá trị (trong chế độ setting)
    output [3:0] hour_tens,   
    output [3:0] hour_units,  
    output reg hour_done      
);
reg [5:0] hour;
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 

assign hour_tens = (hour >= 20)? 2 : ((hour >= 10) ? 1 :0);
assign hour_units = hour - (hour_tens * 10);

wire tick = (!set_enable) ? enable : (inc_pulse | dec_pulse);

always @(posedge enable or negedge rstn) begin
    if (!rstn) begin
        hour_done <= 0;
    end else begin
        hour_done <= (hour == 23 && clk_1s);
    end
end

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        hour <= 0;
    end else if (set_enable && set_mode) begin
        // Chế độ setting
        if (inc_pulse) begin
            hour <= (hour >= 23) ? 0 : hour + 1;
        end else if (dec_pulse) begin
            hour <= (hour == 0) ? 23 : hour - 1;
        end
    end else if (!set_enable) begin
        // Chế độ đếm bình thường
        if (hour >= 23) begin
            hour <= 0;
        end else begin
            hour <= hour + 1;
        end
    end
end

endmodule