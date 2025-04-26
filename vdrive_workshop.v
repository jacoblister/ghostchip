module vdrive_workshop(
  input hires,
  input [8:0] hvsync_hpos,
  input [8:0] hvsync_vpos,
  output [1:0] hvsync_pixel,
  
  output [6:0] vram_hpos,
  output [5:0] vram_vpos,
  input [1:0] vram_pixel
  );
  
  assign vram_hpos = hires ? hvsync_hpos[7:1] : hvsync_hpos[8:2];
  assign vram_vpos = hires ? hvsync_vpos[6:1] : hvsync_vpos[7:2];
  assign hvsync_pixel = hvsync_hpos < 256 & hvsync_vpos < 128 ? vram_pixel : 0;

endmodule