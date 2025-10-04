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

  logic [ADDR_WIDTH-1:0] pc_d, pc_q;
  logic [INSTR_WIDTH-1:0] instruction;

  logic [DATA_WIDTH-1:0] reg_a_data, reg_b_data;
  logic [DATA_WIDTH-1:0] result_alu;
  logic [DATA_WIDTH-1:0] data_from_mem;
  logic [DATA_WIDTH-1:0] data_to_reg;
  
  logic reg_wr_en;

  imem #(
    .MEM_SIZE      (MEM_SIZE   ),
    .ADDR_WIDTH    (ADDR_WIDTH ),
    .DATA_WIDTH    (INSTR_WIDTH)
  ) imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  // For the current ISA, only stores do not write into the register bank
  assign reg_wr_en = instruction[3:0] != 4'b0010;
 
  // Only loads write data from memory into the register bank
  assign data_to_reg = instruction[3:0] == 4'b0001 ? data_from_mem : result_alu;

  // TODO: populate correctly with the proper wires
  rbank #(
    .DATA_WIDTH (DATA_WIDTH)
   ) rbank (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    .wr_en_i      (reg_wr_en),
    .rd_reg_a_i   (instruction[18:14]),
    .rd_reg_b_i   (instruction[13:9]),
    .wr_reg_i     (instruction[8:4]),
    .wr_data_i    (data_to_reg),
    .reg_a_data_o (reg_a_data),
    .reg_b_data_o (reg_b_data)
  );

  // TODO: populate correctly with the proper wires
  dmem #(
    .MEM_SIZE   (MEM_SIZE  ),
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH)
  ) dmem (
    .clk_i     (clk_i),
    .rst_i     (rst_i),
    .wr_en_i   (0),
    .addr_i    (result_alu),
    .wr_data_i (0),
    .rd_data_o (data_from_mem)
  );

  // TODO: populate correctly with the proper wires
  alu #(
    .OPCODE_WIDTH (OPCODE_WIDTH),
    .DATA_WIDTH   (DATA_WIDTH  )
  ) alu (
    .op_i     (instruction[3:0]),
    .a_i      (reg_a_data),
    .b_i      (reg_b_data),
    .result_o (result_alu)
  );

  always_ff @(posedge clk_i) begin : flops
    if (!rst_i) begin
      pc_q <= 0;
    end else begin
      pc_q <= pc_d;
    end
  end

  assign pc_d = (pc_q + 1) % MEM_SIZE;

endmodule
