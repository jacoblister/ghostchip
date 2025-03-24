module vdrive_workshop(
  input [8:0] hvsync_hpos,
  input [8:0] hvsync_vpos,
  output [1:0] hvsync_pixel,
  
  output [6:0] vram_hpos,
  output [5:0] vram_vpos,
  input [1:0] vram_pixel
  );
  
//  assign vram_hpos = hvsync_hpos[6:0];
//  assign vram_vpos = hvsync_vpos[5:0];
//  assign hvsync_pixel = hvsync_hpos < 128 & hvsync_vpos < 64 ? vram_pixel : 0;

  assign vram_hpos = hvsync_hpos[7:1];
  assign vram_vpos = hvsync_vpos[6:1];
  assign hvsync_pixel = hvsync_hpos < 256 & hvsync_vpos < 128 ? vram_pixel : 0;

endmodule