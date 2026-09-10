%import chunks
%import common
%import debug
%import values

vm {
    alias Chunk = chunks.Chunk
    alias Value = values.Value
    alias ValueArray = values.ValueArray

    struct VM {
        ^^Chunk chunk
        uword ip
    }

    ^^VM theVM = memory("theVM", sizeof(VM), 1)

    enum InterpretResult {
        OK, COMPILE_ERROR, RUNTIME_ERROR
    }

    sub init() {
    }

    sub free() {
    }

    sub interpret(^^Chunk chunk) -> ubyte {
        theVM.chunk = chunk
        theVM.ip = chunk.code
        return run()
    }

    sub run() -> ubyte {
        ubyte instruction
        ^^Value value
        repeat {
            if common.DEBUG_TRACE_EXECUTION {
                void debug.disassembleInstruction(theVM.chunk,
                        (theVM.ip as uword) - (theVM.chunk.code as uword))
            }
            instruction = @(theVM.ip)
            theVM.ip += 1
            when instruction {
               chunks.OpCode::RETURN -> return InterpretResult::OK
               chunks.OpCode::CONSTANT -> {
                    value = theVM.chunk.constants.values + @(theVM.ip)
                    theVM.ip += 1
                    values.print(value)
               }
               chunks.OpCode::CONSTANT2 -> {
                    value = theVM.chunk.constants.values + peekw(theVM.ip)
                    theVM.ip += 2
                    values.print(value)
               }
            }
        }
    }
                



}
