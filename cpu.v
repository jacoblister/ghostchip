module cpu(
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
  
  parameter CPU_INIT   = 0;
  parameter CPU_MEMORY = 1;
  parameter CPU_FETCH  = 2;
  parameter CPU_EXEC   = 3;
  parameter CPU_DRAW   = 4;
  
  reg [3:0] state = CPU_INIT;
  reg [11:0] mem_from_index = 0;
  reg [11:0] mem_to_index = 0;
  reg [11:0] mem_count;
  reg mem_delay_cycle = 0;
  reg mem_is_fetch = 0;

  reg [1:0] draw_state = 0;
  reg [12:0] counter = 0;
  assign vram_hpos = counter[6:0];
  assign vram_vpos = counter[12:7];
  wire [2:0] vram_pixel_index = 7 - {counter[1:0], 1'b0};
  assign vram_pixeli = {ram_dout[vram_pixel_index], ram_dout[vram_pixel_index-1]};
  
  assign vram_we = draw_state == 1;
  assign rom_addr = mem_from_index;
  assign ram_addr = state == CPU_DRAW ? {1'b00, counter[12:2]} : mem_to_index;
  assign ram_din = rom_dout;
  assign ram_we = state == CPU_MEMORY;
 
//  assign rom_addr = {1'b00, counter[12:2]};
//  assign vram_pixeli = {rom_dout[vram_pixel_index], rom_dout[vram_pixel_index-1]};
  
  always @(posedge clk)
  begin
    case (state)
      CPU_INIT: begin
//        mem_from <= MEM_ROM;
        mem_from_index <= 0;
//        mem_to <= MEM_RAM;
        mem_to_index <= 0; //12'h0200;
        mem_count <= 2048;
        mem_delay_cycle <= 1;
        mem_is_fetch <= 0;
        
        state <= CPU_MEMORY;
      end
      CPU_MEMORY: begin
        if (mem_delay_cycle)
        begin
          mem_from_index <= mem_from_index + 1;
          mem_delay_cycle <= 0;
        end
        else
          if (mem_count > 0)
          begin
            mem_from_index <= mem_from_index + 1;
            mem_to_index <= mem_to_index + 1;
            mem_count <= mem_count - 1;
          end
          else
            state <= CPU_DRAW;
      end
      CPU_DRAW: begin
        if (draw_state == 0)
        begin
          draw_state <= 1;
        end
    
        if (draw_state == 1)
        begin
          if (counter == 8191) 
            draw_state <= 2;
          else
            begin
              counter <= counter + 1;
              draw_state <= 0;
            end
          end  
        end
    endcase
  end  
endmodule