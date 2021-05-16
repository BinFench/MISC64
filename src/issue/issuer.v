module issuer(
  input clock,
  input valid [3:0],
  input sign [3:0],
  input [1:0] issue [3:0],
  input [4:0] opsel [3:0],
  input [63:0] A [3:0],
  input [63:0] B [3:0],
  input [63:0] C [3:0],
  input [5:0] re1 [3:0],
  input [5:0] re2 [3:0],
  input [5:0] rd [3:0],
  input [63:0] ejmp [3:0],
  input [63:0] PC [3:0],
  output [268:0] executables [3:0]
);

integer space;
integer taken;
integer i;
integer j;
integer k;
integer done;
integer assigned;
integer works;
integer flag;
integer executing;

reg [268:0] issbuff [7:0];
reg [2:0] head;
reg [2:0] tail;
reg empty;
reg full;

wire [1:0] issuetemp [3:0];
wire [4:0] opseltemp [3:0];
wire [63:0] Atemp [3:0];
wire [63:0] Btemp [3:0];
wire [5:0] re1temp [3:0];
wire [5:0] re2temp [3:0];
wire [5:0] rdtemp [3:0];
wire [2:0] tailtemp [4:0];
wire [2:0] headtemp [4:0];
wire signtemp [3:0];

wire [63:0] diff [7:0];

wire hasissue [3:0];
wire [5:0] hasrd [3:0];
wire [1:0] hasissue [3:0];
wire [4:0] hasop [3:0];

wire taking [7:0];
wire [268:0] tempbuff [7:0];

initial begin
  empty = 1;
  full = 0;
  tailtemp[0] = 0;
  headtemp[0] = 0;
end

always @(posedge clock) begin
  if (~full) begin
    //Buffer issuer logic
    if (head <= tail) begin
      space = 8 - tail + head;
    end else begin
      space = head - tail;
    end

    if (space < 4) begin
      //Stall issuer
      full = 1;
    end else begin
      //Issue instructions to buffer
      for (i = 0; i < 4; i = i + 1) begin
	issuetemp[i] = valid[i] ? issue[i] : 0;
	opseltemp[i] = valid[i] ? opsel[i] : 3;
	Atemp[i] = valid[i] ? A[i] : PC[i];
	Btemp[i] = valid[i] ? B[i] : ejmp[i];
	re1temp[i] = valid[i] ? re1[i] : 63;
	re2temp[i] = valid[i] ? re2[i] : 0;
	rdtemp[i] = valid[i] ? rd[i] : 63;
	tailtemp[i + 1] = (tailtemp[i] + 1);
	signtemp[i] = valid[i] ? sign[i] : 1;

	issbuff[(tailtemp[i] + tail) % 8][1:0] <= issuetemp[i];
	issbuff[(tailtemp[i] + tail) % 8][6:2] <= opseltemp[i];
	issbuff[(tailtemp[i] + tail) % 8][70:7] <= Atemp[i];
	issbuff[(tailtemp[i] + tail) % 8][134:71] <= Btemp[i];
	issbuff[(tailtemp[i] + tail) % 8][198:135] <= C[i];
	issbuff[(tailtemp[i] + tail) % 8][204:199] <= re1temp[i];
	issbuff[(tailtemp[i] + tail) % 8][210:205] <= re2temp[i];
	issbuff[(tailtemp[i] + tail) % 8][216:211] <= rdtemp[i];
	issbuff[(tailtemp[i] + tail) % 8][280:217] <= PC[i];
	issbuff[(tailtemp[i] + tail) % 8][281:281] <= signtemp[i];

      end
      if (space == 4) begin
	full = 1;
      end
      tail <= (tail + 4) %  8;
    end
  end

  if (~empty) begin
    //Buffer receiver logic
    if (head < tail) begin
      taken = tail - head;
    end else if (head > tail) begin
      taken = 8 - head + tail;
    end else begin
      taken = 0;
      empty = full ? 0 : 1;
    end

    done = 0;
    flag = 1;

    for (i = 0; i < 4; i = i + 1) begin
      if(done == 0) begin
        if (taken - headtemp[i] == 0) begin
          for (j = i; j < 4; j = j + 1) begin
	    hasissue[j] = 0;
	  end
	  done = 1;
        end else begin
	  assigned = 0;
          for (j = 0; j < taken - headtemp[i]; j = j + 1) begin
	    if (assigned == 0) begin
	      if (i == 0) begin
	        assigned == 1;
		headtemp[1] = 1;
		hasrd[0] = issbuff[head][216:211];
		hasissue[0] = issbuff[head][1:0];
		hasop[0] = issbuff[head][6:2];
	      end else begin
		works = 1;
		for (k = 0; k < i; k = k + 1) begin
		  if ((((hasrd[k] == issbuff[(head + headtemp[i]) % 8][204:199]) || (hasrd[k] == issbuff[(head + headtemp[i]) % 8][210:205]) && (hasrd[k] != 0) && ~((hasissue[k] == 3) && (hasop[k][5:4] == 2))) || (hasrd[k] == 63))) begin
		    works = 0;
		  end
		end
		if (works == 1) begin
		  assigned == 1;
		  headtemp[i + 1] = headtemp[i] + j + 1;
		  hasrd[i] = issbuff[(head + headtemp[i]) % 8][216:211];
		  hasissue[i] = issbuff[(head + headtemp[i]) % 8][1:0];
		  hasop[i] = issbuff[(head + headtemp[i]) % 8][6:2];
             	end
	      end
            end
          end
	  if (assigned == 1) begin
	    hasissue[i] = 1;
          end else begin
	    for (j = i + 1; j < 4; j = j + 1) begin
	      hasissue[j] = 0;
	    end
	    done = 1; 
	  end
        end
      end else if (flag == 1) begin
	head <= head + i - 1;
	flag = 0;
	executing = i;
      end
    end
    //Buffer Ordering Logic
    j = 0;
    k = 0;
    for (i = 0; i < headtemp[4]; i = i + 1) begin
      if (taking[i] == 0) begin
	tempbuff[j] = issbuff[(head + i) % 8];
	j = j + 1;
      end else begin
	executables[k] = issbuff[(head + i) % 8];
	k = k + 1;
      end
    end
    for (i = executing; i < headtemp[4]; i = i + 1) begin
      issbuff[(head + i - 1) % 8] <= tempbuff[i - executing];
    end
  end
end

endmodule
