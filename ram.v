module ram(
  input  clk,    
  input  [11:0] addr,    
  input  [7:0] din,    
  input  we,
  output [7:0] dout
  );
 
  reg [7:0] mem [0:4095];
  reg [7:0] dout_mem;
  
  always @(posedge clk) begin
    if (we)
      mem[addr] <= din;   
    
    dout_mem <= mem[addr];   
  end
  
  assign dout = dout_mem;
endmodule