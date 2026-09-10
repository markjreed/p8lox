%import mem
%import values

chunks {
    alias Value = values.Value
    alias ValueArray = values.ValueArray

    struct Chunk {
        uword count
        uword capacity
        ^^ubyte code
        ^^uword lines
        ^^ValueArray constants
    }

    enum OpCode {
        CONSTANT,
        RETURN
    }

    sub init(^^Chunk chunk) {
        chunk.count = 0
        chunk.capacity = 0
        chunk.code = 0
        chunk.lines = 0
        chunk.constants = mem.alloc(0, 0, sizeof(ValueArray))
        values.initArray(chunk.constants)
    }

    sub write(^^Chunk chunk, ubyte value, uword line) {
        if chunk.capacity < chunk.count + 1 {
            uword old_capacity = chunk.capacity
            chunk.capacity = mem.grow(old_capacity)
            chunk.code = mem.alloc(chunk.code, old_capacity, chunk.capacity)
            chunk.lines = mem.alloc(chunk.lines, old_capacity * 2, chunk.capacity * 2)
        }
        @(chunk.code + chunk.count) = value
        pokew(chunk.lines + chunk.count, line)
        chunk.count += 1
    }
   
    sub addConstant(^^Chunk chunk, float value) -> ubyte {
        values.writeArray(chunk.constants, values.makeFloat(value))
        uword constant = chunk.constants.count - 1
        txt.print("constant = ")
        txt.print_uw(constant)
        if constant > 255 {
            txt.print("too many constants")
            sys.exit(1)
        }
        return lsb(constant)
    }


    sub free(^^Chunk chunk) {
        values.freeArray(chunk.constants)
        void mem.alloc(chunk.code, chunk.capacity, 0)
        void mem.alloc(chunk.lines, chunk.capacity * 2, 0)
        init(chunk)
    }

}
