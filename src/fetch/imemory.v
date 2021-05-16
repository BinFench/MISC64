module imemory(
  input clock,
  input reset,
  input wire [63:0] address,
  output wire [63:0] data_out [19:0]
);

reg [7:0] mem [`MEM_DEPTH];
reg [63:0] init [`MEM_DEPTH/8:0];
integer i;

initial begin
  // Load program into memory
  $readmemh(`MEM_PATH, init);
  // Reformat memory from longs to bytes
  for (i = 0; i < `MEM_DEPTH/8; i = i + 1) begin
    mem[8*i] = init[i][7:0];
    mem[8*i + 1] = init[i][15:8];
    mem[8*i + 2] = init[i][23:16];
    mem[8*i + 3] = init[i][31:24];
    mem[8*i + 4] = init[i][39:32];
    mem[8*i + 5] = init[i][47:40];
    mem[8*i + 6] = init[i][55:48];
    mem[8*i + 7] = init[i][63:56];
  end
end

always @(*) begin
  // If byte address is within range, output memory.  Otherwise, output 0.
  for (i = 0; i < 20; i = i + 1) begin
    if (address + 8*i < `MEM_DEPTH) begin
      data_out[i][7:0] = mem[address + 8*i];
      if (address + 8*i + 1 < `MEM_DEPTH) begin
	data_out[i][15:8] = mem[address + 8*i + 1];
	if (address + 8*i + 2 < `MEM_DEPTH) begin
	  data_out[i][23:16] = mem[address + 8*i + 2];
	  if (address + 8*i + 3 < `MEM_DEPTH) begin
	    data_out[i][31:24] = mem[address + 8*i + 3];
	    if (address + 8*i + 4 < `MEM_DEPTH) begin
	      data_out[i][39:32] = mem[address + 8*i + 4];
	      if (address + 8*i + 5 < `MEM_DEPTH) begin
	        data_out[i][47:40] = mem[address + 8*i + 5];
		if (address + 8*i + 6 < `MEM_DEPTH) begin
		  data_out[i][55:48] = mem[address + 8*i + 6];
		  if (address + 8*i + 7 < `MEM_DEPTH) begin
		    data_out[i][63:56] = mem[address + 8*i + 7];
		  end else begin
		    data_out[i][63:56] = 0;
		  end
		end else begin
		  data_out[i][63:48] = 0;
		end
	      end else begin
		data_out[i][63:40] = 0;
	      end
	    end else begin
	      data_out[i][63:32] = 0;
	    end
	  end else begin
	    data_out[i][63:24] = 0;
	  end
	end else begin
	  data_out[i][63:16] = 0;
	end
      end else begin
	data_out[i][63:8] = 0;
      end
    end else begin
      data_out[i][63:0] = 0;
    end
  end
end

endmodule
