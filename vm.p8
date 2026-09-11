%import chunks
%import common
%import debug
%import values

vm {
    alias Chunk = chunks.Chunk
    alias Value = values.Value
    alias ValueArray = values.ValueArray

    const uword STACK_MAX = 256

    struct VM {
        ^^Chunk chunk
        uword ip
        ^^Value stack
        ^^Value stackTop
    }

    ^^VM theVM = memory("theVM", sizeof(VM), 1)

    enum InterpretResult {
        OK, COMPILE_ERROR, RUNTIME_ERROR
    }

    sub init() {
        theVM.stack = memory("stack", STACK_MAX * sizeof(Value), 1)
        resetStack()
    }

    sub resetStack() {
        theVM.stackTop = theVM.stack
    }

    sub free() {
    }

    sub interpret(^^Chunk chunk) -> ubyte {
        theVM.chunk = chunk
        theVM.ip = chunk.code
        return run()
    }

    sub pushValue(^^Value value) {
        void values.assign(theVM.stackTop, value)
        theVM.stackTop = (theVM.stackTop as ^^ubyte + sizeof(Value)) as ^^Value
    }

    sub popValue() -> ^^Value {
        theVM.stackTop = (theVM.stackTop as ^^ubyte - sizeof(Value)) as ^^Value 
        return theVM.stackTop
    }

    sub run() -> ubyte {
        ubyte instruction
        ^^Value value, other
        repeat {
            if common.DEBUG_TRACE_EXECUTION {
                txt.chrout(' ')
                value = theVM.stack
                while value < theVM.stackTop {
                    txt.chrout('[') values.print(value) txt.chrout(']')
                    value++
                }
                txt.nl()
                void debug.disassembleInstruction(theVM.chunk,
                        (theVM.ip as uword) - (theVM.chunk.code as uword))
            }
            instruction = @(theVM.ip)
            theVM.ip += 1
            when instruction {
               chunks.OpCode::RETURN -> {
                     value = popValue()
                     values.print(value)
                     values.free(value)
                     txt.nl()
                     return InterpretResult::OK
               }
               chunks.OpCode::CONSTANT -> {
                    value = theVM.chunk.constants.values + @(theVM.ip)
                    theVM.ip += 1
                    pushValue(value)
               }
               chunks.OpCode::CONSTANT2 -> {
                    value = theVM.chunk.constants.values + peekw(theVM.ip)
                    theVM.ip += 2
                    pushValue(value)
               }
               chunks.OpCode::NEGATE -> {
                    value = popValue()
                    other = values.negate(value)
                    pushValue(other)
                    values.free(value)
                }
               chunks.OpCode::ADD -> {
                    value = popValue()
                    other = popValue()
                    pushValue(values.add(value, other))
                    values.free(value)
                    values.free(other)
                }
               chunks.OpCode::SUBTRACT -> {
                    other = popValue()
                    value = popValue()
                    pushValue(values.subtract(value, other))
                    values.free(value)
                    values.free(other)
                }
               chunks.OpCode::MULTIPLY -> {
                    value = popValue()
                    other = popValue()
                    pushValue(values.multiply(value, other))
                    values.free(value)
                    values.free(other)
                }
               chunks.OpCode::DIVIDE -> {
                    other = popValue()
                    value = popValue()
                    pushValue(values.divide(value, other))
                    values.free(value)
                    values.free(other)
                }
            }
        }
    }

}
