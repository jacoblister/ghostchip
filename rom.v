module rom(
  input  clk,        
  input  [13:0] addr,    
  output reg [7:0] dout,
  output dready
  );
  
  reg [7:0] mem [0:16383];
  reg [13:0] addr_loaded = 14'h2FFF;
  
  always @(posedge clk) begin
    addr_loaded <= addr;
    dout <= mem[addr];
  end
  
  assign dready = addr_loaded == addr;

  initial begin
    parameter MEM_INIT_FILE 
//      = "chip8logo.hex";
//      = "flags.hex";
//      = "quirks.hex";
//      = "keypad.hex";
//      = "beep.hex";
//      = "random.hex";
//      = "pong.hex";
//      = "snake.hex";
//      = "blinky.hex";
//      = "down8.hex";
//      = "rockto.hex";
//      = "chipcross.hex";
//      = "squad.hex";
//      = "dvn8.hex";
      = "octopaint.hex";
//      = "garden.hex";
//      = "expedition.hex";
//      = "garlicscape.hex";
//      = "superneatboy.hex";
//      = "sound.hex";
    
    `ifdef __8BITWORKSHOP__
    integer j;
    for(j = 0; j < 16383; j = j+1) 
      mem[j] = 0;
    
    $readmemh(MEM_INIT_FILE, mem);
    for(j = 16383; j >= 512; j = j-1) 
      mem[j] = mem[j - 512];
    `endif
    
    `ifndef __8BITWORKSHOP__
    $readmemh(MEM_INIT_FILE, mem, 512);
    `endif
    
    mem[00] = 8'hf0; mem[01] = 8'h90; mem[02] = 8'h90; mem[03] = 8'h90; mem[04] = 8'hf0;
    mem[05] = 8'h20; mem[06] = 8'h60; mem[07] = 8'h20; mem[08] = 8'h20; mem[09] = 8'h70;
    mem[10] = 8'hf0; mem[11] = 8'h10; mem[12] = 8'hf0; mem[13] = 8'h80; mem[14] = 8'hf0;
    mem[15] = 8'hf0; mem[16] = 8'h10; mem[17] = 8'hf0; mem[18] = 8'h10; mem[19] = 8'hf0;
    mem[20] = 8'h90; mem[21] = 8'h90; mem[22] = 8'hf0; mem[23] = 8'h10; mem[24] = 8'h10;
    mem[25] = 8'hf0; mem[26] = 8'h80; mem[27] = 8'hf0; mem[28] = 8'h10; mem[29] = 8'hf0;
    mem[30] = 8'hf0; mem[31] = 8'h80; mem[32] = 8'hf0; mem[33] = 8'h90; mem[34] = 8'hf0;
    mem[35] = 8'hf0; mem[36] = 8'h10; mem[37] = 8'h20; mem[38] = 8'h40; mem[39] = 8'h40;
    mem[40] = 8'hf0; mem[41] = 8'h90; mem[42] = 8'hf0; mem[43] = 8'h90; mem[44] = 8'hf0;
    mem[45] = 8'hf0; mem[46] = 8'h90; mem[47] = 8'hf0; mem[48] = 8'h10; mem[49] = 8'hf0;
    mem[50] = 8'hf0; mem[51] = 8'h90; mem[52] = 8'hf0; mem[53] = 8'h90; mem[54] = 8'h90;
    mem[55] = 8'he0; mem[56] = 8'h90; mem[57] = 8'he0; mem[58] = 8'h90; mem[59] = 8'he0;
    mem[60] = 8'hf0; mem[61] = 8'h80; mem[62] = 8'h80; mem[63] = 8'h80; mem[64] = 8'hf0;
    mem[65] = 8'he0; mem[66] = 8'h90; mem[67] = 8'h90; mem[68] = 8'h90; mem[69] = 8'he0;
    mem[70] = 8'hf0; mem[71] = 8'h80; mem[72] = 8'hf0; mem[73] = 8'h80; mem[74] = 8'hf0;
    mem[75] = 8'hf0; mem[76] = 8'h80; mem[77] = 8'hf0; mem[78] = 8'h80; mem[79] = 8'h80;

    mem[080] = 8'hff; mem[081] = 8'hff; mem[082] = 8'hc3; mem[083] = 8'hc3; mem[084] = 8'hc3; mem[085] = 8'hc3; mem[086] = 8'hc3; mem[087] = 8'hcf; mem[088] = 8'hff; mem[089] = 8'hff;
    mem[090] = 8'h0c; mem[091] = 8'h0c; mem[092] = 8'h3c; mem[093] = 8'h3c; mem[094] = 8'h0c; mem[095] = 8'h0c; mem[096] = 8'h0c; mem[097] = 8'h0c; mem[098] = 8'h3f; mem[099] = 8'h3f;
    mem[100] = 8'hff; mem[101] = 8'hff; mem[102] = 8'h03; mem[103] = 8'h03; mem[104] = 8'hff; mem[105] = 8'hff; mem[106] = 8'hc0; mem[107] = 8'hc0; mem[108] = 8'hff; mem[109] = 8'hff;
    mem[110] = 8'hff; mem[111] = 8'hff; mem[112] = 8'h07; mem[113] = 8'h07; mem[114] = 8'hff; mem[115] = 8'hff; mem[116] = 8'h07; mem[117] = 8'h07; mem[118] = 8'hff; mem[119] = 8'hff;
    mem[120] = 8'hc3; mem[121] = 8'hc3; mem[122] = 8'hc3; mem[123] = 8'hff; mem[124] = 8'hff; mem[125] = 8'h03; mem[126] = 8'h03; mem[127] = 8'h03; mem[128] = 8'h03; mem[129] = 8'h03;
    mem[130] = 8'hff; mem[131] = 8'hff; mem[132] = 8'hc0; mem[133] = 8'hc0; mem[134] = 8'hff; mem[135] = 8'hff; mem[136] = 8'h03; mem[137] = 8'h03; mem[138] = 8'hff; mem[139] = 8'hff;
    mem[140] = 8'hff; mem[141] = 8'hff; mem[142] = 8'hc0; mem[143] = 8'hc0; mem[144] = 8'hff; mem[145] = 8'hff; mem[146] = 8'hc3; mem[147] = 8'hc3; mem[148] = 8'hff; mem[149] = 8'hff;
    mem[150] = 8'hff; mem[151] = 8'hff; mem[152] = 8'h03; mem[153] = 8'h03; mem[154] = 8'h0c; mem[155] = 8'h0c; mem[156] = 8'h30; mem[157] = 8'h30; mem[158] = 8'h30; mem[159] = 8'h30;
    mem[160] = 8'hff; mem[161] = 8'hff; mem[162] = 8'hc3; mem[163] = 8'hc3; mem[164] = 8'hff; mem[165] = 8'hff; mem[166] = 8'hc3; mem[167] = 8'hc3; mem[168] = 8'hff; mem[169] = 8'hff;
    mem[170] = 8'hff; mem[171] = 8'hff; mem[172] = 8'hc3; mem[173] = 8'hc3; mem[174] = 8'hff; mem[175] = 8'hff; mem[176] = 8'h03; mem[177] = 8'h03; mem[178] = 8'hff; mem[179] = 8'hff;

    mem[180] = 8'hff; mem[181] = 8'hff; mem[182] = 8'hc3; mem[183] = 8'hc3; mem[184] = 8'hff; mem[185] = 8'hff; mem[186] = 8'hc3; mem[187] = 8'hc3; mem[188] = 8'hc3; mem[189] = 8'hc3;
    mem[190] = 8'hfc; mem[191] = 8'hfc; mem[192] = 8'hc3; mem[193] = 8'hc3; mem[194] = 8'hfc; mem[195] = 8'hfc; mem[196] = 8'hc3; mem[197] = 8'hc3; mem[198] = 8'hfc; mem[199] = 8'hfc;
    mem[200] = 8'hff; mem[201] = 8'hff; mem[202] = 8'hc0; mem[203] = 8'hc0; mem[204] = 8'hc0; mem[205] = 8'hc0; mem[206] = 8'hc0; mem[207] = 8'hc0; mem[208] = 8'hff; mem[209] = 8'hff;
    mem[210] = 8'hfc; mem[211] = 8'hfc; mem[212] = 8'hc3; mem[213] = 8'hc3; mem[214] = 8'hc3; mem[215] = 8'hc3; mem[216] = 8'hc3; mem[217] = 8'hc3; mem[218] = 8'hfc; mem[219] = 8'hfc;
    mem[220] = 8'hff; mem[221] = 8'hff; mem[222] = 8'hc0; mem[223] = 8'hc0; mem[224] = 8'hff; mem[225] = 8'hff; mem[226] = 8'hc0; mem[227] = 8'hc0; mem[228] = 8'hff; mem[229] = 8'hff;
    mem[230] = 8'hff; mem[231] = 8'hff; mem[232] = 8'hc0; mem[233] = 8'hc0; mem[234] = 8'hff; mem[235] = 8'hff; mem[236] = 8'hc0; mem[237] = 8'hc0; mem[238] = 8'hc0; mem[239] = 8'hc0;
  end  
endmodule