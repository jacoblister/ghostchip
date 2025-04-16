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

    reg [1:0] line = 0;
  
    always @ (posedge clk) 
    begin
      line <= line + 1;
      case(line)
        0: begin
          matrix[4'h1] <= in0;
          matrix[4'h2] <= in1;
          matrix[4'h3] <= in2;
          matrix[4'hC] <= in3;
        end
        1: begin
          matrix[4'h4] <= in0;
          matrix[4'h5] <= in1;
          matrix[4'h6] <= in2;
          matrix[4'hD] <= in3;
        end
        2: begin
          matrix[4'h7] <= in0;
          matrix[4'h8] <= in1;
          matrix[4'h9] <= in2;
          matrix[4'hE] <= in3;
        end
        3: begin
          matrix[4'hA] <= in0;
          matrix[4'h0] <= in1;
          matrix[4'hB] <= in2;
          matrix[4'hF] <= in3;
        end
      endcase
    end
    
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