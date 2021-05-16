A superscalar implementation of an original instruction set architecture with intended hardware support for OS functionality.

Instruction breakdown:

First byte: Conditional Logic

First 2 bits: Condition Form
00 - Condition Passes
01 - Condition if last condition passed
10 - Else: condition if last condition did not pass
11 - New condition on instruction

Next 3 bits: Comparison Form
First bit: pass if less than
Second bit: pass if equal
Third bit: pass if greater than

Next 3 bits: Comp Operand Form
First bit: signed comparison
00 - Both operands are registers
01 - Operand B is immediate
10 - Operand A is immediate
11 - Both operands are immediate

Second byte: Else Jump
(A signed jump in instructions, not bytes)
(Can jump to +- 127 instructions of the current instruction address)

Third byte: instruction logic
First bit: ISA extension instruction
Second bit: Operation is signed
Remaining 6 bits: Instruction opcode

Fourth byte: Extension logic
(Only applicable if first bit of second byte is 1)
8 bits: Extension opcode

Remainder bytes: Operand logic
00 - Both operands are registers
01 - Operand A is an immediate
10 - Operand B is an immediate
11 - Both operands are immediates

Next 6 bits: Comp Operand A register
Next 6 bits: Comp Operand B register
Next 6 bits: Exec Operand A register
Next 6 bits: Exec Operand B register
Next 6 bits: Store/Destination Register


Base ISA:
Arithmetic:
ADD - Add                    - 000011 - rd = r1 + r2
SUB - Subtract               - 000010 - rd = r1 - r2
Boolean:
AND - Bitwise AND            - 001001 - rd = r1 & r2
OR  - Bitwise OR             - 001010 - rd = r1 | r2
XOR - Bitwise XOR            - 001100 - rd = r1 ^ r2
Shift:
SHL - Shift Left             - 000100 - rd = r1 << r2
SHR - Shift Right            - 000101 - rd = r1 >> r2
Memory Load:
LDL - Load Long (64 bits)    - 111000 - rd = r1(r2)
LDW - Load Word (32 bits)    - 110100 - rd = r1(r2)
LDH - Load Half (16 bits)    - 110010 - rd = r1(r2)
LDB - Load Byte (8 bits)     - 110001 - rd = r1(r2)
Memory Store:
STL - Store Long (64 bits)   - 101000 - r1(r2) = rs
STW - Store Word (32 bits)   - 100100 - r1(r2) = rs
STH - Store Half (16 bits)   - 100010 - r1(r2) = rs
STB - Store Byte (8 bits)    - 100001 - r1(r2) = rs
Compare:
SLT - Set Less Than          - 010001 - rd = r1 < r2
LTE - Set Less Than or Equal - 010011 - rd = r1 <= r2
SEQ - Set Equal              - 010010 - rd = r1 == r2
SNE - Set Not Equal          - 010100 - rd = r1 != r2
Else:
NOP - No Op                  - 000000


Immediate Handling:
Instruction
Comp Operand A Immediate (If exists, else skip)
Comp Operand B Immediate (If exists, else skip)
Exec Operand A Immediate (If exists, else skip)
Exec Operand B Immediate (If exists, else skip)
Instruction


Register Allocation:
x0  - fixed at 0
x63 - program counter
