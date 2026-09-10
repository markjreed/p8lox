%import mem
%import values

chunks {
    alias Value = values.Value
    alias ValueArray = values.ValueArray

    struct Line {
        uword number
        ubyte count
    }

    struct Chunk {
        uword code_count
        uword code_capacity
        ^^ubyte code
        uword line_count
        uword line_capacity
        ^^Line lines
        ^^ValueArray constants
    }

    enum OpCode {
        CONSTANT,
        CONSTANT2,
        RETURN
    }

    sub init(^^Chunk chunk) {
        chunk.code_count = 0
        chunk.code_capacity = 0
        chunk.code = 0
        chunk.line_count = 0
        chunk.line_capacity = 0
        chunk.lines = 0
        chunk.constants = mem.alloc(0, 0, sizeof(ValueArray))
        values.initArray(chunk.constants)
    }

    sub write(^^Chunk chunk, ubyte value, uword line) {
        if chunk.code_capacity < chunk.code_count + 1 {
            uword old_code_capacity = chunk.code_capacity
            chunk.code_capacity = mem.grow(old_code_capacity)
            chunk.code = mem.alloc(chunk.code, old_code_capacity, chunk.code_capacity)
        }
        @(chunk.code + chunk.code_count) = value
        bool need_line = false
        ^^Line last
        if chunk.line_count == 0 {
            need_line = true
        } else {
            last = chunk.lines + chunk.line_count - 1
            need_line = last.number != line
        }
        if need_line {
            if chunk.line_capacity < chunk.line_count + 1 {
                uword old_line_capacity = chunk.line_capacity
                chunk.line_capacity = mem.grow(old_line_capacity)
                chunk.lines = mem.alloc(chunk.lines, 
                                        old_line_capacity * sizeof(Line),
                                        chunk.line_capacity * sizeof(Line))
            }
            last = chunk.lines + chunk.line_count 
            last.number = line
            last.count = 1
            chunk.line_count += 1
        } else {
            last.count += 1
        }
        chunk.code_count += 1
    }
   
    sub addConstant(^^Chunk chunk, float value) -> uword {
        values.writeArray(chunk.constants, values.makeFloat(value))
        return chunk.constants.count - 1
    }

    sub free(^^Chunk chunk) {
        values.freeArray(chunk.constants)
        void mem.alloc(chunk.code, chunk.code_capacity, 0)
        void mem.alloc(chunk.lines, chunk.code_capacity * 2, 0)
        init(chunk)
    }

}
