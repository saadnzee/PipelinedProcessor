module TopLevel_PP(
 output [31:0] PC_Out,
 output [31:0] Instr,		// Instruction that is fetched in each cycle
 output reg [31:0] Rs_Val,	// Goes into ALU
 output reg [31:0] Rt_Val,	// Goes into ALU
 input clk,
 input rst,
 input enable_forwarding	// if 1 forwarding is done, if 0 we stall
);

wire [31:0] Rs,Rt;		// Value read at ID Stage
reg PCWrite = 1'b1;

wire PCSrc; 			// if 0/X Normal PC or if 1 then Branch Address
wire [31:0] Jump_Address; 	// PC for Jump
wire Branch;
reg [31:0] write_data;		// Either ALUResult or Read Data from RAM

wire jump;
wire [31:0] PC_EX;		// For Branch (Address)
wire [31:0] im;

PC_PP PP (.clk(clk), .rst(rst), .PC_Out(PC_Out), .PCSrc(PCSrc), .PC_Branch(PC_EX), .Jump_Address(Jump_Address), .jump(jump), .PCWrite(PCWrite));

ROM_PP RP (.PC_In(PC_Out), .Instr(Instr));

wire [31:0] PC_ID, Instr_ID;

reg rst_IF_ID = 1'b0;
reg we_IF_ID = 1'b1;	// FOR HAZARD DETECTION (LW,xx)

// Flush Case when Branch
always@* begin
if (PCSrc==1'b1) 
 rst_IF_ID <= 1'b1;
else
 rst_IF_ID <= 1'b0;
end

IF_ID_Register IIR (.clk(clk), .rst(rst), .PC_In(PC_Out), .Instr_In(Instr), .PC_Out(PC_ID), .Instr_Out(Instr_ID), .we_IF_ID(we_IF_ID), .rst_IF_ID(rst_IF_ID));

wire [4:0] rs,rt,rd,shamt;
wire [5:0] opcode;
wire [25:0] jump_address_temp;
wire [15:0] im_temp;

Decoder_PP DP (.Instr(Instr_ID), .im_temp(im_temp), .jump_address_temp(jump_address_temp), .opcode(opcode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .rst(rst));

assign im = {{16{im_temp[15]}},im_temp};
assign Jump_Address = {{PC_Out[31:26]},jump_address_temp};

wire [1:0] ALUOp;
wire RegDst, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;

Control_PP CP (.opcode(opcode), .ALUOp(ALUOp), .RegDst(RegDst), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .MemWrite(MemWrite), .ALUSrc(ALUSrc), 
.RegWrite(RegWrite), .jump(jump));

reg [4:0] rd_sel;	// Either rd (R-Type) or rt (I-Type)
wire RegWrite_WB;
wire [4:0] rd_WB;

RegisterFile_PP RFP (.rs(rs), .rt(rt), .rd(rd_WB), .clk(clk), .rst(rst), .RegWrite(RegWrite_WB), .Data_In(write_data), .Rs(Rs), .Rt(Rt));

wire [31:0] data_lw;
wire [31:0] Rs_EX, Rt_EX, im_EX; 
wire [4:0] rt_EX, rd_EX, rs_EX;

reg rst_ID_EX = 1'b0;

wire [31:0] PC_Result;
assign PC_Result = PC_ID + im;		// In decode stage, PC + Immediate

ID_EX_Register IED (.PC_In(PC_Result), .Rs_In(Rs), .Rt_In(Rt), .im_In(im), .rt_In(rt), .rd_In(rd), .rs_In(rs), .PC_Out(PC_EX), .Rs_Out(Rs_EX), .Rt_Out(Rt_EX), .im_Out(im_EX), .rt_Out(rt_EX),
.rd_Out(rd_EX), .rs_Out(rs_EX), .clk(clk), .rst(rst), .rst_ID_EX(rst_ID_EX));

wire [1:0] ALUOp_EX;
wire [5:0] opcode_EX;
wire RegDst_EX, MemRead_EX, MemtoReg_EX, MemWrite_EX, ALUSrc_EX, RegWrite_EX, Branch_EX;

ID_EX_Control IEC (.ALUOp_Out(ALUOp_EX), .RegDst_Out(RegDst_EX), .MemRead_Out(MemRead_EX), .MemtoReg_Out(MemtoReg_EX), .MemWrite_Out(MemWrite_EX), .ALUSrc_Out(ALUSrc_EX), .RegWrite_Out(RegWrite_EX),
.Branch_Out(Branch_EX), .opcode_Out(opcode_EX), .clk(clk), .rst(rst_ID_EX), .ALUOp_In(ALUOp), .RegDst_In(RegDst), .MemRead_In(MemRead), .MemtoReg_In(MemtoReg), .MemWrite_In(MemWrite), .ALUSrc_In(ALUSrc), .RegWrite_In(RegWrite),
.Branch_In(Branch), .opcode_In(opcode));

wire zero_flag;
assign zero_flag = (Rs_EX==Rt_EX);
assign PCSrc = Branch_EX && zero_flag;

always@* begin
if (RegDst_EX == 1'b1) begin 
 rd_sel <= rd_EX; 
end
else begin 
 rd_sel <= rt_EX; 
end
end

reg [31:0] Rt_ALU;	// Either Rt (R-Type) or Im (I-Type)

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

wire [31:0] ALUResult_WB;

always@* begin

// LW Type Dependency (One Necessary Stall)
if(enable_forwarding==1'b1) begin
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

// R-Type Dependency Case (Stall must be mantained until Register File is updated and we can read the correct/required data)
if (enable_forwarding==1'b0) begin
 if(RegWrite_EX == 1'b1) begin
  if ((rd_EX == rs) || (rd_EX == rt)) begin
   we_IF_ID <= 0;
   PCWrite <= 0;
   rst_ID_EX <= 1;
  end
 end
 if ((Rs == ALUResult_WB) || (Rt == ALUResult_WB)) begin
   we_IF_ID <= 1;
   PCWrite <= 1;
   rst_ID_EX <= 0;
 end
 
// LW Dependency Case (Stall must be mantained until Register File is updated and we can read the correct/required data)
 if (MemRead_EX == 1'b1) begin
  if ((rt_EX == rs) || (rt_EX == rt)) begin
   we_IF_ID <= 0;
   PCWrite <= 0;
   rst_ID_EX <= 1;
  end
 end
 if ((Rs == data_lw) || (Rt == data_lw)) begin
   we_IF_ID <= 1;
   PCWrite <= 1;
   rst_ID_EX <= 0;
 end

  Rs_Val <= Rs_EX;
  Rt_Val <= Rt_EX;

end
end


// ******************************
// ******************************
// ******************************



// ******************************
// *****For Data Forwarding*****
// ******************************

wire MemtoReg_WB;

wire [31:0] ALUResult_MEM;
wire [4:0] rd_MEM;

// For Rs
always@* begin
 if (enable_forwarding==1'b1) begin
  if(rd_MEM == rs_EX)			// Type-1
   Rs_Val <= ALUResult_MEM;
  else if (rd_WB == rs_EX)		// Type-2
   Rs_Val <= ALUResult_WB;
  else 
   Rs_Val <= Rs_EX;
 
  if (MemtoReg_WB==1'b0) begin
   if (rd_WB == rs_EX)			// In this case rd_WB contains rt/destination for lw
    Rs_Val <= data_lw;
  end
 end
end

// For Rt
always@* begin
if (enable_forwarding==1'b1) begin
 if(rd_MEM == rt_EX)
  Rt_Val <= ALUResult_MEM;		// Type-1
 else if (rd_WB == rt_EX)
  Rt_Val <= ALUResult_WB;		// Type-2
 else 
  Rt_Val <= Rt_ALU;

 if (MemtoReg_WB==1'b0) begin
  if (rd_WB == rt_EX)
   Rt_Val <= data_lw;			// In this case rd_WB contains rt/destination for lw		
 end
end
end

// ******************************
// ******************************
// ******************************

reg rst_EX_MEM, rst_MEM_WB = 1'b0;
// Flush Case when Branch
always@* begin
 if (PCSrc==1'b1) begin
  rst_ID_EX = 1'b1;
 end
 else begin
  rst_ID_EX = 1'b0;
 end
end

always@* begin
 if (jump==1'b1)
  rst_IF_ID = 1'b1;
 else
  rst_IF_ID = 1'b0;
end

// Rt_Val should be equal to Rt_ALU in this case Im for all I-Type Instructions
always@* begin
 if (opcode_EX == 6'd35 || opcode_EX == 6'd43 || opcode_EX == 6'd4 || opcode_EX == 6'd10) begin
  Rt_Val <= Rt_ALU;
 end
end

ALU_Control_PP ACP (.ALUOp(ALUOp_EX), .funct(funct_in), .ALU_opcode(ALU_opcode));

wire [31:0] ALUResult;		// ALU Result at Execute Stage

ALU_PP AP (.ALUResult(ALUResult), .zero_flag(zero_flag), .ALU_opcode(ALU_opcode), .Rs1(Rs_Val),.Rs2(Rt_Val));

wire MemRead_MEM, MemtoReg_MEM, MemWrite_MEM, RegWrite_MEM, jump_MEM, Branch_MEM;

EX_MEM_Control EMC(.MemRead_Out(MemRead_MEM), .MemtoReg_Out(MemtoReg_MEM), . MemWrite_Out(MemWrite_MEM), . RegWrite_Out(RegWrite_MEM),
.clk(clk), .rst(rst_EX_MEM), .MemRead_In(MemRead_EX), .MemtoReg_In(MemtoReg_EX), .MemWrite_In(MemWrite_EX), .RegWrite_In(RegWrite_EX));

wire [31:0] Rt_MEM;
wire zero_flag_MEM;

reg [31:0] Rt_Write;

// LW and SW Dependency
always@* begin
 if (MemtoReg_WB==1'b0) begin
  if (MemWrite_EX == 1'b1) begin
    Rt_Write <= Rt_EX;
   if (rd_WB == rt_EX)
    Rt_Write <= data_lw;
  end
 end
end


EX_MEM_Register EMR (.Rt_Out(Rt_MEM), .rd_Out(rd_MEM), .ALUResult_Out(ALUResult_MEM),
.clk(clk), .rst(rst_EX_MEM), .Rt_In(Rt_Write), .rd_In(rd_sel), .ALUResult_In(ALUResult));

wire [31:0] read_data;

RAM_PP RAP (.address(ALUResult_MEM), .write_data(Rt_MEM), .clk(clk), .MemWrite(MemWrite_MEM), .MemRead(MemRead_MEM), .read_data(read_data));


MEM_WB_Control MWC (.MemtoReg_Out(MemtoReg_WB), .RegWrite_Out(RegWrite_WB), .clk(clk), .rst(rst), .MemtoReg_In(MemtoReg_MEM), .RegWrite_In(RegWrite_MEM));


MEM_WB_Register MWR (.read_data_Out(data_lw), .rd_Out(rd_WB), .ALUResult_Out(ALUResult_WB), .clk(clk), .rst(rst), .read_data_In(read_data),
.rd_In(rd_MEM), .ALUResult_In(ALUResult_MEM));

// if MemtoReg = 1, ALUResult goes into Regfile otherwise data from RAM goes.
always@* begin
 if(MemtoReg_WB == 1'b1)
  write_data <= ALUResult_WB;
 else
  write_data <= data_lw;
end

endmodule
