`include "cpu.sv"

import params_pkg::*;

module test;
  localparam MEM_SIZE = 4096;

  logic clk;
  logic rst;

  logic [ADDR_WIDTH-1:0] model_pc, new_model_pc;

  logic [DATA_WIDTH-1:0] dut_dmem [0:MEM_SIZE-1];
  logic [DATA_WIDTH-1:0] debug_regs [0:31];
  
  logic [DATA_WIDTH-1:0] model_regs [0:31];
  logic [DATA_WIDTH-1:0] model_imem [0:MEM_SIZE-1];
  logic [DATA_WIDTH-1:0] model_dmem [0:MEM_SIZE-1];

  logic dut_instr_is_committed;
  instruction_t model_instr, dut_instr_committed;

  logic [DATA_WIDTH-1:0] offset_sign_extend;

  logic [ADDR_WIDTH-1:0] pc_plus_offset;

  cpu i_cpu (
    .clk_i (clk),
    .rst_i (rst),
    .dut_dmem_o (dut_dmem),
    .debug_regs_o (debug_regs),
    .instr_committed_o (dut_instr_committed),
    .instr_is_committed_o (dut_instr_is_committed)
  );

  initial begin
    model_pc = 0;

    for (int i = 0; i < 32; ++i) begin
      model_regs[i] = i;
    end
    
    for (int i = 0; i < MEM_SIZE; ++i) begin
      model_imem[i] = i * 100;
      model_dmem[i] = i;
    end
    
    model_imem[1] = 32'h4470;      // ADD r1, r2 -> r7
    model_imem[2] = 32'h40B23;     // SUB r6, r5 -> r18
    model_imem[3] = 32'h446F1;     // LW @17(r3) -> r15
    model_imem[4] = 32'hFFFE1981;  // LW @-17(r12) -> r24
    model_imem[5] = 32'h36212;     // SW r1 -> @13(r17)
    model_imem[6] = 32'hFFFF50E2;  // SW r14 -> @-3(r8)
    model_imem[7] = 32'hA0DF9;     // BEQ r16, r6, 63
    model_imem[8] = 32'h98DF9;     // BEQ r6, r6, 63
    model_imem[61] = 32'h427A;     // BNE r1, r1, 3
    model_imem[62] = 32'h4CAA;     // BNE r1, r6, 10
    model_imem[71] = 32'hFFF98D69; // BEQ r6, r6, -10
    model_imem[72] = 32'h390AB;    // BLT r14, r8, 10
    model_imem[73] = 32'h21CAB;    // BLT r8, r14, 10
    model_imem[83] = 32'h6BEAC;    // BGE r26, r31, 10
    model_imem[84] = 32'h7F4AC;    // BGE r31, r26, 10
    model_imem[94] = 32'h7800D;    // JMP r30

    clk = 1;
    rst = 0;

    #5 clk = 0;
    #5 clk = 1; rst = 1;
    #5 clk = 0;

    for (int i = 0; i < 20; ++i) begin
      #5 clk = 1;
      
      if (dut_instr_is_committed) begin
        model_instr = model_imem[model_pc];
        new_model_pc = (model_pc + 1) % MEM_SIZE;
        offset_sign_extend = {{(DATA_WIDTH-(INSTR_WIDTH-14)){model_instr[INSTR_WIDTH-1]}}, model_instr[INSTR_WIDTH-1:14]};
        pc_plus_offset = (model_pc + {model_instr.free, model_instr.rd}) % MEM_SIZE;

        // Check committed instruction
        if (model_instr != dut_instr_committed) begin
          $display("Committed instruction mismatch! Model committed instruction=0x%0h, DUT committed instruction=0x%0h", model_instr, dut_instr_committed);
        end

        // Execute the commit instruction in the model
        case (model_instr.opcode)
          ADD: model_regs[model_instr.rd] = model_regs[model_instr.ra] + model_regs[model_instr.rb]; 
          LW:  model_regs[model_instr.rd] = model_dmem[offset_sign_extend + model_instr.rb];
          SW:  model_dmem[offset_sign_extend + model_instr.rb] = model_instr.rd;
          SUB: model_regs[model_instr.rd] = model_regs[model_instr.ra] - model_regs[model_instr.rb];
          AND: model_regs[model_instr.rd] = model_regs[model_instr.ra] & model_regs[model_instr.rb];
          MUL: model_regs[model_instr.rd] = model_regs[model_instr.ra] * model_regs[model_instr.rb];
          DIV: model_regs[model_instr.rd] = model_regs[model_instr.ra] / model_regs[model_instr.rb];
          OR:  model_regs[model_instr.rd] = model_regs[model_instr.ra] | model_regs[model_instr.rb];
          XOR: model_regs[model_instr.rd] = model_regs[model_instr.ra] ^ model_regs[model_instr.rb];
          BEQ: new_model_pc = model_regs[model_instr.ra] == model_regs[model_instr.rb] ? pc_plus_offset : new_model_pc;
          BNE: new_model_pc = model_regs[model_instr.ra] != model_regs[model_instr.rb] ? pc_plus_offset : new_model_pc;
          BLT: new_model_pc = model_regs[model_instr.ra] < model_regs[model_instr.rb]  ? pc_plus_offset : new_model_pc;
          BGE: new_model_pc = model_regs[model_instr.ra] >= model_regs[model_instr.rb] ? pc_plus_offset : new_model_pc;
          JMP: new_model_pc = model_regs[model_instr.ra];
          //default:
        endcase

      end

      // Check registers
      for (int i = 0; i < 32; ++i) begin
        if (model_regs[i] != debug_regs[i]) begin
          $display("Register mismatch! Model register %0d=%0d, CPU register %0d=%0d", i, model_regs[i], i, debug_regs[i]);
        end
      end

      // Check data memory
      for (int i = 0; i < MEM_SIZE; ++i) begin
        if (model_dmem[i] != dut_dmem[i]) begin
          $display("Data memory mismatch! Model dmem @0x%0h=0x%0h, DUT dmem @0x%0h=0x%0h", i, model_dmem[i], i, dut_dmem[i]); 
        end
      end

      #5 clk = 0;
      model_pc = new_model_pc;
    end
  end
  
endmodule
