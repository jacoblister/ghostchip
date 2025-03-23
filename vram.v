module vram(
  input clk,
  input [6:0] hpos,
  input [5:0] vpos,
  input [1:0] pixeli,
  output [1:0] pixelo,
  input we,

  input [6:0] vdrive_hpos,
  input [5:0] vdrive_vpos,
  output [1:0] vdrive_pixel
  );
  
  reg [1:0] ram [8191:0];
  reg [1:0] vram_pixel_value;
  reg [1:0] vdrive_pixel_value;
  
  always @(posedge clk) 
  begin
    if (we)
      ram[{hpos, vpos}] <= pixeli;
    
    vram_pixel_value <= ram[{hpos, vpos}];
  end    
  assign pixelo = vram_pixel_value;
  
  always @(posedge clk) 
  begin
    vdrive_pixel_value <= ram[{vdrive_vpos, vdrive_hpos}];
  end    
  assign vdrive_pixel = vdrive_pixel_value;
endmodule