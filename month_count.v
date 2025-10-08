module month_counter(
    input clk_1s,              
    input rstn,          
    input enable,
    input set_enable,           
    input set_mode,         
    input inc,              
    input dec,             
    output reg [3:0] month, 
    output [3:0] month_tens,    
    output [3:0] month_units,  
    output reg month_done       
);
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 

// assign month_done = (month == 12) && !set_enable;
assign month_tens = (month >= 10) ? 1 : 0;
assign month_units = month - month_tens * 10;

wire tick = (!set_enable) ? enable : (inc_pulse | dec_pulse);

always @(posedge enable or negedge rstn) begin
    if (!rstn) begin
        month_done <= 0;
    end else begin
        month_done <= (month == 12 && clk_1s);
    end
end

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        month <= 1;
    end else if (set_enable && set_mode) begin
        // Chế độ setting
        if (inc_pulse) begin
            month <= (month >= 12) ? 1 : month + 1;
        end else if (dec_pulse) begin
            month <= (month <= 1) ? 12 : month - 1;
        end
    end else if (!set_enable) begin
        if (month == 12) begin
            month <= 1;
        end else begin
            month <= month + 1;
        end
    end
end
endmodule