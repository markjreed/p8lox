%import Chunk
%import VM_def
%import Value
%import common
%import debug
%import txt

INTERPRET {
    const ubyte OK = 0
    const ubyte COMPILE_ERROR = 1
    const ubyte RUNTIME_ERROR = 2
}

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

    sub pop() -> uword {
        set_stackTop(vm, get_stackTop(vm) - Value.SIZE)
        return get_stackTop(vm)
    }

    sub init() { 
        resetStack()
    }
    sub free() { }
    sub interpret(uword chunk) -> ubyte {
        set_chunk(vm, chunk)
        set_ip(vm, Chunk.get_code(chunk))
        return run()
    }

    sub run() -> ubyte {
        sub READ_BYTE() -> ubyte {
            defer set_ip(vm, get_ip(vm) + 1)
            return @(get_ip(vm))
        }
        sub READ_CONSTANT() -> uword {
            return ValueArray.read(Chunk.get_constants(get_chunk(vm)), READ_BYTE() as uword)
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
                OP.NEGATE -> { Value.negate(top()) }
                OP.RETURN  -> { 
                    Value.print(pop())
                    txt.nl()
                    return INTERPRET.OK
                }
            }
        }
    }
}
