import Foundation

var memory: [UInt8] = [
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

let vm = VM(data: memory)
vm.run()

enum OpCode: UInt8 {
    case hault = 0xff
}

class VM {
    var data: [UInt8]
    var programCounter: UInt8 {
        data.last!
    }
    
    init(data: [UInt8]) {
        self.data = data
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
