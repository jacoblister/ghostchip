module matrix_workshop(clk, switches_p1, switches_p2, matrix);
    input clk;
    input [7:0] switches_p1;
    input [7:0] switches_p2;
    output [15:0] matrix;
    
    assign matrix[4'h0] = 0;
    assign matrix[4'h1] = 0;
    assign matrix[4'h2] = 0;
    assign matrix[4'h3] = 0;
  
    assign matrix[4'h4] = 0;
    assign matrix[4'h5] = 0;
    assign matrix[4'h6] = 0;
    assign matrix[4'h7] = 0;
  
    assign matrix[4'h8] = 0;
    assign matrix[4'h9] = 0;
    assign matrix[4'hA] = 0;
    assign matrix[4'hB] = 0;
  
    assign matrix[4'hC] = 0;
    assign matrix[4'hD] = 0;
    assign matrix[4'hE] = 0;
    assign matrix[4'hF] = switches_p1[0];
  endmodule