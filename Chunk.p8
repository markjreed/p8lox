%import memory
%import syslib
%import Chunk_def
%import ValueArray

OP {
    const ubyte CONSTANT = 0
    const ubyte RETURN   = 1
}

Chunk {
    %option merge
    sub init(uword chunk) {
        set_count(chunk, 0)
        set_capacity(chunk, 0)
        set_code(chunk, 0)
        ValueArray.init(get_constants(chunk))
    }

    sub write(uword chunk, ubyte value) {
        uword oldCapacity = get_capacity(chunk)
        if oldCapacity < get_count(chunk) + 1 {
            set_capacity(chunk, memory.GROW_CAPACITY(oldCapacity))
            set_code(chunk, 
                memory.GROW_ARRAY(sys.sizeof_ubyte, get_code(chunk), 
                                  oldCapacity, get_capacity(chunk)))
        }
        @(get_code(chunk) + get_count(chunk)) = value
        set_count(chunk, get_count(chunk) + 1)
    }

    sub read(uword chunk, uword offset) -> ubyte {
        return @(get_code(chunk) + offset)
    }

    sub addConstant(uword chunk, uword value) -> uword {
        ValueArray.write(get_constants(chunk), value)
        return ValueArray.get_count(get_constants(chunk)) - 1

    }

    sub free(uword chunk) {
        memory.FREE_ARRAY(sys.sizeof_ubyte, get_code(chunk), get_capacity(chunk))
        ValueArray.free(get_constants(chunk))
        init(chunk)
    }
}
