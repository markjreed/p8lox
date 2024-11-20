%import Chunk
%import INTERPRET_def
%import VM_def
%import Value
%import common
%import compiler
%import debug
%import txt

VM {
    %option merge
    const uword STACK_SIZE = 256
    uword vm = memory("VM.vm", SIZE, 1)
    uword stack = memory("VM.stack", STACK_SIZE * Value.SIZE, 1)

    sub resetStack() {
        set_stackTop(vm, stack)
    }

    sub push(uword value) {
        sys.memcopy(value, get_stackTop(vm), Value.SIZE)
        set_stackTop(vm, get_stackTop(vm) + Value.SIZE)
    }

    sub top() -> uword {
        return get_stackTop(vm) - Value.SIZE
    }

    sub pop(uword target) -> uword {
        set_stackTop(vm, get_stackTop(vm) - Value.SIZE)
        sys.memcopy(get_stackTop(vm), target, Value.SIZE)
        return target
    }

    sub init() { 
        resetStack()
    }
    sub free() { }
    sub interpret(uword source) -> ubyte {
        compiler.compile(source)
        return INTERPRET.OK
    }

    sub run() -> ubyte {
        sub READ_BYTE() -> ubyte {
            defer set_ip(vm, get_ip(vm) + 1)
            return @(get_ip(vm))
        }
        sub READ_CONSTANT() -> uword {
            return ValueArray.read(Chunk.get_constants(get_chunk(vm)), READ_BYTE() as uword)
        }
        sub BINARY_OP(uword subroutine) -> bool {
            uword oldTop = memory("oldTop", Value.SIZE, 1)
            void pop(oldTop)
            return Value.binOp(subroutine, top(), oldTop, top())
        }
        repeat {
            if common.DEBUG_TRACE_EXECUTION {
                txt.chrout(' ')
                uword slot = stack
                while slot < get_stackTop(vm) {
                    txt.print("[ ")
                    Value.print(slot)
                    txt.print(" ]")
                    slot += Value.SIZE
                }
                txt.nl()
                void debug.disassembleInstruction(get_chunk(vm), get_ip(vm) - Chunk.get_code(get_chunk(vm)))
            }
            ubyte instruction = READ_BYTE()
            when instruction {
                OP.CONSTANT -> { 
                    uword constant = READ_CONSTANT()
                    push(constant)
                }
                OP.ADD      -> { if not BINARY_OP(&Value.add) { return INTERPRET.RUNTIME_ERROR } }
                OP.SUBTRACT -> { if not BINARY_OP(&Value.subtract) { return INTERPRET.RUNTIME_ERROR } }
                OP.MULTIPLY -> { if not BINARY_OP(&Value.multiply) { return INTERPRET.RUNTIME_ERROR } }
                OP.DIVIDE   -> { if not BINARY_OP(&Value.divide) { return INTERPRET.RUNTIME_ERROR } }
                OP.NEGATE   -> { if not Value.negate(top()) { return INTERPRET.RUNTIME_ERROR } }
                OP.RETURN   -> { 
                    Value.print(pop(Value.buffer))
                    txt.nl()
                    return INTERPRET.OK
                }
            }
        }
    }
}
