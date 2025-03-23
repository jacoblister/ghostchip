module ram(
  input  clk,    
  input  [11:0] addr,    
  input  [7:0] din,    
  input  we,
  output reg [7:0] dout
  );
 
  reg [7:0] mem [0:4095]; 
  
  always @(posedge clk) begin
    if (we)        
      mem[addr] <= din;    
    
    dout <= mem[addr];    
  end
endmodule