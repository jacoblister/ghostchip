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
   $readmemh("pong.hex", mem);
  end  
endmodule