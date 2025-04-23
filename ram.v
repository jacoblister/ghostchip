module ram(
  input  clk,    
  input  [11:0] addr,    
  input  [7:0] din,    
  input  we,
  output [7:0] dout
  );
 
  reg [7:0] font [0:511];
  reg [7:0] dout_font;
  reg [7:0] mem [0:4095];
  reg [7:0] dout_mem;
  
  always @(posedge clk) begin
    if (we)
      mem[addr] <= din;   
    
    dout_mem <= mem[addr];   
  end

  always @(posedge clk) begin
    dout_font <= font[addr[8:0]];  
  end
  
  assign dout = addr < 512 ? dout_font : dout_mem;

  initial begin
    font[0] = 8'hf0; font[1] = 8'h90; font[2] = 8'h90; font[3] = 8'h90; font[4] = 8'hf0;
    font[5] = 8'h20; font[6] = 8'h60; font[7] = 8'h20; font[8] = 8'h20; font[9] = 8'h70;
    font[10] = 8'hf0; font[11] = 8'h10; font[12] = 8'hf0; font[13] = 8'h80; font[14] = 8'hf0;
    font[15] = 8'hf0; font[16] = 8'h10; font[17] = 8'hf0; font[18] = 8'h10; font[19] = 8'hf0;
    font[20] = 8'h90; font[21] = 8'h90; font[22] = 8'hf0; font[23] = 8'h10; font[24] = 8'h10;
    font[25] = 8'hf0; font[26] = 8'h80; font[27] = 8'hf0; font[28] = 8'h10; font[29] = 8'hf0;
    font[30] = 8'hf0; font[31] = 8'h80; font[32] = 8'hf0; font[33] = 8'h90; font[34] = 8'hf0;
    font[35] = 8'hf0; font[36] = 8'h10; font[37] = 8'h20; font[38] = 8'h40; font[39] = 8'h40;
    font[40] = 8'hf0; font[41] = 8'h90; font[42] = 8'hf0; font[43] = 8'h90; font[44] = 8'hf0;
    font[45] = 8'hf0; font[46] = 8'h90; font[47] = 8'hf0; font[48] = 8'h10; font[49] = 8'hf0;
    font[50] = 8'hf0; font[51] = 8'h90; font[52] = 8'hf0; font[53] = 8'h90; font[54] = 8'h90;
    font[55] = 8'he0; font[56] = 8'h90; font[57] = 8'he0; font[58] = 8'h90; font[59] = 8'he0;
    font[60] = 8'hf0; font[61] = 8'h80; font[62] = 8'h80; font[63] = 8'h80; font[64] = 8'hf0;
    font[65] = 8'he0; font[66] = 8'h90; font[67] = 8'h90; font[68] = 8'h90; font[69] = 8'he0;
    font[70] = 8'hf0; font[71] = 8'h80; font[72] = 8'hf0; font[73] = 8'h80; font[74] = 8'hf0;
    font[75] = 8'hf0; font[76] = 8'h80; font[77] = 8'hf0; font[78] = 8'h80; font[79] = 8'h80;
  end
endmodule