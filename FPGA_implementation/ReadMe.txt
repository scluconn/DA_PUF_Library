This folder contains the FPGA implementation of XOR APUF (or XORPUF for short)
and IPUF.

XORPUF and IPUF has the same file organization, so we just use XORPUF folder
as an example. 

--isePro
    This is the folder for ISE project. You can use Xilinx ISE to open the
    project file to see one example project. 

--src
    Contains all the source codes.

----tb
        Contains testbench

----ucf
        Contains different UCF file to constraint the placement of LUTs.
        Please open the example project in isePro to see how these UCF files
        are included.

----verilog
        Contains all verilog source code.
--------apuf
            source code for one arbiter PUF
--------picoBlaze6
            contains the source code to instantiate picoBlaze for cotrolling
            and communicating the PUF with the PUF via serial port. Check the
            example project in isePro to see how to include this file. To change
            the assembly code, please look into file assembler/program.psm,
            and use assembler/kcpsm6.exe for compiling and generating verilog
            code. 
-------sw_dolut
            is the file to implement a stage of Arbiter PUF (called switch
            chain in this file) as a LUT. 
-------xorpuf
            contains the implementation of xorpuf, instantiating APUFs built
            in another folder.

----matlab
        contains matlab code for FPGA implementation
------placement
            sw_placement_apuf_a_backup.m generates UCF files according to the
            placement strategies you select. Many strategies are provided for
            you to choose. They are "placementType_XXXX.m" files. In
            particular, "placementType_RAND.m" takes one seed and select a
            random LUT among A,B,C,D in each slice to form a switch chain.
            This is the random placement we refer to in the paper. 
------rs232_COM
            run main.m file to communicate with the FPGA. Many parameters can
            be changed in the main file. The collected data will be in a
            folder called "dataset"
-----crpProcessing
            After obtaining dataset from rs232_COM, you can run
            crpProcessing.m to parse the raw data collected from FPGA. This
            will facilitate your further analysis. The scripts for computing
            uniqueness, reliability, uniformity and SAC property are available
            as well. "crpProcessiing23.m" has been modified to process the raw
            data of 23XOR APUFs specifically. 
