import Foundation

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

let instructionRange = 0x00...0x0d
let outputRange = 0x0e...0x0f
let inputRange = 0x10...0x13

let vm = VM(memory: sampleInput)
vm.run()

enum OpCode: UInt8 {
    case loadWord = 0x01
    case storeWord = 0x02
    case add = 0x03
    case sub = 0x04
    case hault = 0xff
}

enum Register: UInt8, CaseIterable {
    case programCounter = 0x00
    case generalPurpose1 = 0x01
    case generalPurpose2 = 0x02
}

class VM {
    var programMemory: [UInt8]
    var registers: [Register: UInt16]
    
    var programCounter: UInt16 {
        registers[.programCounter]!
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
        while programCounter != OpCode.hault.rawValue {
            fetch()
            decode()
            execute()
        }
    }
    
    private func fetch() {
        
    }
    
    private func decode() {
        
    }
    
    private func execute() {
        
    }
}
