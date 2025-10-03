module rbank (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        wr_en_i,
  input  logic [4:0]  rd_reg_a_i,
  input  logic [4:0]  rd_reg_b_i,
  input  logic [4:0]  wr_reg_i,
  input  logic [31:0] wr_data_i,
  output logic [31:0] reg_a_data_o,
  output logic [31:0] reg_b_data_o
);

  logic [31:0] regs[31:0];

  always_ff @(posedge clk_i or negedge rst_i) begin : flops
    if (!rst_i) begin
      for (int i = 0; i < 32; ++i) begin
        regs[i] <= i;
      end
    end else if (wr_en_i) begin
      regs[wr_reg_i] <= wr_data_i;
    end
  end

  assign reg_a_data_o = regs[rd_reg_a_i];
  assign reg_b_data_o = regs[rd_reg_b_i];

  initial begin
    $readmemh("init_regs.hex", regs);
  end

endmodule
