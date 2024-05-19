module TopLevel_PP(
 output [31:0] PC_Out,
 output [31:0] Instr,
 output reg [31:0] Rs_Val,	// Goes into ALU
 output reg [31:0] Rt_Val,	// Goes into ALU
 input clk,
 input rst
);

wire [31:0] Rs,Rt;	// Value read at ID Stage
reg PCWrite = 1'b1;

wire PCSrc; // Normal PC or Branch Address
wire [31:0] PC_MEM; // PC for Branch
wire [31:0] Jump_Address; // PC for Jump Goes in ID/EX Register
wire [31:0] Jump_Address_EX; // PC for Jump goes into PC Module
wire jump_EX;
wire Branch;
reg [31:0] write_data;

PC_PP PP (.clk(clk), .rst(rst), .PC_Out(PC_Out), .PCSrc(PCSrc), .PC_MEM(PC_MEM), .Jump_Address(Jump_Address_EX), .jump(jump_EX), .PCWrite(PCWrite));

ROM_PP RP (.PC_In(PC_Out), .Instr(Instr));

wire [31:0] PC_ID, Instr_ID;

reg we_IF_ID = 1'b1;	// FOR HAZARD DETECTION (LW,xx)

IF_ID_Register IIR (.clk(clk), .rst(rst), .PC_In(PC_Out), .Instr_In(Instr), .PC_Out(PC_ID), .Instr_Out(Instr_ID), .we_IF_ID(we_IF_ID));

wire [4:0] rs,rt,rd,shamt;
wire [5:0] opcode;
wire [25:0] jump_address_temp;
wire [15:0] im_temp;

Decoder_PP DP (.Instr(Instr_ID), .im_temp(im_temp), .jump_address_temp(jump_address_temp), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt));

wire [31:0] im;
assign im = {{16{im_temp[15]}},im_temp};

assign Jump_Address = {{PC_Out[31:26]},jump_address_temp};

wire [1:0] ALUOp;
wire RegDst, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, jump;

Control_PP CP (.opcode(opcode), .ALUOp(ALUOp), .RegDst(RegDst), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .MemWrite(MemWrite), .ALUSrc(ALUSrc), 
.RegWrite(RegWrite), .jump(jump));

reg [4:0] rd_sel;
wire RegWrite_WB;
wire [4:0] rd_WB;

RegisterFile_PP RFP (.rs(rs), .rt(rt), .rd(rd_WB), .clk(clk), .rst(rst), .RegWrite(RegWrite_WB), .Data_In(write_data), .Rs(Rs), .Rt(Rt));

wire [31:0] PC_EX, Rs_EX, Rt_EX, im_EX; 
wire [4:0] rt_EX, rd_EX, rs_EX;

reg rst_ID_EX;

ID_EX_Register IED (.PC_In(PC_ID), .Rs_In(Rs), .Rt_In(Rt), .im_In(im), .rt_In(rt), .rd_In(rd), .rs_In(rs), .Jump_Address_In(Jump_Address), .PC_Out(PC_EX), .Jump_Address_Out(Jump_Address_EX), .Rs_Out(Rs_EX), .Rt_Out(Rt_EX), .im_Out(im_EX), .rt_Out(rt_EX),
.rd_Out(rd_EX), .rs_Out(rs_EX), .clk(clk), .rst(rst), .rst_ID_EX(rst_ID_EX));

wire [1:0] ALUOp_EX;
wire RegDst_EX, MemRead_EX, MemtoReg_EX, MemWrite_EX, ALUSrc_EX, RegWrite_EX, Branch_EX;

ID_EX_Control IEC (.ALUOp_Out(ALUOp_EX), .RegDst_Out(RegDst_EX), .MemRead_Out(MemRead_EX), .MemtoReg_Out(MemtoReg_EX), .MemWrite_Out(MemWrite_EX), .ALUSrc_Out(ALUSrc_EX), .RegWrite_Out(RegWrite_EX), .jump_Out(jump_EX),
.Branch_Out(Branch_EX), .clk(clk), .rst(rst), .ALUOp_In(ALUOp), .RegDst_In(RegDst), .MemRead_In(MemRead), .MemtoReg_In(MemtoReg), .MemWrite_In(MemWrite), .ALUSrc_In(ALUSrc), .RegWrite_In(RegWrite),
.jump_In(jump), .Branch_In(Branch));

always@* begin
if (RegDst_EX == 1'b1) begin 
 rd_sel <= rd_EX; 
end
else begin 
 rd_sel <= rt_EX; 
end
end

reg [31:0] Rt_ALU;

always@* begin
if (ALUSrc_EX == 1'b0) begin
 Rt_ALU <= Rt_EX;
end
else begin
 Rt_ALU <= im_EX;
end
end

wire [3:0] ALU_opcode;
wire [5:0] funct_in = im_EX[5:0];

// ******************************
// *****For HAZARD DETECTION*****
// ******************************

always@* begin
 if(MemRead_EX == 1'b1) begin
  if ((rt_EX == rs) || (rt_EX == rt)) begin
   we_IF_ID <= 0;
   PCWrite <= 0;
   rst_ID_EX <= 1;
  end
  else begin
   PCWrite <= 1;
   we_IF_ID <= 1;
   rst_ID_EX <= 0;
  end
 end
 else begin
  PCWrite <= 1;
  we_IF_ID <= 1;
  rst_ID_EX <= 0;
 end
end

// ******************************
// ******************************
// ******************************



// ******************************
// *****For Data Forwarding*****
// ******************************
wire [31:0] data_lw;
wire MemtoReg_WB;

wire [31:0] ALUResult_MEM, ALUResult_WB;
wire [4:0] rd_MEM;

//reg [31:0] Rs_Type1, Rt_Type1, Rs_Type2, R_Type3;

/*
always@* begin
  if(rd_MEM == rs_EX) begin
   Rs_Type1 <= ALUResult_MEM;
  end 
  else if (rd_MEM == rt_EX) begin 
   Rt_Type1 <= ALUResult_MEM;
  end
  else if (rd_WB == rs_EX) begin
   Rs_Type2 <= ALUResult_WB;
  end
  else if (rd_WB == rt_EX) begin
   Rt_Type2 <= ALUResult_WB;
  end
  // LW and R-Type (case)
  if (MemtoReg_WB==1'b1) begin
   if (rd_WB == rs_EX || rd_WB == rt_EX)
    R_Type3 <= data_lw;
  end
end
*/

// For Rs
always@* begin
 if(rd_MEM == rs_EX)
  Rs_Val <= ALUResult_MEM;
 else if (rd_WB == rs_EX)
  Rs_Val <= ALUResult_WB;
 else 
  Rs_Val <= Rs_EX;

 if (MemtoReg_WB==1'b0) begin
  if (rd_WB == rs_EX)
   Rs_Val <= data_lw;
 end
end

// For Rt
always@* begin
 if(rd_MEM == rt_EX)
  Rt_Val <= ALUResult_MEM;
 else if (rd_WB == rt_EX)
  Rt_Val <= ALUResult_WB;
 else 
  Rt_Val <= Rt_ALU;

 if (MemtoReg_WB==1'b0) begin
  if (rd_WB == rt_EX)
   Rt_Val = data_lw;
 end
end

// ******************************
// ******************************
// ******************************

ALU_Control_PP ACP (.ALUOp(ALUOp_EX), .funct(funct_in), .ALU_opcode(ALU_opcode));

wire zero_flag;
wire [31:0] ALUResult;
wire [31:0] PC_Result;

ALU_PP AP (.ALUResult(ALUResult), .zero_flag(zero_flag), .ALU_opcode(ALU_opcode), .Rs1(Rs_Val),.Rs2(Rt_Val));

assign PC_Result = PC_EX + im_EX;

wire MemRead_MEM, MemtoReg_MEM, MemWrite_MEM, RegWrite_MEM, jump_MEM, Branch_MEM;

EX_MEM_Control EMC(.MemRead_Out(MemRead_MEM), .MemtoReg_Out(MemtoReg_MEM), . MemWrite_Out(MemWrite_MEM), . RegWrite_Out(RegWrite_MEM), . jump_Out(jump_MEM), .Branch_Out(Branch_MEM),
.clk(clk), .rst(rst), .MemRead_In(MemRead_EX), .MemtoReg_In(MemtoReg_EX), .MemWrite_In(MemWrite_EX), .RegWrite_In(RegWrite_EX), .jump_In(jump_EX), .Branch_In(Branch_EX));

//wire [31:0] Rt_MEM, ALUResult_MEM;  *uncomment* and remove the line below
wire [31:0] Rt_MEM;
//wire [4:0] rd_MEM; *uncomment*
wire zero_flag_MEM;

EX_MEM_Register EMR (.PC_Out(PC_MEM), .Rt_Out(Rt_MEM), .rd_Out(rd_MEM), .zero_flag_Out(zero_flag_MEM), .ALUResult_Out(ALUResult_MEM),
.clk(clk), .rst(rst), .PC_In(PC_Result), .Rt_In(Rt_EX), .rd_In(rd_sel), .zero_flag_In(zero_flag), .ALUResult_In(ALUResult));

wire [31:0] read_data;

assign PCSrc = Branch_MEM && zero_flag_MEM;

RAM_PP RAP (.address(ALUResult_MEM), .write_data(Rt_MEM), .clk(clk), .MemWrite(MemWrite_MEM), .MemRead(MemRead_MEM), .read_data(read_data));

//wire MemtoReg_WB;

MEM_WB_Control MWC (.MemtoReg_Out(MemtoReg_WB), .RegWrite_Out(RegWrite_WB), .clk(clk), .rst(rst), .MemtoReg_In(MemtoReg_MEM), .RegWrite_In(RegWrite_MEM));

//wire [31:0] data_lw;

MEM_WB_Register MWR (.read_data_Out(data_lw), .rd_Out(rd_WB), .ALUResult_Out(ALUResult_WB), .clk(clk), .rst(rst), .read_data_In(read_data),
.rd_In(rd_MEM), .ALUResult_In(ALUResult_MEM));

always@* begin
 if(MemtoReg_WB == 1'b1)
  write_data <= ALUResult_WB;
 else
  write_data <= data_lw;
end

endmodule

