module keypad (
    input clk, 
    output out0,
    output out1,
    output out2,
    output out3,
    input in0,
    input in1,
    input in2,
    input in3,
    output reg [15:0] matrix,
    output led0,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6,
    output led7);

    reg [23:0] counter = 0;
    
    always @ (posedge clk) 
    begin
        counter <= counter + 1'b1;
    end
    
    wire [1:0] line;
    assign line = counter[23:22];
    assign out0 = (line == 0);
    assign out1 = (line == 1);
    assign out2 = (line == 2);
    assign out3 = (line == 3);
    assign led0 = line == 0;
    assign led1 = line == 1;
    assign led2 = line == 2;
    assign led3 = line == 3;
    assign led4 = in0;
    assign led5 = in1;
    assign led6 = in2;
    assign led7 = in3;

endmodule