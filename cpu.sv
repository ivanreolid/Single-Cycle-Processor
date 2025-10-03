`include "imem.sv"
`include "rbank.sv"
`include "dmem.sv"

module cpu #(
  parameter MEM_SIZE = 4096
)(
  input logic clk_i,
  input logic rst_i
);

  localparam INSTR_WIDTH = 32;
  localparam ADDR_WIDTH  = 32;
  localparam DATA_WIDTH  = 32;

  logic [ADDR_WIDTH-1:0] pc_d, pc_q;
  logic [INSTR_WIDTH-1:0] instruction;

  logic [DATA_WIDTH-1:0] reg_a_data, reg_b_data;

  imem #(
    .MEM_SIZE      (MEM_SIZE   ),
    .ADDR_WIDTH    (ADDR_WIDTH ),
    .DATA_WIDTH    (INSTR_WIDTH)
  ) imem (
    .address_i     (pc_q       ),
    .instruction_o (instruction)
  );

  // TODO: populate correctly with the proper wires
  rbank #(
    .DATA_WIDTH (DATA_WIDTH)
   ) rbank (
    .clk_i       (clk_i),
    .rst_i       (rst_i),
    .wr_en_i     (1'b0),
    .rd_reg_a_i  (2),
    .rd_reg_b_i  (3),
    .wr_reg_i    (0),
    .wr_data_i   (0),
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
    .addr_i    (0),
    .wr_data_i (0),
    .rd_data_o ()
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
