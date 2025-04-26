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
//   $readmemh("pokemon.hex", mem);
//   $readmemh("cubes.hex", mem);
//   $readmemh("flags.hex", mem);
//   $readmemh("keypad.hex", mem);
//   $readmemh("beep.hex", mem);
//   $readmemh("random.hex", mem);
//   $readmemh("pong.hex", mem);
//   $readmemh("snake.hex", mem);
//   $readmemh("blinky.hex", mem);
//   $readmemh("down8.hex", mem);

//   $readmemh("rockto.hex", mem);
   $readmemh("chipcross.hex", mem);
  end  
endmodule