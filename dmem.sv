module dmem #(
  parameter MEM_SIZE = 4096,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic clk_i,
  input  logic rst_i,
  input  logic wr_en_i,
  input  logic [ADDR_WIDTH-1:0] addr_i,
  input  logic [DATA_WIDTH-1:0] wr_data_i,
  output logic [DATA_WIDTH-1:0] rd_data_o
);

  logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

  always_ff @(posedge clk_i) begin : flops
    if (!rst_i) begin
      for (int i = 0; i < MEM_SIZE; ++i) begin
        mem[i] <= i;       
      end
    end else if (wr_en_i) begin
      mem[addr_i] <= wr_data_i;
    end
  end

  assign rd_data_o = mem[addr_i];
  
endmodule
