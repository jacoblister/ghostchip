module keyread(
  input clk,
  input [15:0] keypad_matrix,
  output reg trigger,
  output reg [3:0] index
  );
  
  reg pressed;
  
  always @(posedge clk)
  begin
    pressed <= keypad_matrix != 0;
    
    if (keypad_matrix[0]) index <= 0;
    if (keypad_matrix[1]) index <= 1;
    if (keypad_matrix[2]) index <= 2;
    if (keypad_matrix[3]) index <= 3;
    if (keypad_matrix[4]) index <= 4;
    if (keypad_matrix[5]) index <= 5;
    if (keypad_matrix[6]) index <= 6;
    if (keypad_matrix[7]) index <= 7;
    if (keypad_matrix[8]) index <= 8;
    if (keypad_matrix[9]) index <= 9;
    if (keypad_matrix[10]) index <= 10;
    if (keypad_matrix[11]) index <= 11;
    if (keypad_matrix[12]) index <= 12;
    if (keypad_matrix[13]) index <= 13;
    if (keypad_matrix[14]) index <= 14;
    if (keypad_matrix[15]) index <= 15;
    
    trigger <= pressed && keypad_matrix == 0;
  end  
endmodule

module cpu(
  input clk,
  input vsync,
  output beep,
  output reg hires = 0,
  input [15:0] keypad_matrix,
  output [15:0] rom_addr,
  input [7:0] rom_dout,
  input rom_dready,
  output [15:0] ram_addr,
  output [7:0] ram_din,
  input [7:0] ram_dout,
  output ram_we,
  output [6:0] vram_hpos,
  output [5:0] vram_vpos,
  output [1:0] vram_pixeli,
  input [1:0] vram_pixelo,
  output vram_we
  );
  
  assign beep = reg_st != 0;
  
  wire keypad_trigger;
  wire [3:0] keypad_index;
  keyread keyread(
    .clk(vsync),
    .keypad_matrix(keypad_matrix),
    .trigger(keypad_trigger),
    .index(keypad_index)
  );
  
  parameter CPU_INIT     = 0;
  parameter CPU_MEMORY   = 1;
  parameter CPU_FETCH    = 2;
  parameter CPU_EXEC     = 3;
  parameter CPU_CLEAR    = 4;
  parameter CPU_DRAW     = 5;
  parameter CPU_KEYPRESS = 6;
  parameter CPU_WAIT     = 7;
  parameter CPU_IDLE     = 8;
  
  parameter MEM_ROM = 0;
  parameter MEM_RAM = 1;
  parameter MEM_REG = 2;
  parameter MEM_BCD = 3;
  parameter MEM_IR  = 4;
  parameter MEM_RPL = 5;
  parameter MEM_I   = 6;
  
  reg [15:0] reg_pc;
  reg [15:0] reg_i;
  reg [7:0] reg_vr [16];
  reg [15:0] reg_stack [8];
  reg [7:0] reg_rpl [8];
  reg [2:0] reg_sp;
  reg [15:0] reg_ir;
  reg [7:0] reg_dt;
  reg [7:0] reg_st;
  reg [7:0] reg_rng;
    
  reg [15:0] cpu_limit = 0;
    
  reg [3:0] state = CPU_INIT;
  reg [2:0] mem_from;
  reg [15:0] mem_from_index = 0;
  reg [2:0] mem_to;
  reg [15:0] mem_to_index = 0;
  reg [15:0] mem_count;
  reg mem_delay_cycle = 0;

  parameter DRAW_CLEAR     = 0;
  parameter DRAW_SPRITE_8  = 1;
  parameter DRAW_SPRITE_16 = 2;
  reg [1:0] draw_op;
  reg [12:0] draw_i = 0;
  reg [12:0] draw_n = 0;
  reg [11:0] draw_count = 0;
  reg [6:0] draw_x = 0;
  reg [5:0] draw_y = 0;
  assign vram_hpos = 
    draw_op == DRAW_CLEAR ? draw_i[6:0] :
    draw_op == DRAW_SPRITE_8 ? draw_x + {4'h0, draw_i[2:0]} :
    draw_op == DRAW_SPRITE_16 ? draw_x + {3'h0, draw_i[3:0]} :
    0;
  assign vram_vpos = 
    draw_op == DRAW_CLEAR ? draw_i[12:7] :
    draw_op == DRAW_SPRITE_8 ? draw_y + draw_i[8:3] :
    draw_op == DRAW_SPRITE_16 ? draw_y + draw_i[8:4] :
    0;
  
  parameter DRAW_PLANE_CLONE = 0;
  parameter DRAW_PLANE_0     = 1;
  parameter DRAW_PLANE_1     = 2;
  parameter DRAW_PLANE_0_1   = 3;
  
  reg [1:0] draw_plane_mode = DRAW_PLANE_CLONE;
  reg draw_plane = 0;
  wire draw_plane_0 = !draw_plane || draw_plane_mode == DRAW_PLANE_CLONE;
  wire draw_plane_1 = draw_plane || draw_plane_mode == DRAW_PLANE_CLONE;
  
  assign vram_we = state == CPU_CLEAR || (state == CPU_DRAW && mem_delay_cycle == 0);
  wire[2:0] vram_ram_index = 7 - draw_i[2:0];

  assign vram_pixeli = 
    state == CPU_DRAW ? 
      ((ram_dout[vram_ram_index] & draw_plane_0) ^ vram_pixelo[0] ? 1 : 0) |
      ((ram_dout[vram_ram_index] & draw_plane_1) ^ vram_pixelo[1] ? 2 : 0) :
    state == CPU_CLEAR ? 0 :
    0;

  wire [7:0] data = 
    mem_from == MEM_RAM ? ram_dout : 
    mem_from == MEM_ROM ? rom_dout : 
    mem_from == MEM_REG ? reg_vr[mem_from_index[3:0]] :
    mem_from == MEM_BCD && mem_from_index == 0 ? reg_vr[reg_ir[11:8]] / 100 :
    mem_from == MEM_BCD && mem_from_index == 1 ? (reg_vr[reg_ir[11:8]] / 10) % 10:
    mem_from == MEM_BCD && mem_from_index == 2 ? (reg_vr[reg_ir[11:8]] % 100) % 10 :
    mem_from == MEM_IR && mem_from_index == 0 ? reg_ir[15:8] :
    mem_from == MEM_IR && mem_from_index == 1 ? reg_ir[7:0] :
    mem_from == MEM_RPL ? reg_rpl[mem_from_index[2:0]] :
    0;
  assign ram_addr =  
    mem_from == MEM_RAM ? mem_from_index : 
    mem_to == MEM_RAM ? mem_to_index :
    0;
  assign rom_addr =  
    mem_from == MEM_ROM ? mem_from_index : 
    mem_to == MEM_ROM ? mem_to_index :
    0;
  assign ram_din = data;
  assign ram_we = mem_to == MEM_RAM;
  
  reg last_vsync;
  
  always @(posedge clk)
  begin
    reg_rng <= reg_rng + 1;
    
    last_vsync <= vsync;
    if (vsync && last_vsync != vsync)
      begin
      if (reg_dt > 0)
        reg_dt <= reg_dt - 1;
      if (reg_st > 0)
        reg_st <= reg_st - 1;
      if (state == CPU_WAIT)
        cpu_limit <= 400;
        state <= CPU_MEMORY;
      end
    
    case (state)
      CPU_INIT: begin
        draw_i <= 0;
        draw_n <= 13'h1fff;
        draw_op <= DRAW_CLEAR;

        mem_from <= MEM_ROM;
        mem_from_index <= 0;
        mem_to <= MEM_RAM;
        mem_to_index <= 16'h0000;
        mem_count <= 16'h3FFF;
        mem_delay_cycle <= 0;
        
        reg_vr[4'h0] <= 0;
        reg_vr[4'h1] <= 0;
        reg_vr[4'h2] <= 0;
        reg_vr[4'h3] <= 0;
        reg_vr[4'h4] <= 0;
        reg_vr[4'h5] <= 0;
        reg_vr[4'h6] <= 0;
        reg_vr[4'h7] <= 0;
        reg_vr[4'h8] <= 0;
        reg_vr[4'h9] <= 0;
        reg_vr[4'ha] <= 0;
        reg_vr[4'hb] <= 0;
        reg_vr[4'hc] <= 0;
        reg_vr[4'hd] <= 0;
        reg_vr[4'he] <= 0;
        reg_vr[4'hf] <= 0;

        reg_sp <= 0;
        reg_pc <= 16'h0200;
       
        state <= CPU_MEMORY;
      end
      CPU_MEMORY: begin
        if (mem_from != MEM_ROM || rom_dready)
          begin
          if (mem_to == MEM_IR && mem_to_index == 0) 
            reg_ir[15:8] <= data;
          if (mem_to == MEM_IR && mem_to_index == 1) 
            reg_ir[7:0] <= data;
          if (mem_to == MEM_I && mem_to_index == 0) 
            reg_i[15:8] <= data;
          if (mem_to == MEM_I && mem_to_index == 1) 
            reg_i[7:0] <= data;
          if (mem_to == MEM_REG)
            reg_vr[mem_to_index[3:0]] <= data;
          if (mem_to == MEM_RPL)
            reg_rpl[mem_to_index[2:0]] <= data;
        
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
              state <= 
                mem_to == MEM_IR ? CPU_EXEC :
                mem_from == MEM_ROM ? CPU_CLEAR :
                CPU_FETCH;
          end
      end
      CPU_FETCH: begin
        mem_from <= MEM_RAM;
        mem_from_index <= reg_pc;
        mem_to <= MEM_IR;
        mem_to_index <= 0;
        mem_count <= 2;
        mem_delay_cycle <= 1;
        reg_pc <= reg_pc + 2;

        if (cpu_limit == 0)
          state <= CPU_WAIT;
        else
          begin
          cpu_limit <= cpu_limit - 1;
          state <= CPU_MEMORY;
          end;
      end
      CPU_EXEC: begin
        if (reg_ir == 16'h00e0)
          begin
          draw_i <= 0;
          draw_n <= 13'h1fff;
          draw_op <= DRAW_CLEAR;
          state <= CPU_CLEAR;
          end
        else if (reg_ir == 16'h00ee)
          begin
          reg_pc <= reg_stack[reg_sp - 1];
          reg_sp <= reg_sp - 1;
          state <= CPU_FETCH;
          end
        else if (reg_ir == 16'h00fe)
          begin
          hires <= 0;
          state <= CPU_FETCH;
          end
        else if (reg_ir == 16'h00ff)
          begin
          hires <= 1;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h1)
          begin
          reg_pc <= {4'h0, reg_ir[11:0]};
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h2)
          begin
          reg_stack[reg_sp] <= reg_pc;
          reg_pc <= {4'h0, reg_ir[11:0]};
          reg_sp <= reg_sp + 1;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h3)
          begin
          if (reg_vr[reg_ir[11:8]] == reg_ir[7:0])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h4)
          begin
          if (reg_vr[reg_ir[11:8]] != reg_ir[7:0])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h5 && reg_ir[3:0] == 4'h0)
          begin
          if (reg_vr[reg_ir[11:8]] == reg_vr[reg_ir[7:4]])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h5 && reg_ir[3:0] == 4'h02)
          begin
          if (reg_ir[11:8] > reg_ir[7:4])
            state <= CPU_IDLE;
          else
            begin
            mem_count <= {12'h00, reg_ir[7:4] - reg_ir[11:8]};
            mem_from <= MEM_REG;
            mem_from_index <= {12'h0, reg_ir[11:8]};
            mem_to <= MEM_RAM;
            mem_to_index <= reg_i;
            mem_delay_cycle <= 0;
            state <= CPU_MEMORY;
            end
          end
        else if (reg_ir[15:12] == 4'h5 && reg_ir[3:0] == 4'h03)
          begin
          if (reg_ir[11:8] > reg_ir[7:4])
            state <= CPU_IDLE;
          else
            begin
            mem_count <= {12'h00, reg_ir[7:4] - reg_ir[11:8]};
            mem_from <= MEM_RAM;
            mem_from_index <= reg_i;
            mem_to <= MEM_REG;
            mem_to_index <= {12'h0, reg_ir[11:8]};
            mem_delay_cycle <= 1;
            state <= CPU_MEMORY;
            end
          end
        else if (reg_ir[15:12] == 4'h6)
          begin
          reg_vr[reg_ir[11:8]] <= reg_ir[7:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h7)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] + reg_ir[7:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h0)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h1)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] | reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h2)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] & reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h3)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] ^ reg_vr[reg_ir[7:4]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h4)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] + reg_vr[reg_ir[7:4]];
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]] + reg_vr[reg_ir[7:4]] > 255 ? 8'h01 : 8'h00;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h5)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] - reg_vr[reg_ir[7:4]];
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]] < reg_vr[reg_ir[7:4]] ? 8'h00 : 8'h01;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h6)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] >> 1;
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]][0] ? 8'h01 : 8'h00;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'h7)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[7:4]] - reg_vr[reg_ir[11:8]];
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]] > reg_vr[reg_ir[7:4]] ? 8'h00 : 8'h01;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h8 && reg_ir[3:0] == 4'hE)
          begin
          reg_vr[reg_ir[11:8]] <= reg_vr[reg_ir[11:8]] << 1;
          reg_vr[4'hf] <= reg_vr[reg_ir[11:8]][7] ? 8'h01 : 8'h00;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'h9)
          begin
            if (reg_vr[reg_ir[11:8]] != reg_vr[reg_ir[7:4]])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hA)
          begin
          reg_i <= {4'h0, reg_ir[11:0]};
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hB)
          begin
          reg_pc <= {4'h0, reg_ir[11:0]} + {8'h0, reg_vr[0]};
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hC)
          begin
          reg_vr[reg_ir[11:8]] <= reg_rng & reg_ir[7:0];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hD)
          begin
          reg_vr[4'hf] <= 0;
          draw_x <= reg_vr[reg_ir[11:8]][6:0];
          draw_y <= reg_vr[reg_ir[7:4]][5:0];
          draw_i <= 0;
          draw_n <= {6'h0, reg_ir[3:0], 3'h0} - 1;
          mem_from <= MEM_RAM;
          mem_from_index <= reg_i;
          mem_delay_cycle <= 1;
          draw_op <= DRAW_SPRITE_8;
          state <= CPU_DRAW;
          
          if (reg_ir[3:0] == 0)
            begin
              draw_op <= DRAW_SPRITE_16;
              draw_n <= (16 * 16) - 1;
            end
          draw_plane <= draw_plane_mode == DRAW_PLANE_1;
          end
        else if (reg_ir[15:12] == 4'hE && reg_ir[7:0] == 8'h9E)
          begin
          if (keypad_matrix[reg_vr[reg_ir[11:8]][3:0]])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hE && reg_ir[7:0] == 8'hA1)
          begin
          if (!keypad_matrix[reg_vr[reg_ir[11:8]][3:0]])
            reg_pc <= reg_pc + 2;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:0] == 16'hF000)
          begin
          mem_from <= MEM_RAM;
          mem_from_index <= reg_pc;
          mem_to <= MEM_I;
          mem_to_index <= 0;
          mem_count <= 2;
          mem_delay_cycle <= 1;
          reg_pc <= reg_pc + 2;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h01)
          begin
          draw_plane_mode <= reg_ir[9:8];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h02)
          begin
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h07)
          begin
          reg_vr[reg_ir[11:8]] <= reg_dt;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h0A)
          begin
          state <= CPU_KEYPRESS;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h15)
          begin
          reg_dt <= reg_vr[reg_ir[11:8]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h18)
          begin
          reg_st <= reg_vr[reg_ir[11:8]];
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h1E)
          begin
          reg_i <= reg_i + {8'h00, reg_vr[reg_ir[11:8]]};
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h29)
          begin
          reg_i <= reg_vr[reg_ir[11:8]] * 5;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h30)
          begin
          reg_i <= 80 + reg_vr[reg_ir[11:8]] * 10;
          state <= CPU_FETCH;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h33)
          begin
          mem_from <= MEM_BCD;
          mem_count <= 2;
          mem_from_index <= 0;
          mem_to <= MEM_RAM;
          mem_to_index <= reg_i;
          mem_delay_cycle <= 0;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h55)
          begin
          reg_i <= reg_i + {12'h00, reg_ir[11:8]} + 1;
          mem_count <= {12'h00, reg_ir[11:8]};
          mem_from <= MEM_REG;
          mem_from_index <= 0;
          mem_to <= MEM_RAM;
          mem_to_index <= reg_i;
          mem_delay_cycle <= 0;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h65)
          begin
          reg_i <= reg_i + {12'h00, reg_ir[11:8]} + 1;
          mem_count <= {12'h00, reg_ir[11:8]};
          mem_from <= MEM_RAM;
          mem_from_index <= reg_i;
          mem_to <= MEM_REG;
          mem_to_index <= 0;
          mem_delay_cycle <= 1;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h75)
          begin
          mem_count <= {12'h00, reg_ir[11:8]};
          mem_from <= MEM_REG;
          mem_from_index <= 0;
          mem_to <= MEM_RPL;
          mem_to_index <= 0;
          mem_delay_cycle <= 0;
          state <= CPU_MEMORY;
          end
        else if (reg_ir[15:12] == 4'hF && reg_ir[7:0] == 8'h85)
          begin
          mem_count <= {12'h00, reg_ir[11:8]};
          mem_from <= MEM_RPL;
          mem_from_index <= 0;
          mem_to <= MEM_REG;
          mem_to_index <= 0;
          mem_delay_cycle <= 0;
          state <= CPU_MEMORY;
          end
        else 
          state <= CPU_IDLE;
      end
      CPU_CLEAR: begin
        draw_i <= draw_i + 1;
        if (draw_i == draw_n)
          state <= CPU_FETCH;
      end
      CPU_DRAW: begin
        if (mem_delay_cycle)
          begin
          mem_delay_cycle <= 0;
          end
        else
          begin
            mem_delay_cycle <= 1;
            reg_vr[4'hf] <= vram_pixelo[draw_plane] && ram_dout[vram_ram_index[2:0]] ? 1 : reg_vr[4'hf];
          
            draw_i <= draw_i + 1;
            if (draw_i[2:0] == 7)
              begin
                mem_from_index <= mem_from_index + 1;
              end
            
            if (draw_i == draw_n)
              begin
                if (draw_plane_mode == DRAW_PLANE_0_1 && !draw_plane)
                  begin
                    draw_plane <= 1;
                        draw_x <= reg_vr[reg_ir[11:8]][6:0];
                    draw_y <= reg_vr[reg_ir[7:4]][5:0];
                    draw_i <= 0;
                    state <= CPU_DRAW;
                  end
                else 
                  state <= CPU_FETCH;
              end
          end
        end
      CPU_KEYPRESS: begin
        if (keypad_trigger)
          begin
            reg_vr[reg_ir[11:8]] <= {4'h00, keypad_index};
            state <= CPU_FETCH;
          end
      end
      CPU_IDLE: begin
      end
    endcase
  end  
endmodule