# Pipelined Processor
This pipelined processor is designed to execute the MIPS instruction set architecture (ISA) efficiently by overlapping the execution of multiple instructions. The processor includes mechanisms to handle data and control hazards, ensuring correct program execution while maintaining high performance.

# Instruction Set Architecture (ISA)
The processor fully supports the MIPS instruction set, including:

- R-Type Instructions: Arithmetic and logical operations involving registers (e.g., add, sub, mul).
- I-Type Instructions: Operations involving immediate values, memory access instructions (e.g., lw, sw), and conditional branches (e.g., beq).
- J-Type Instructions: Unconditional jump instructions (e.g., j).
# Pipeline Stages
Instruction Fetch (IF): The instruction is fetched from memory.
Instruction Decode/Register Fetch (ID): The instruction is decoded, and operands are fetched from the register file.
Execution (EX): The ALU performs the required computation.
Memory Access (MEM): Data memory is accessed for load/store instructions.
Write-Back (WB): The result of the computation or memory access is written back to the register file.
# Data Hazard Handling
Forwarding/Bypassing: The processor includes forwarding paths to resolve data hazards by routing data directly from one pipeline stage to another without waiting for it to be written back to the register file.
Stall Mechanism: When forwarding is not possible, the processor can introduce stalls to delay the dependent instruction until the required data is available.
Integrated Signal (enable_forwarding): A signal enable_forwarding is included to control hazard resolution mechanisms:
- When set to 1, the processor resolves hazards using forwarding.
- When set to 0, the processor resolves hazards using stalls.
# Control Hazard Handling
Control Hazards: The processor includes mechanisms to handle control hazards, ensuring that the correct instruction is fetched and executed following branch and jump instructions.
