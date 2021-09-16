import Foundation

// MARK: - Constants

enum Constants {
    static let instructionRange = 0x00...0x0d
    static let outputRange = 0x0e...0x0f
    static let inputRange = 0x10...0x13
}

// MARK: - Instructions

enum Instruction: CustomDebugStringConvertible {
    case loadWord(register: Register, address: UInt8)
    case storeWord(register: Register, address: UInt8)
    case add(registerA: Register, registerB: Register)
    case sub(registerA: Register, registerB: Register)
    case hault
    
    // UInt16 used to match program counter
    var counterIncrementCount: UInt16 {
        switch self {
        case .hault:
            return 1
        case .add, .loadWord, .storeWord, .sub:
            return 3
        }
    }
    
    enum OpCode: UInt8 {
        case load = 0x01
        case store = 0x02
        case add = 0x03
        case sub = 0x04
        case hault = 0xff
    }
    
    enum Error: Swift.Error, LocalizedError {
        case instructionOutOfBounds
        case unknownInstruction
        case paramMismatchForInstruction
        
        var errorDescription: String? {
            switch self {
            case .instructionOutOfBounds:
                return "Program counter, or expected parameters, are out of the instruction bounds."
            case .unknownInstruction:
                return "Unrecognized instruction"
            case .paramMismatchForInstruction:
                return "The instruction was supplied with the incorrect parameters"
            }
        }
    }
    
    init(memory: [UInt8], programCounter: UInt16) throws {
        let pcIndex = Int(programCounter) // Cast to an Int for indexing into memory: [UInt8]
        guard Constants.instructionRange.contains(pcIndex) else {
            throw Error.instructionOutOfBounds
        }
        guard let opCode = OpCode(rawValue: memory[pcIndex]) else {
            throw Error.unknownInstruction
        }
        
        guard opCode != .hault else {
            self = .hault; return
        }
        
        guard Constants.instructionRange.contains(pcIndex + 1),
              Constants.instructionRange.contains(pcIndex + 2) else {
            throw Error.instructionOutOfBounds
        }
        
        switch opCode {
        case .add:
            guard let param1 = Register(rawValue: memory[pcIndex + 1]),
                  let param2 = Register(rawValue: memory[pcIndex + 2]) else {
                throw Error.paramMismatchForInstruction
            }
            self = .add(registerA: param1, registerB: param2)
            
        case .sub:
            guard let param1 = Register(rawValue: memory[pcIndex + 1]),
                  let param2 = Register(rawValue: memory[pcIndex + 2]) else {
                throw Error.paramMismatchForInstruction
            }
            self = .sub(registerA: param1, registerB: param2)
            
        case .load:
            guard let register = Register(rawValue: memory[pcIndex + 1]),
                  Constants.inputRange.contains(Int(memory[pcIndex + 2])) else {
                throw Error.paramMismatchForInstruction
            }
            self = .loadWord(register: register, address: memory[pcIndex + 2])
            
        case .store:
            guard let register = Register(rawValue: memory[pcIndex + 1]),
                  Constants.outputRange.contains(Int(memory[pcIndex + 2])) else {
                throw Error.paramMismatchForInstruction
            }
            self = .storeWord(register: register, address: memory[pcIndex + 2])
            
        case .hault:
            preconditionFailure("Hault handled above in guard.")
        }
    }
    
    var debugDescription: String {
        switch self {
        case .hault:
            return "HAULT"
        case .add(registerA: let regA, registerB: let regB):
            return "ADD \(regA) + \(regB) store in \(regA)"
        case .sub(registerA: let regA, registerB: let regB):
            return "SUB \(regA) - \(regB) store in \(regA)"
        case .loadWord(register: let reg, address: let address):
            return "LOAD value at \(String(format: "0x%02X", address)) into \(reg)"
        case .storeWord(register: let reg, address: let address):
            return "STORE value in \(reg) to \(String(format: "0x%02X", address))"
        }
    }
}

// MARK: - Registers

enum Register: UInt8, CaseIterable, CustomDebugStringConvertible {
    case programCounter = 0x00
    case generalPurpose1 = 0x01
    case generalPurpose2 = 0x02
    
    var debugDescription: String {
        switch self {
        case .generalPurpose1:
            return "GP1"
        case .generalPurpose2:
            return "GP2"
        case .programCounter:
            return "PC"
        }
    }
}

// MARK: - Sample Input Parsing

var sampleInput: [UInt8] = [
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

do {
    print("=============TESTING-DECODING===================")
    print(try Instruction(memory: sampleInput, programCounter: 0x00))
    print(try Instruction(memory: sampleInput, programCounter: 0x03))
    print(try Instruction(memory: sampleInput, programCounter: 0x06))
    print(try Instruction(memory: sampleInput, programCounter: 0x09))
    print(try Instruction(memory: sampleInput, programCounter: 0x0c))
    print("=============TESTING-DECODING===================\n")
} catch {
    print(error)
}

// MARK: - VM

class VM {
    var programMemory: [UInt8]
    var output: UInt16 {
        let lowBits = UInt16(programMemory[Constants.outputRange.lowerBound])
        let highBits = UInt16(programMemory[Constants.outputRange.upperBound]) * 256
        return lowBits + highBits
    }
    
    private var registers: [Register: UInt16]
    private var hasHaulted = false {
        didSet {
            print("Program-Output: \(output)")
            print("=============Program-Execution-Ended============")
        }
    }
    
    private var programCounter: UInt16 {
        get { registers[.programCounter]! }
        set { registers[.programCounter] = newValue }
    }
    
    init(memory: [UInt8]) {
        self.programMemory = memory
        self.registers = [
            .programCounter: 0x0000,
            .generalPurpose1: 0x0000,
            .generalPurpose2: 0x0000
        ]
    }
    
    func run() {
        print("=============Starting-Program-Execution=========")
        while !hasHaulted {
            do {
                let instruction = try decode()
                execute(instruction)
                programCounter += instruction.counterIncrementCount
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    
    private func decode() throws -> Instruction {
        try Instruction(memory: programMemory, programCounter: programCounter)
    }
    
    private func execute(_ instruction: Instruction) {
        print(instruction.debugDescription)
        switch instruction {
        case .hault:
            hasHaulted = true
        case .add(registerA: let rga, registerB: let rgb):
            registers[rga]! = registers[rga]! + registers[rgb]!
        case .sub(registerA: let rga, registerB: let rgb):
            registers[rga]! = registers[rga]! - registers[rgb]!
        case .loadWord(register: let register, address: let address):
            // Also programMemory indicies are cast to expected array index type of Int.
            let addressIndex = Int(address)
            let lowBits = UInt16(programMemory[addressIndex])
            let highBits = UInt16(programMemory[addressIndex + 1]) * 256
            registers[register]! = lowBits + highBits
        case .storeWord(register: let register, address: let address):
            let registerValue = registers[register]!
            let lowBits = UInt8(registerValue % 256)
            let highBits = UInt8(registerValue / 256)
            let lowIndex = Int(address)
            let highIndex = lowIndex + 1
            programMemory[lowIndex] = lowBits
            programMemory[highIndex] = highBits
        }
    }
}

let vm = VM(memory: sampleInput)
vm.run()
