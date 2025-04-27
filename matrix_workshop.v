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
  assign matrix[4'h5] = switches_p2[2];
  assign matrix[4'h6] = 0;
  assign matrix[4'h7] = switches_p2[0];

  assign matrix[4'h8] = switches_p2[3];
  assign matrix[4'h9] = switches_p2[1];
  assign matrix[4'hA] = 0;
  assign matrix[4'hB] = 0;

  assign matrix[4'hC] = switches_p1[2];
  assign matrix[4'hD] = switches_p1[3];
  assign matrix[4'hE] = 0;
  assign matrix[4'hF] = switches_p1[0];
endmodule