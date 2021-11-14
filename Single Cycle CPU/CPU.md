-   Logged in user [samymbas](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#)
    -   Log out
-   Log in

[FIT CTU Course Pages](https://courses.fit.cvut.cz/)

BIE-APS — Architectures of Computer Systems

-   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#)
     Past semesters
    -   [B101](https://courses.fit.cvut.cz/BIE-APS/@B101/)
    -   [B131](https://courses.fit.cvut.cz/BIE-APS/@B131/)
    -   [B141](https://courses.fit.cvut.cz/BIE-APS/@B141/)
    -   [B151](https://courses.fit.cvut.cz/BIE-APS/@B151/)
    -   [B161](https://courses.fit.cvut.cz/BIE-APS/@B161/)
    -   [B171](https://courses.fit.cvut.cz/BIE-APS/@B171/)
    -   [B181](https://courses.fit.cvut.cz/BIE-APS/@B181/)
    -   [B201](https://courses.fit.cvut.cz/BIE-APS/@B201/)
    -   [master](https://courses.fit.cvut.cz/BIE-APS/)
-   [](https://gitlab.fit.cvut.cz/BI-APS/bie-aps/blob/master/tutorials/05/semester_project.adoc)
     View on GitLab
-   [](https://gitlab.fit.cvut.cz/BI-APS/bie-aps/issues/new?issue[title]=tutorials/05/semester_project.adoc:%20)
     Report issue

[Go to course navigation](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#nav)

Seminar project \#1: Single-cycle CPU design
============================================

[](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_seminar-project-1-single-cycle-cpu-design)Seminar project \#1: Single-cycle CPU design
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

#### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_basic-cpu-design)Basic CPU design

Design a simple 32-bit processor connected to a separate instruction and data memory. The processor has to implement instructions given in the table bellow. Suppose that the processor starts the execution from the beginning of instruction memory (0x00000000).

![cpu](./CPU_files/cpu.png)

Instruction

Syntax

Operation

Note

add

add rd, rs1, rs2

rd ← [rs1] + [rs2];

addi

addi rd, rs1, imm<sub>11:0</sub>

rd ← [rs1] + imm<sub>11:0</sub>;

addu.qb

addu.qb rd, rs1, rs2

rd<sub>31:24</sub> ← [rs1<sub>31:24</sub>] + [rs2<sub>31:24</sub>]; rd<sub>23:16</sub> ← [rs1<sub>23:16</sub>] + [rs2<sub>23:16</sub>]; etc.

User-defined SIMD instr.

and

and rd, rs1, rs2

rd ← [rs1] & [rs2];

sub

sub rd, rs1, rs2

rd ← [rs1] - [rs2];

slt

slt rd, rs1, rs2

if [rs1] \< [rs2] then rd←1; else rd←0;

beq

beq rs1, rs2, imm<sub>12:1</sub>

if [rs1] == [rs2] go to [PC]+{imm<sub>12:1</sub>,'0'}; else go to [PC]+4;

lw

lw rd,imm<sub>11:0</sub>(rs1)

rd ← Memory[[rs1] + imm<sub>11:0</sub>]

sw

sw rs2,imm<sub>11:0</sub>(rs1)

Memory[[rs1] + imm<sub>11:0</sub>] ← [rs2];

lui

lui rd, imm<sub>31:12</sub>

rd ← {imm<sub>31:12</sub>,'0000 0000 0000'};

jal

jal rd, imm<sub>20:1</sub>

rd ← [PC]+4; go to [PC] +{imm<sub>20:1</sub>,'0'};

jalr

jalr rd, rs1, imm<sub>11:0</sub>

rd ← [PC]+4; go to [rs1]+imm<sub>11:0</sub>;

#### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_extended-cpu-design)Extended CPU design

Add to the processor the support for: auipc, sll, srl, sra.

Instruction

Syntax

Operation

Note

auipc

auipc rd,imm<sub>31:12</sub>

rd ← [PC] + {imm<sub>31:12</sub>,'0000 0000 0000'};

sll

sll rd, rs1, rs2

rd ← [rs1] \<\< [rs2];

srl

srl rd, rs1, rs2

rd ← (unsigned)[rs1] \>\> [rs2];

sra

sra rd, rs1, rs2

rd ← (signed)[rs1] \>\> [rs2];

Note: The submission system tests these instructions sequentially (in some order). If it finds an incorrect implementation, it does not continue testing and it displays the number of points. Because this is an extended design, it no longer provides a hint.

**Instruction encoding:**

Each instruction is encoded in 32 bits (in the table from msb towards lsb), where rs1, rs2 and rd are encoded in 5 bits. Very last column of the table represents Opcode of the instruction.

add:

0000000

rs2

rs1

000

rd

0110011

addi

imm[11:0]

rs1

000

rd

0010011

adduqb:

0000000

rs2

rs1

000

rd

0001011

and:

0000000

rs2

rs1

111

rd

0110011

sub:

0100000

rs2

rs1

000

rd

0110011

slt:

0000000

rs2

rs1

010

rd

0110011

beq:

imm[12|10:5]

rs2

rs1

000

imm[4:1|11]

1100011

lw:

imm[11:0]

rs1

010

rd

0000011

sw:

imm[11:5]

rs2

rs1

010

imm[4:0]

0100011

lui:

imm[31:12]

rd

0110111

jal:

imm[20|10:1|11|19:12]

rd

1101111

jalr:

imm[11:0]

rs1

000

rd

1100111

auipc:

imm[31:12]

rd

0010111

sll:

0000000

rs2

rs1

001

rd

0110011

srl:

0000000

rs2

rs1

101

rd

0110011

sra:

0100000

rs2

rs1

101

rd

0110011

#### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_program-s)Program S

Write a program called S in the RISC-V assembly language that merges two images into one image. We will use image format described later. Program calls a subroutine merge() with the following C-language prototype:

    int merge(int *inputImgA, int *inputImgB, int *outputImg);

This subroutine should return the number of pixels of the output image. Use the RISC-V calling convention.

Suppose that the input adresses for the subroutine are stored in the data memory at following adresses:

-   0x00000004: inputImgA
-   0x00000008: inputImgB
-   0x0000000C: outputImg

For instance, at address 0x00000004 the address of inputImgA is stored (where the image begins).

After returning from the subroutine, program should write the returned result (i.e. the number of pixels of the output image) into the data memory at address of 0x00000010.

Translate program S from the RISC-V assembly language into the machine code of your CPU design.

**Image format:** Image starts with a header consisting of a 4-byte signature 0x5350412e (i.e. ".APS" in ASCII) followed by image width (4 bytes) and image height (4 bytes). After the header, comes a series of individual pixels. Each pixel (4 bytes) encodes red, green, blue and alpha channel (in this ordering), each of which is 1 byte long (8 bits). Red channel is encoded in LSB, whereas alpha channel is encoded in MSB.

An example of the 2x3 image in hexadecimal:

    5350412e
    00000002
    00000003
    11223300
    2200aaff
    00ffff00
    03565654
    1b459748
    ecf39baa

**Algorithm:** For every pixel of the output image:

-   set aplha channel to 0xFF
-   output color channel (i.e., red, green and blue) is computed as the sum of corresponding channels of the input pixels. There is no need to treat overflow (i.e. if the sum is greather than 0xFF, only lower 8 bits are used).

Only the images with the same size can be merged. Input images have always the same size (no need to test it).

###### Note:

If you got 0 points for your program, there is a change it is the result of incomplete/poor CPU description.

### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_seminar-project-evaluation)Seminar project evaluation

Description

Points

Basic CPU design in Verilog

12

Extended CPU design:

4

Program S in the machine code

9

Soft deadline: November ~~14~~ 21, 2021. Each week delay is sanctioned with -2 points. Submissions after the 13th week of the semester are not accepted (hard deadline).

###### Important:

Your program has to run on your CPU design, i.e. you can get 9 points for your program only if you provide your description of the CPU in Verilog.

### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_the-requirements-for-semester-project-documentation)The requirements for semester project documentation

-   Your semester project will be submitted as zipped archive **Surname\_FirstName.zip** of three files.
-   The first file named **Surname\_FirstName\_CPU.v** should contain all source codes in Verilog.

###### Important:

Include the Verilog description only for the CPU. Do not include the description of other components (data memory, instruction memory, etc.).

Use the following template:

    `default_nettype none
    module processor( input         clk, reset,
                      output [31:0] PC,
                      input  [31:0] instruction,
                      output        WE,
                      output [31:0] address_to_mem,
                      output [31:0] data_to_mem,
                      input  [31:0] data_from_mem
                    );
        //... write your code here ...
    endmodule

    //... add new Verilog modules here ...
    `default_nettype wire

You can add and use new Verilog modules as you wish.

-   The second file named **Surname\_FirstName\_prog1.asm** should contain program S in the RISC-V assembly language.
-   The third file named **Surname\_FirstName\_prog1.hex** should contain program S in the hexadecimal format (one instruction per line).

### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_submition-of-your-semester-project)Submition of your semester project

Submit the zip archive **Surname\_FirstName.zip** to the web page [http://biaps.fit.cvut.cz/first\_semestral\_project/index.php](http://biaps.fit.cvut.cz/first_semestral_project/index.php).

You must authenticate using the last 4 digits of your ID number = the number found on your ISIC card or found on [https://usermap.cvut.cz](https://usermap.cvut.cz/).

### [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html#_hints)Hints

You can use the MARS simulator to generate the machine code of program S. See figure bellow. Note: MARS implements RISC-V ISA, which slightly differs from picoMIPS ISA - see the definition of instructions described above (there is no addu.qb instruction).

![MARS 01](./CPU_files/MARS_01.png)

You can use the following Verilog modules to represent the whole computer system. If the data and instruction memory arrays of vectors are not large enough, extend them. However, please **do not** include them into the **Surname\_FirstName\_CPU.v** file.

    module top (    input         clk, reset,
            output [31:0] data_to_mem, address_to_mem,
            output        write_enable);

        wire [31:0] pc, instruction, data_from_mem;

        inst_mem  imem(pc[7:2], instruction);
        data_mem  dmem(clk, write_enable, address_to_mem, data_to_mem, data_from_mem);
        processor CPU(clk, reset, pc, instruction, write_enable, address_to_mem, data_to_mem, data_from_mem);
    endmodule

    //-------------------------------------------------------------------
    module data_mem (input clk, we,
             input  [31:0] address, wd,
             output [31:0] rd);

        reg [31:0] RAM[63:0];

        initial begin
            $readmemh ("memfile_data.hex",RAM,0,63);
        end

        assign rd=RAM[address[31:2]]; // word aligned

        always @ (posedge clk)
            if (we)
                RAM[address[31:2]]<=wd;
    endmodule

    //-------------------------------------------------------------------
    module inst_mem (input  [5:0]  address,
             output [31:0] rd);

        reg [31:0] RAM[63:0];
        initial begin
            $readmemh ("memfile_inst.hex",RAM,0,63);
        end
        assign rd=RAM[address]; // word aligned
    endmodule

And for the simulation, you can use the following template:

    module testbench();
        reg         clk;
        reg         reset;
        wire [31:0] data_to_mem, address_to_mem;
        wire        memwrite;

        top simulated_system (clk, reset, data_to_mem, address_to_mem, write_enable);

        initial begin
            $dumpfile("test");
            $dumpvars;
            reset<=1; # 2; reset<=0;
            #100; $finish;
        end

        // generate clock
        always  begin
            clk<=1; # 1; clk<=0; # 1;
        end
    endmodule

You’re browsing the **...** version.
 [Go to the latest version.](https://courses.fit.cvut.cz/BIE-APS/)

Course navigation
=================

-   [](https://courses.fit.cvut.cz/BIE-APS/index.html)
    BIE-APS - News
-   [](https://courses.fit.cvut.cz/BIE-APS/classification/index.html)
    Evaluation, assessment, exam, and grading
-   [](https://courses.fit.cvut.cz/BIE-APS/lectures/index.html)
    Lectures
-   [](https://courses.fit.cvut.cz/BIE-APS/news/index.html)
    News
-   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/index.html)
    Seminars
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/01/index.html)
        1. Seminar - Computer Performance Measurement
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/02/index.html)
        2. Seminar - ISA and the RISC-V assembly language
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/03/index.html)
        3. Programming in assembly language for RISC-V: calling convention, instruction encoding and machine code generation.
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/04/index.html)
        4. Hardware description language (Verilog)
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/index.html)
        5. Seminar - Basic computer components II, Single cycle CPU
        -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/05/semester_project.html)
            Seminar project \#1: Single-cycle CPU design
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/06/index.html)
        6. Seminar - Pipelined microarchitecture
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/07/index.html)
        7. Seminar - Cache - Introduction
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/08/index.html)
        8. Seminar - Cache - Accessing memory from C programs, Virtual memory
        -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/08/seminar_project.html)
            Seminar project \#2: Cache access optimization
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/09/index.html)
        9. Seminar - Cache - Coherence and coherence protocols, Explanation of MESI protocol
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/10/index.html)
        10. Seminar - Memory consistency and multithreaded programs
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/11/index.html)
        11. Seminar - Sequential consistency
    -   [](https://courses.fit.cvut.cz/BIE-APS/tutorials/12/index.html)
        12. Seminar - Superscalar processors, Evaluation of assignments, credit
-   [](https://courses.fit.cvut.cz/BIE-APS/teacher/index.html)
    Teachers

Seminar project \#1: Single-cycle CPU design
 [tutorials/05/semester\_project.adoc](https://gitlab.fit.cvut.cz/BI-APS/bie-aps/blob/master/tutorials/05/semester_project.adoc), [last change 5bcbc904 (2021-11-11 at 18:39, Ing. Michal Štepanovský, Ph.D)](https://gitlab.fit.cvut.cz/BI-APS/bie-aps/commit/5bcbc904b5596c573c4a56534beb1dff7c2d18fb "Update tutorials/05/semester_project.adoc")

Generated with [**FIT CTU Course Pages**](https://gitlab.fit.cvut.cz/course-pages/course-pages/) v0.8.0
 Page generated at 2021-11-11 at 18:40

[![Build status](./CPU_files/pipeline.svg)](https://gitlab.fit.cvut.cz/BI-APS/bie-aps/pipelines)
