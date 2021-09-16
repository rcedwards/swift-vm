# Building a Virtual Machine - Class 2

## Solution

[Contents.swift](./SwiftVM.playground/Contents.swift)

## Overview
* 20 bytes of memory
* 3 registers: 2 general purpose register and 1 for the “program counter”
* 5 instructions: 
	* `load_word  0x01 reg (addr)`
		*    Load value at given address into register
	* `store_word 0x02 reg (addr)`
		* Store the value in register at the given address
	* `add        0x03 reg1 reg2`
		* Set reg1 = reg1 + reg2
	* `sub        0x04 reg1 reg2`
		* Set reg1 = reg1 - reg2
	* `halt       0xff`
	* Parameters
		* each “parameter” is represented with a single byte. This means that all the instructions except `halt` (just one) will take three bytes. 
		* The `reg` parameters may only take one of two values, because our architecture only has 2 general purpose registers. We can choose any single byte value to identify the registers, we’ve chosen the values `0x01` and `0x02` (reserving value `0x00` for the program counter).

### Memory Layout
```
00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13
__ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __ __
INSTRUCTIONS ---------------------------^ OUT-^ IN-1^ IN-2^
```

### Program

#### “Assembly” Representation
```
load_word r1 (0x10)   # Load input 1 into register 1
load_word r2 (0x12)   # Load input 2 into register 2
add r1 r2             # Add the two registers, store the result in register 1
store_word r1 (0x0E)  # Store the value in register 1 to the output device
halt
```

#### Machine Representation (in hex)
_Don’t forget that machine code values are ultimately in binary; we only use a hexadecimal representation here to aid readability._
```
### 0x010110
### 0x010212
### 0x030102
### 0x02010e
### 0xff
```

#### In Our Memory Layout
```
00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13
01 01 10 01 02 12 03 01 02 02 01 0e ff __ __ __ __ __ __ __
INSTRUCTIONS —————————————--------------^ OUT-^ IN-1^ IN-2^
```

#### Example Run
Add 5281 to 12
```
00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13
01 01 10 01 02 12 03 01 02 02 01 0e ff __ __ __ a1 14 0c 00
INSTRUCTIONS ————————————--------------—^ OUT-^ IN-1^ IN-2^
```

_High Level Language Representation_
```
program = [
  0x01, 0x01, 0x10,
  0x01, 0x02, 0x12,
  0x03, 0x01, 0x02,
  0x02, 0x01, 0x0e,
  0xff,
  0x00,
  0x00, 0x00,
  0xa1, 0x14,
  0x0c, 0x00
]
```

Expected Output: 5293

### Assumptions

* The registers can hold 16 bit (2 byte) numbers directly. This means that you need to wrestle with endianness only when you load_store values from_to memory. 
* When running the add or subtract command you may use your language’s `+` and `-` operators directly to perform the operation. 
* start by supporting only positive numbers 
* if you have time, make your input and output representations 16-bit two’s complement numbers

### Exercise
* Write a VM
* Take input as a reference to 20 bytes of memory (array of 20)
* Model the FDE cycle in a loop
* Program counter should hold the address of the next instruction (starting at 0x00)
* Fetch - read all relevant information including the values in the params (registers/main memory)
* Decode - find out which operation should be performed
* Execute - perform the operation and update the program counter
* Operate on only the 20-bytes passed in and avoid using other main memory
* Write tests to take 20 bytes of input and inspect the array to ensure expected results

#### Stretch Goals
* Add a “branch if equal” instruction, which changes the program counter to a given address if the given register values are equal. Depending on your approach, this may require handling a 4-byte instruction, as well as expanding the overall memory size.
* Add an “add immediate” instruction, which adds a constant number (encoded within the instruction itself) to a given register.
* Support negative numbers using 16-bit twos complement.
* Consider porting your implementation to a lower level language, or using lower-level primitives in your existing language, to more easily encode your programs as true arrays (contiguous in memory) as as bytes in binary-encoded files.



#class