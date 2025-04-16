module rom(
  input  clk,        
  input  [11:0] addr,    
  output reg [7:0] dout
  );
  
  reg [7:0] mem [0:4095];
  
  always @(posedge clk) begin
    dout <= mem[addr];
  end
  
  initial begin
//    ram[0] = 2'b00; ram[1] = 2'b00; ram[2] = 2'b00; ram[3] = 2'b00; ram[4] = 2'b00; ram[5] = 2'b00;
//    integer x;
//    for (x=0; x < 256; x=x+1)
//      mem[x] = 8'h00;
//    for (x=256; x < 512; x=x+1)
//      mem[x] = 8'h55;
//    for (x=512; x < 768; x=x+1)
//      mem[x] = 8'hAA;
//    for (x=768; x < 1024; x=x+1)
//      mem[x] = 8'hFF;

//    for (x=0; x < 1024; x=x+1)
//      mem[x] = 8'h00;

    mem[0] = 8'hC8;
    mem[1] = 8'h84;
    mem[64] = 8'h80;
    mem[128] = 8'h80;
    mem[192] = 8'h40;
    mem[1855] = 8'h04;
    mem[1919] = 8'h08;
    mem[1983] = 8'h08;
    mem[2046] = 8'h48;
    mem[2047] = 8'h8C;
//    $readmemh("pokemon.hex", mem);
//    $readmemh("cubes.hex", mem);
//    $readmemh("flags.hex", mem);
    $readmemh("keypad.hex", mem);
  end  
endmodule