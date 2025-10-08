`include "imem.sv"
`include "rbank.sv"
`include "dmem.sv"
`include "alu.sv"

import params_pkg::*;

module cpu (
  input logic clk_i,
  input logic rst_i
);

  // PC wires
  logic [ADDR_WIDTH-1:0] pc_d, pc_q;
  logic [ADDR_WIDTH-1:0] pc_plus_one, pc_plus_offset, pc_added;
  logic is_zero, is_less;
  logic branch_taken;

  // Instruction wires
  instruction_t instruction;
  logic [DATA_WIDTH-1:0] offset_sign_extend;
  logic is_branch, is_jump;
  logic is_load, is_store;

  // ALU wires
  logic [DATA_WIDTH-1:0] reg_a_data, reg_b_data;
  logic [DATA_WIDTH-1:0] data_a_to_alu;
  logic [DATA_WIDTH-1:0] result_alu;

  logic [DATA_WIDTH-1:0] data_from_mem;
  logic [DATA_WIDTH-1:0] data_to_reg;

  logic [REGISTER_WIDTH-1:0] reg_a;
  
  logic reg_wr_en;

  assign is_branch = (instruction.opcode == BEQ) | (instruction.opcode == BNE) | (instruction.opcode == BLT) | (instruction.opcode == BGE);
  assign is_jump = instruction.opcode == JMP;
  assign is_load = instruction.opcode == LW;
  assign is_store = instruction.opcode == SW;

  assign branch_taken = ((instruction.opcode == BEQ) & is_zero) | ((instruction.opcode == BNE) & ~is_zero) |
                        ((instruction.opcode == BLT) & is_less) | ((instruction.opcode == BGE) & ~is_less);
 
  assign pc_plus_one = (pc_q + 1) % MEM_SIZE;
  assign pc_plus_offset = (pc_q + {instruction.free, instruction.rd}) % MEM_SIZE;
  assign pc_added = branch_taken ? pc_plus_offset : pc_plus_one;
  assign pc_d = is_jump ? reg_a_data : pc_added;

  // Data a from register bank must be rd data for stores
  assign reg_a = is_store ? instruction.rd : instruction.ra;

  assign reg_wr_en = ~is_store & ~is_branch & ~is_jump;

  assign offset_sign_extend = {{DATA_WIDTH-(INSTR_WIDTH-14){instruction[INSTR_WIDTH-1]}}, instruction[INSTR_WIDTH-1:14]}; 
 
  // Data a for the ALU is the offset sign extended for both load and store instructions
  assign data_a_to_alu = (is_load | is_store) ? offset_sign_extend : reg_a_data;

  // Only loads write data from memory into the register bank
  assign data_to_reg = is_load ? data_from_mem : result_alu;

  imem #(
    .MEM_SIZE      (MEM_SIZE   ),
    .ADDR_WIDTH    (ADDR_WIDTH ),
    .DATA_WIDTH    (INSTR_WIDTH)
  ) imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  rbank #(
    .REGISTER_WIDTH (REGISTER_WIDTH),
    .DATA_WIDTH     (DATA_WIDTH)
   ) rbank (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .wr_en_i      (reg_wr_en),
    .rd_reg_a_i   (reg_a),
    .rd_reg_b_i   (instruction.rb),
    .wr_reg_i     (instruction.rd),
    .wr_data_i    (data_to_reg),
    .reg_a_data_o (reg_a_data),
    .reg_b_data_o (reg_b_data)
  );

  dmem #(
    .MEM_SIZE   (MEM_SIZE  ),
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
  ) dmem (
    .clk_i     (clk_i),
    .rst_i     (rst_i),
    .wr_en_i   (is_store),
    .addr_i    (result_alu),
    .wr_data_i (reg_a_data),
    .rd_data_o (data_from_mem)
  );

  alu #(
    .OPCODE_WIDTH (OPCODE_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH  )
  ) alu (
    .op_i      (instruction.opcode),
    .a_i       (data_a_to_alu),
    .b_i       (reg_b_data),
    .is_zero_o (is_zero),
    .is_less_o (is_less),
    .result_o  (result_alu)
  );

  always_ff @(posedge clk_i) begin : flops
    if (!rst_i) begin
      pc_q <= 0;
    end else begin
      pc_q <= pc_d;
    end
  end

endmodule
