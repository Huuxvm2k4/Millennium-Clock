module second_counter(
    input clk_1s,            
    input rstn,       
    input set_enable,   
    input set_mode,         
    input inc,              
    input dec,              
    output [3:0] second_tens,   
    output [3:0] second_units,  
    output reg second_done       
);
reg [5:0] second;
wire inc_pulse = (set_mode && inc); 
wire dec_pulse = (set_mode && dec); 

assign second_tens = (second >=50) ? 5 : ((second >= 40) ? 4 :((second >= 30) ? 3 :((second >= 20)? 2 : ((second >= 10) ? 1 :0))));
assign second_units = second - (second_tens * 10);
    
wire tick = (!set_mode) ? clk_1s : (inc_pulse | dec_pulse);

// always @(posedge tick or negedge rstn) begin
//     if (!rstn) begin
//         second <= 0;
//         second_done <= 0;
//     end else if (set_enable && set_mode) begin
//         // Chế độ setting
//         if (inc_pulse) begin
//             second <= (second >= 59) ? 0 : second + 1;  
//         end else if (dec_pulse) begin
//             second <= (second == 0) ? 59 : second - 1;
//         end
//     end else if (!set_enable) begin
//         // Chế độ đếm bình thường
//         if (second == 59) begin
//             second <= 0;
//             second_done <= 1;
//         end else begin
//             second <= second + 1;
//             second_done <= 0;
//         end
//     end
// end
// endmodule

always @(posedge tick or negedge rstn) begin
    if (!rstn) begin
        second <= 0;
        second_done <= 0;
    end else begin
        second_done <= 0; // gán mặc định
        if (set_mode && set_enable) begin
            // Chế độ chỉnh tay
            if (inc_pulse)
                second <= (second == 59) ? 0 : second + 1;
            else if (dec_pulse)
                second <= (second == 0) ? 59 : second - 1;

        end else if (!set_mode && !set_enable) begin
            // Chế độ chạy bình thường
            if (second == 59) begin
                second <= 0;
                second_done <= 1;
            end else begin
                second <= second + 1;
            end
        end
    end
end
endmodule