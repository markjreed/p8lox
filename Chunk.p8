%import memory
%import syslib
%import Chunk_def
%import ValueArray

OP {
    const ubyte CONSTANT = 0
    const ubyte ADD      = 1
    const ubyte SUBTRACT = 2
    const ubyte MULTIPLY = 3
    const ubyte DIVIDE   = 4
    const ubyte NEGATE   = 5
    const ubyte RETURN   = 6
}

Chunk {
    %option merge
    sub init(uword chunk) {
        set_count(chunk, 0)
        set_capacity(chunk, 0)
        set_code(chunk, 0)
        set_lines(chunk, 0)
        ValueArray.init(get_constants(chunk))
    }

    sub write(uword chunk, ubyte value, uword line) {
        uword oldCapacity = get_capacity(chunk)
        if oldCapacity < get_count(chunk) + 1 {
            uword newCapacity = memory.GROW_CAPACITY(oldCapacity)
            set_capacity(chunk, newCapacity)
            set_code(chunk, 
                memory.GROW_ARRAY(sys.sizeof_ubyte, get_code(chunk), 
                                  oldCapacity, newCapacity))
            set_lines(chunk, 
                memory.GROW_ARRAY(sys.sizeof_uword, get_lines(chunk), 
                                  oldCapacity, newCapacity))
        }
        @(get_code(chunk) + get_count(chunk)) = value
        pokew(get_lines(chunk) + get_count(chunk) * sys.sizeof_uword, line)
        set_count(chunk, get_count(chunk) + 1)
    }

    sub read(uword chunk, uword offset) -> ubyte {
        return @(get_code(chunk) + offset)
    }

    sub readLine(uword chunk, uword offset) -> uword {
        return peekw(get_lines(chunk) + offset * sys.sizeof_uword)
    }

    sub addConstant(uword chunk, uword value) -> uword {
        ValueArray.write(get_constants(chunk), value)
        return ValueArray.get_count(get_constants(chunk)) - 1
    }

    sub free(uword chunk) {
        memory.FREE_ARRAY(sys.sizeof_ubyte, get_code(chunk), get_capacity(chunk))
        memory.FREE_ARRAY(sys.sizeof_uword, get_lines(chunk), get_capacity(chunk))
        ValueArray.free(get_constants(chunk))
        init(chunk)
    }
}
