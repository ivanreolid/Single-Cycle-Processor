`include "cpu.sv"

import params_pkg::*;

module test;
  localparam MEM_SIZE = 4096;

  logic clk;
  logic rst;

  logic [31:0] debug_regs [0:31];
  logic [31:0] model_regs [0:31];

  instruction_t model_instr;

  cpu i_cpu (
    .clk_i (clk),
    .rst_i (rst),
    .debug_regs_o (debug_regs)
  );

  initial begin
    for (int i = 0; i < 32; ++i) begin
      model_regs[i] = i;
    end
    
    clk = 1;
    rst = 0;

    #5 clk = 0;
    #5 clk = 1; rst = 1;

    for (int i = 0; i < 20; ++i) begin
      #5 clk = 1;
      for (int i = 0; i < 32; ++i) begin
        if (model_regs[i] != debug_regs[i]) begin
          $display("Register mismatch! Model register %0d=%0d, CPU register %0d=%0d", i, model_regs[i], i, debug_regs[i]);
          $finish;
        end
      end
      #5 clk = 0;
    end
  end
  
endmodule
