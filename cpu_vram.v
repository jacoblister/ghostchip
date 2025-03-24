module cpu_vram(
  input clk,
  input [15:0] keypad_matrix,
  output [11:0] rom_addr,
  input [7:0] rom_dout,
  output [11:0] ram_addr,
  output [7:0] ram_din,
  input [7:0] ram_dout,
  output ram_we,
  output [6:0] vram_hpos,
  output [5:0] vram_vpos,
  output [1:0] vram_pixeli,
  input [1:0] vram_pixelo,
  output vram_we
  );
  
  reg [1:0] state = 0;
  reg [12:0] counter = 0;
  
//  assign rom_addr = counter;
  assign vram_hpos = counter[12:6];
  assign vram_vpos = counter[5:0];
//  assign vram_pixeli = counter < 4096 ? (counter < 2048 ? 0 : 1) : (counter < 6144 ? 2 : 3);  
//  assign vram_pixeli = (counter == 0 || counter == 126) ? 3 : 2;
  wire [2:0] vram_pixel_index = 7 - {counter[1:0], 1'b0};
  assign vram_pixeli = {rom_dout[vram_pixel_index], rom_dout[vram_pixel_index-1]};
  
  //assign vram_we = state != 2;
  assign vram_we = state == 1;
  assign rom_addr = {1'b00, counter[12:2]};
  
  always @(posedge clk)
  begin
    if (state == 0)
      begin
        state <= 1;
      end
    
    if (state == 1)
      begin
        if (counter == 8191) 
          state <= 2;
        else
          begin
            counter <= counter + 1;
            state <= 0;
          end
      end
    
//    if (counter == 8191) 
//      state <= 2;
//    else
//      counter <= counter + 1;
  end  
    
  
  assign ram_addr = 0;
  assign ram_din = 0;
  assign ram_we = 0;
//  assign rom_addr = 0;
  
//  assign vram_hpos = 0;
//  assign vram_vpos = 0;
//  assign vram_pixeli = 0;
//  assign vram_we = 0;
endmodule