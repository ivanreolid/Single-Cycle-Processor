`include "imem.sv"
`include "rbank.sv"
`include "dmem.sv"
`include "alu.sv"

module cpu #(
  parameter MEM_SIZE = 4096
)(
  input logic clk_i,
  input logic rst_i
);

  localparam INSTR_WIDTH = 32;
  localparam ADDR_WIDTH  = 32;
  localparam DATA_WIDTH  = 32;
  localparam OPCODE_WIDTH = 4;

  // PC wires
  logic [ADDR_WIDTH-1:0] pc_d, pc_q;
  logic [ADDR_WIDTH-1:0] pc_plus_one, pc_plus_offset;
  logic is_branch;
  logic is_zero;
  logic is_less;
  logic branch_taken;

  // Instruction wires
  logic [INSTR_WIDTH-1:0] instruction;
  logic [DATA_WIDTH-1:0] offset_sign_extend;

  // ALU wires
  logic [DATA_WIDTH-1:0] reg_a_data, reg_b_data;
  logic [DATA_WIDTH-1:0] data_a_to_alu;
  logic [DATA_WIDTH-1:0] result_alu;

  logic [DATA_WIDTH-1:0] data_from_mem;
  logic [DATA_WIDTH-1:0] data_to_reg;

  logic [4:0] reg_a;
  
  logic reg_wr_en;
  logic dmem_wr_en;

  imem #(
    .MEM_SIZE      (MEM_SIZE   ),
    .ADDR_WIDTH    (ADDR_WIDTH ),
    .DATA_WIDTH    (INSTR_WIDTH)
  ) imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  assign pc_plus_one = (pc_q + 1) % MEM_SIZE;
  assign pc_plus_offset = (pc_q + {instruction[31:19], instruction[8:4]}) % MEM_SIZE;
  assign is_branch = (instruction[3:0] == 4'b1001) | (instruction[3:0] == 4'b1010) | (instruction[3:0] == 4'b1011);
  assign branch_taken = ((instruction[3:0] == 4'b1001) & is_zero) | ((instruction[3:0] == 4'b1010) & ~is_zero) |
                        ((instruction[3:0] == 4'b1011) & is_less);
  assign pc_d = branch_taken ? pc_plus_offset : pc_plus_one;

  // Data a from register bank must be rd data for stores
  assign reg_a = instruction[3:0] == 4'b0010 ? instruction[8:4] : instruction[18:14];

  // For the current ISA, only stores write into data memory
  assign dmem_wr_en = instruction[3:0] == 4'b0010;

  assign reg_wr_en = (instruction[3:0] != 4'b0010) & ~is_branch;

  assign offset_sign_extend = {{DATA_WIDTH-(INSTR_WIDTH-14){instruction[INSTR_WIDTH-1]}}, instruction[INSTR_WIDTH-1:14]}; 
 
  // Data a for the ALU is the offset sign extended for both load and store instructions
  assign data_a_to_alu = (instruction[3:0] == 4'b0001 || instruction[3:0] == 4'b0010) ? offset_sign_extend : reg_a_data; 

  // Only loads write data from memory into the register bank
  assign data_to_reg = instruction[3:0] == 4'b0001 ? data_from_mem : result_alu;

  rbank #(
    .DATA_WIDTH (DATA_WIDTH)
   ) rbank (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .wr_en_i      (reg_wr_en),
    .rd_reg_a_i   (reg_a),
    .rd_reg_b_i   (instruction[13:9]),
    .wr_reg_i     (instruction[8:4]),
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
    .wr_en_i   (dmem_wr_en),
    .addr_i    (result_alu),
    .wr_data_i (reg_a_data),
    .rd_data_o (data_from_mem)
  );

  alu #(
    .OPCODE_WIDTH (OPCODE_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH  )
  ) alu (
    .op_i      (instruction[3:0]),
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
