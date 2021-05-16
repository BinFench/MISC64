module decoder(
  input [63:0] longs [4:0],
  input [63:0] r1,
  input [63:0] r2,
  input [63:0] r3,
  input [63:0] r4,
  input [63:0] rd,
  input pass,
  output valid,
  output [1:0] issue,
  output [4:0] opsel,
  output [3:0] length;
  output [63:0] A,
  output [63:0] B,
  output [63:0] C,
  output [63:0] ejmp,
  output [5:0] rc1,
  output [5:0] rc2,
  output [5:0] re1,
  output [5:0] re2,
  output [5:0] rd
);

wire [7:0]  cond;
wire [1:0]  cndf;
wire [2:0]  cmpf;
wire [2:0]  oprf;
wire        osgn;
wire [1:0]  cimm;

wire [7:0]  inst;
wire        exti;
wire        sign;
wire [5:0]  opcd;

wire [7:0]  extn;

wire [31:0] oprn;
wire [1:0]  oimm;

wire [63:0] cmpA;
wire [63:0] cmpB;
wire cmp;
wire cmpl;
wire cmpe;
wire cmpg;

assign cond = longs[0][7:0];
assign cndf = cond[7:6];
assign cmpf = cond[5:3];
assign oprf = cond[2:0];
assign osgn = oprf[2];
assign cimm = oprf[1:0];

assign ejmp = longs[0][15:8];

assign inst = longs[0][23:16];
assign exti = inst[7];
assign sign = inst[6];
assign opcd = inst[5:0];

assign extn = longs[0][31:24];

assign oprn = longs[0][63:32];
assign oimm = oprn[31:30];
assign rc1 = oprn[29:24];
assign rc2 = oprn[23:18];
assign re1 = oprn[17:12];
assign re2 = oprn[11:6];
assign rd = oprn[5:0];

assign cmpA = cimm[0] ? longs[1] : r1;

assign cmpB = cimm[1] ? 
	        cimm[0] ? 
		  longs[2] : 
		longs[1] : 
	      r2;

assign A = oimm[0] ? 
	     (cimm == 0) ? 
	       longs[1] :
	     (cimm == 3) ?
	       longs[3] :
	     longs[2] : 
	   r3;

assign B = oimm[1] ? 
	     (cimm == 0) ? 
	       oimm[0] ? 
	         longs[2] : 
	       longs[1] : 
	     (cimm == 3) ? 
	       oimm[0] ? 
	         longs[4] : 
	       longs[3] : 
	     oimm[0] ? 
	       longs[3] : 
	     longs[2] : 
	   r4;

assign C = rd;

assign length = (oimm == 3) ? 
	        (cimm == 3) ? 
		  5 : 
		(cimm == 0) ? 
		  3 : 
		4 : 
	      (oimm == 0) ? 
	        (cimm == 3) ? 
		  3 : 
		(cimm == 0) ? 
		  1 : 
		2 : 
	      (cimm == 3) ? 
	        4 : 
              (cimm == 0) ? 
	        2 : 
	      3;

assign cmpl = osgn ? ($signed(cmpA) < $signed(cmpB)) : (cmpA < cmpB);
assign cmpe = osgn ? ($signed(cmpA) == $signed(cmpB)) : (cmpA == cmpB);
assign cmpg = osgn ? ($signed(cmpA) > $signed(cmpB)) : (cmpA >  cmpB);
assign cmp = (cmpf[2] && cmpl) || (cmpf[1] && cmpe) || (cmpf[0] && cmpg);
assign valid = (cndf == 0 || (cndf == 1 && pass && cmp) || (cndf == 2 && ~pass && cmp) || (cndf == 3 && cmp));

assign issue = opcd[5] ? 3 : opcd[4:3];
assign opsel = opcd[4:0];

endmodule
