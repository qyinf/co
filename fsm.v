`define s0 3'd0
`define s1 3'd1
`define s2 3'd2
`define s3 3'd3
`define s4 3'd4
`define s5 3'd5
module BlockChecker(
    input clk,
    input reset,
    input[7:0] in,
    output result
);
    wire[7:0] a;
    reg has_space;
    reg[2:0] status1;
    reg[2:0] status2;
    reg[31:0] begin_num = 0;
    reg[31:0] last;
    reg trigger;
    assign a = (in >= "A" && in <= "Z") ? in-"A"+"a" : in;
    assign result = ($signed(begin_num) == 0)? 1 : 0; 
    // assign result = (stk == 0 && has_end == 1)? 1 : 0;
    always@(posedge clk or posedge reset)begin
        if(reset == 1)begin
            status1 <= `s0;
            status2 <= `s0;
            begin_num <= 0;
            trigger <= 0;
            has_space <= 0;
            last <= 0;
        end
        else begin
            if(a >= "a" && a <= "z")trigger <= 1;
            if(a == " ")has_space <= 1;
            last <= begin_num;
            case(status1)
            `s0:begin
                if(a == "b")begin
                    if(has_space)begin
                        status1 <= `s1;
                        has_space <= 0;
                    end
                    else if(trigger == 0)status1 <= `s1;
                    else status1 <= `s0;
                end
                else begin
                    status1 <= `s0;
                    if(a >= "a" && a <= "z")has_space <= 0;
                end
            end
            `s1:begin
                if(a == "e")status1 <= `s2;
                else status1 <= `s0;
            end
            `s2:begin
                if(a == "g")status1 <= `s3;
                else status1 <= `s0;
            end
            `s3:begin
                if(a == "i")status1 <= `s4;
                else status1 <= `s0;
            end
            `s4:begin
                if(a == "n")begin
                    status1 <= `s5;
                    if($signed(begin_num) >= 0)begin_num <= begin_num + 1;
                    else begin_num <= begin_num;
                end
                else status1 <= `s0;
            end
            `s5:begin
                status1 <= `s0;
                if(a == " ")begin_num <= begin_num;
                else begin
                    if($signed(begin_num) >= 0)begin_num<= begin_num - 1;
                    else begin_num <= begin_num;
                end
            end
            endcase
            case(status2)
            `s0:begin
                if(a == "e")begin
                    if(has_space)begin
                        status2 <= `s1;
                        has_space <= 0;
                    end
                    else if(trigger == 0)status2 <= `s1;
                    else status2 <= `s0;
                end
                else begin
                    status2 <= `s0;
                    if(a>= "a" && a <= "z")has_space <= 0;
                end
            end
            `s1:begin
                if(a == "n")status2 <= `s2;
                else status2 <= `s0;
            end
            `s2:begin
                if(a == "d")begin
                    status2 <= `s3;
                    begin_num <= begin_num - 1;
                end
                else status2 <= `s0;
            end
            `s3:begin
                status2 <= `s0;
                if(a == " ") begin_num <= begin_num;
                else begin_num <= begin_num + 1;
            end
			endcase
        end
    end
endmodule