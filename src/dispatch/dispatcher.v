module dispatcher(
input [3:0] length [3:0],
input [63:0] inst [19:0],
output [63:0] long [3:0][3:0]
);

integer i;
integer j;

wire [4:0] len [3:0];

initial begin
  for (i = 0; i < 4; i = i + 1) begin
    len[i] = 0;
  end
end

always @(*) begin
  long[0][0] = inst[0];
  long[0][1] = inst[1];
  long[0][2] = inst[2];
  long[0][3] = inst[3];

  for (i = 0; i < 3; i = i + 1) begin
    len[i + 1] = len[i] + length[i];
    long[i + 1][0] = inst[len[i + 1]];
    long[i + 1][1] = inst[len[i + 1] + 1];
    long[i + 1][2] = inst[len[i + 1] + 2];
    long[i + 1][3] = inst[len[i + 1] + 3];
  end
end

endmodule
