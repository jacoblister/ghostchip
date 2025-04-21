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
//    $readmemh("font.hex", font);
    $readmemh("IBMLogo.hex", font);
  end
endmodule