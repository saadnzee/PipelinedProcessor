module RAM_PP(
input [31:0] address,
input [31:0] write_data,
input clk,
input MemWrite,
input MemRead,
output reg [31:0] read_data
);

reg [31:0] RAM [63:0];

initial begin
RAM[0] = 32'd50;
RAM[1] = 32'd51;
RAM[2] = 32'd52;
RAM[3] = 32'd53;
RAM[4] = 32'd54;
RAM[5] = 32'd109;
RAM[6] = 32'd56;
RAM[7] = 32'd5;
RAM[8] = 32'd58;
RAM[9] = 32'd59;
RAM[10] = 32'd50;
RAM[11] = 32'd50;
RAM[12] = 32'd50;
RAM[13] = 32'd50;
RAM[14] = 32'd50;
RAM[15] = 32'd50;
RAM[16] = 32'd50;
RAM[17] = 32'd50;
RAM[18] = 32'd50;
RAM[19] = 32'd50;
RAM[20] = 32'd50;
RAM[21] = 32'd50;
RAM[22] = 32'd50;
RAM[23] = 32'd50;
RAM[24] = 32'd50;
RAM[25] = 32'd50;
RAM[26] = 32'd50;
RAM[27] = 32'd50;
RAM[28] = 32'd50;
RAM[29] = 32'd50;
RAM[30] = 32'd50;
RAM[31] = 32'd50;
RAM[62] = 32'd9;
end

always @(posedge clk)
begin
 if(MemWrite)
  RAM[address] <= write_data;
end
always @*
begin
 if(MemRead)
  read_data <= RAM[address];
end

endmodule

