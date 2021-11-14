# " SINGLE-CYCLE CPU DESIGN " 
============================================

Design a simple 32-bit processor connected to a separate instruction and data memory. The processor has to implement instructions given in the table bellow. Suppose that the processor starts the execution from the beginning of instruction memory (0x00000000).

![cpu](./cpu.png)

#### Program S

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
