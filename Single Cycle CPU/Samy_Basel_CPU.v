//==============================================================================
// " CPU "
module processor( input clk, reset,
                  output [31:0] PC,
                  input [31:0] instruction,
                  output WE,
                  output [31:0] address_to_mem,
                  output [31:0] data_to_mem,
                  input [31:0] data_from_mem );

  wire reg_write, reg_dst, alu_src, is_branch, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j, pc_beq, zero;
	wire [3:0] alu_ctrl;
	wire [4:0] r3addy, write_reg, register31;
	wire [31:0] result, extended_imm, extended_shifted, r1, r2, dst_beq, dst_jal, dst_jr, PC, srcy, res, r3data, pc_next;
	supply0 GND;

  // OPCODE, FUNCTION, SHAMT, REG_WRITE, REG_DST, ALU_SRC, PC_BEQ, PC_JAL, PC_JR, PC_J, MEM_WRITE, MEM_TO_REG, ALU_CTRL
  control control_unit(instruction[31:26], instruction[5:0], instruction[10:6], reg_write, reg_dst, alu_src, is_branch, pc_jal, pc_jr, pc_j, mem_write, mem_to_reg, alu_ctrl);
  // CLK, RESET, PC_NOW, PC_BEQ, PC_JAL, PC_JR, BEQ_FLAG, JAL_FLAG, JR_FLAG, J_FLAG, PC_NOW
  pc program_counter(clk, reset, PC, dst_beq, dst_jal,	dst_jr, pc_beq, pc_jal, pc_jr, pc_j, PC);
  // CLK, WRITE_ENABLE, R1_ADDY, R2_ADDY, R3_ADDY, R3_DATA, R1, R2
  registers register_set(clk, reg_write, instruction[25:21], instruction[20:16], r3addy, r3data, r1, r2);
  // EXTENDS IMMEDIATE OPERAND
  sign_ext sign_extendor(instruction[15:0], extended_imm);
  // 5 BIT BINARY MULTIPLEXOR ( REGISTER 2 ADDY VS RESULT ADDY ) => ENABLES WRITE TO REGISTER SET
  multiplexor2_1_5 register_destination(instruction[20:16], instruction[15:11], reg_dst, write_reg);
  // 32 BIT BINARY MULTIPLEXOR ( REGISTER 2 VS SIGN EXTENDED IMMEDIATE OPERAND ) => RESULT USED AS SRC_Y OF ALU
  multiplexor2_1 alu_source(r2, extended_imm, alu_src, srcy);
  // 32 BIT BINARY MULTIPLEXOR ( READ DATA VS ALU RESULT ) => RESULT STORED TO BE WRITTEN TO REGISTER SET
  multiplexor2_1 memory_to_register(result, data_from_mem, mem_to_reg, res);
  // ARITHMETIC LOGIC OPERATION OF R1 AND SRC_Y DEPENDING ON ALU_CTRL, STORES ALU OUTPUT INTO RESULT & OVERFLOW
  alu arithmetic_logic_unit(r1, srcy, alu_ctrl, result, zero);

  assign data_to_mem = r2;
	assign address_to_mem = result;
	assign WE = mem_write;

  assign dst_beq = PC + 4 + extended_shifted;
  assign dst_jal = {PC[31:28], instruction[25:0], GND, GND};
  assign dst_jr = r1;

	assign register31 = 31;
	assign pc_next = PC + 4;

  // AND GATE DECIDING BRANCH ON EQUALITY FLAG
	branch branch_on_equality(zero, is_branch, pc_beq);
  // BRANCH ON EQUALITY IMMEDIATE OPERAND OFFSET CALCULATION
	shifter multiply_by_4(extended_imm, extended_shifted);
  // 32 BIT BINARY MULTIPLEXOR ( REGISTER SOURCE ADDY VS REGISTER 31 ADDY ) => USED TO JUMP BACK TO ADDY OF R31 AFTER JAL
	multiplexor2_1_5 pc_jump_and_link(write_reg, register31, pc_jal, r3addy);
  // 32 BIT BINARY MULTIPLEXOR ( IMMEDIATE OPERAND VS PC+4 ) SELECTION AS TO WHICH DATA TO WRITE TO REGISTER SET
	multiplexor2_1 write_data_register3(res, pc_next, pc_jal, r3data);

endmodule
//==============================================================================
// BINARY MULTIPLEXOR ( 32 BITS )

module multiplexor2_1( input [31:0] x_0, x_1, input select, output reg [31:0] y );
  always @ ( * ) begin
    if( select ) y = x_1;
    else y = x_0;
  end
endmodule
//==============================================================================
// BINARY MULTIPLEXOR ( 5 BITS )

module multiplexor2_1_5( input [4:0] x_0, x_1, input select, output reg [4:0] y );
  always @ ( * ) begin
    if( select ) y = x_1;
    else y = x_0;
  end
endmodule
//==============================================================================
// SIGN EXTENDOR - EXTENDS 16 BIT INPUT TO 32 BITS (2'S COMPLEMENT CODE)

module sign_ext( input [15:0] in, output[31:0] out );
  assign out = { {16{in[15]}}, in };
endmodule
//==============================================================================
// SHIFTER ( MULTIPLY x4 )

module shifter(input [31:0] in, output [31:0] out );
  assign out = in * 4;
endmodule
//==============================================================================
// " PROGRAM COUNTER "

module pc( input clk, reset,
           input [31:0] inaddy, beq, jal, jr,
           input pc_beq, pc_jal, pc_jr, pc_j,
           output reg [31:0] outaddy );

  initial begin
    outaddy <= 0;
  end
  always @ ( posedge clk ) begin
    if( reset )
      outaddy <= 0;
    else if( pc_jr )
      outaddy <= jr;
    else if( pc_jal || pc_j )
      outaddy <= jal;
    else if( pc_beq )
      outaddy <= beq;
    else
      outaddy <= inaddy + 4; // PC += 4
  end
endmodule
//==============================================================================
// " REGISTER SET "

module registers( input clk, write_enable,
                  input [4:0] r1addy, r2addy, r3addy,
                  input [31:0] r3data,
                  output reg [31:0] r1, r2);

  reg [31:0] rs[31:0]; // 32 BIT SET FOR 32 REGISTERS
  initial begin
    rs[0] = 0; // $0 = 0
  end

  always @ ( * ) begin // READ DATA FROM RS
    r1 = rs[ r1addy ];
    r2 = rs[ r2addy ];
  end

  always @ ( posedge clk ) begin // WRITE DATA TO RS
    if( write_enable ) begin
      if( r3addy != 0 )
        rs[ r3addy ] = r3data;
    end
  end
endmodule
//==============================================================================
// " ARITHMETIC LOGIC UNIT "

module alu( input [31:0] srcx, srcy,
            input [3:0] alu_ctrl,
            output reg [31:0] result,
            output zero );

  reg sat = 0;

  parameter
  op_add = 4'b0010,
  op_sub = 4'b0110,
  op_and = 4'b0000,
  op_or = 4'b0001,
  op_slt = 4'b0111,
  op_sllv = 4'b1010,
  op_srlv = 4'b1011,
  op_srav = 4'b1100,
  op_addu = 4'b1000,
  op_addu_s = 4'b1001;

  always @ ( * )
    case( alu_ctrl )
      op_add : result = srcx + srcy;
      op_sub : result = srcx - srcy;
      op_and : result = srcx & srcy;
      op_or : result = srcx | srcy;
      op_slt: result = (srcx[31] != srcy[31]) ? srcx[31] : (srcx < srcy);
      op_sllv: result = srcy << srcx;
      op_srlv: result = srcy >> srcx;
      op_srav: result = ($signed(srcy) >>> (srcx));
      op_addu :
                begin
                  result[7:0] = srcx[7:0] + srcy[7:0];
                  result[15:8] = srcx[15:8] + srcy[15:8];
                  result[23:16] = srcx[23:16] + srcy[23:16];
                  result[31:24] = srcx[31:24] + srcy[31:24];
                end
      op_addu_s :
              begin
              sat = 0;
              {sat, result[7:0]} = srcx[7:0] + srcy[7:0];
              if(sat == 1) result[7:0] = 8'b11111111;
              sat = 0;
              {sat, result[15:8]} = srcx[15:8] + srcy[15:8];
              if(sat == 1) result[15:8] = 8'b11111111;
              sat = 0;
              {sat, result[23:16]} = srcx[23:16] + srcy[23:16];
              if(sat == 1) result[23:16] = 8'b11111111;
              sat = 0;
              {sat, result[31:24]} = srcx[31:24] + srcy[31:24];
              if(sat == 1) result[31:24] = 8'b11111111;
              end
    endcase
    assign zero = ( result == 0 ) ? 1 : 0;
endmodule
//==============================================================================
// " ALU AND " - BRANCH

module branch( input zero, branch, output pc_beq );
	assign pc_beq = ( zero && branch ) ? 1 : 0;
endmodule
//==============================================================================
// " CONTROL UNIT "

module control( input [5:0] opcode, funct,
                input [4:0] shamt,
                output reg_write, reg_dst, alu_src,
                output pc_beq, pc_jal, pc_jr, pc_j, mem_write, mem_to_reg,
                output [3:0] alu_ctrl );
  wire [1:0] alu_op;
  main_decoder maindec( opcode, reg_write, reg_dst, alu_src, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j, alu_op );
  alu_decoder aludec( alu_op, funct, shamt, alu_ctrl );
endmodule
//==============================================================================
// " MAIN DECODER "

module main_decoder( input [5:0] opcode,
                     output reg reg_write, reg_dst, alu_src,
                     output reg pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j,
                     output reg [1:0] alu_op);
  parameter
  op_r = 6'b000000,
  ctrl_r = 11'b11010000000,
  op_lw = 6'b100011,
  ctrl_lw = 11'b10100001000,
  op_sw = 6'b101011,
  ctrl_sw = 11'b0x10001x000,
  op_beq = 6'b000100,
  ctrl_beq = 11'b0x00110x000,
  op_addi = 6'b001000,
  ctrl_addi = 11'b10100000000,
  op_jal = 6'b000011,
  ctrl_jal = 11'b1xxxxx0x100,
  op_j = 6'b000010,
  ctrl_j = 11'b0xxxxx0x001,
  op_jr = 6'b000111,
  ctrl_jr = 11'b0xxxxx0x010,
  op_addu = 6'b011111,
  ctrl_addu = 11'b11011000000;

	always @ (*) begin
		case (opcode)
			op_r: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_r;
			op_lw: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_lw;
			op_sw: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_sw;
			op_beq: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_beq;
			op_addi: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_addi;
			op_jal: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_jal;
      op_j: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_j;
			op_jr: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_jr;
			op_addu: {reg_write, reg_dst, alu_src, alu_op, pc_beq, mem_write, mem_to_reg, pc_jal, pc_jr, pc_j} = ctrl_addu;
		endcase
	end
endmodule
//==============================================================================
// " ALU DECODER "

module alu_decoder( input [1:0] alu_op,
                    input [5:0] funct,
                    input [4:0] shamt,
                    output reg [3:0] alu_ctrl );
  parameter
  op_add = 4'b0010,
  op_sub = 4'b0110,
  op_and = 4'b0000,
  op_or = 4'b0001,
  op_slt = 4'b0111,
  op_sllv = 4'b1010,
  op_srlv = 4'b1011,
  op_srav = 4'b1100,
  op_addu = 4'b1000,
  op_addu_s = 4'b1001;

	always @ (*) begin
		case (alu_op)
			0: alu_ctrl = op_add; // ADD
			1: alu_ctrl = op_sub; // SUB
			2: begin
				      case (funct)
                6'b100000: alu_ctrl = op_add; // ADD
					      6'b100010: alu_ctrl = op_sub; // SUB
					      6'b100100: alu_ctrl = op_and; // AND
					      6'b100101: alu_ctrl = op_or; // OR
					      6'b101010: alu_ctrl = op_slt; // SLT
					      6'b000100: alu_ctrl = op_sllv; // SLLV
					      6'b000110: if(shamt == 0) alu_ctrl = op_srlv; // SRLV
					      6'b000111: if(shamt == 0) alu_ctrl = op_srav; // SRAV
				      endcase
			   end
			3: begin
				if(shamt == 5'b00000 && funct == 6'b010000)
					alu_ctrl = op_addu; // ADDU.QB
				if(shamt == 5'b00100 && funct == 6'b010000)
					alu_ctrl = op_addu_s; // ADDU_S.QB
			   end
		endcase
	end
endmodule
//==============================================================================
// " DATA MEMORY "

module data_mem( input clk, we,
		             input [31:0] address, wd,
		             output [31:0] rd );

	reg [31:0] RAM[63:0]; // 32 bit memory with 64 entries

	initial begin
		$readmemh ("datamem.txt",RAM,0,63);
	end

	assign rd=RAM[address[31:2]]; // word aligned

	always @ (posedge clk)
    begin
  		if (we)
  			RAM[address[31:2]]<=wd;
      // display RAM memory values ( array )
      // $display("RAM[5] = %h", RAM[5]);
      // $display("RAM[6] = %h", RAM[6]);
      // $display("RAM[7] = %h", RAM[7]);
      // $display("RAM[8] = %h", RAM[8]);
      // $display("RAM[9] = %h", RAM[9]);
      // $display("======================");
    end

endmodule
//==============================================================================
// " INSTRUCTION MEMORY "

module inst_mem( input [5:0] address, output [31:0] rd );

	reg [31:0] RAM[63:0]; // 32 bit memory with 64 entries
	initial begin
		$readmemh ("Samy_Basel_prog1.hex",RAM,0,63);
	end
	assign rd=RAM[address]; // word aligned

endmodule
//==============================================================================
// " TOP MODULE "

module top( input clk, reset,
		        output [31:0] data_to_mem, address_to_mem,
		        output write_enable );

  wire [31:0] pc, instruction, data_from_mem;

  inst_mem imem( pc[7:2], instruction );
	data_mem dmem( clk, write_enable, address_to_mem, data_to_mem, data_from_mem );
  processor CPU( clk, reset, pc, instruction, write_enable, address_to_mem, data_to_mem, data_from_mem );

endmodule
