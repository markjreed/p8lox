%import memory
%import syslib
%import Chunk_def

OP {
    const ubyte RETURN = 0
}

Chunk {
    %option merge
    sub init(uword chunk) {
        set_count(chunk, 0)
        set_capacity(chunk, 0)
        set_code(chunk, 0)
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

    sub free(uword chunk) {
        memory.FREE_ARRAY(sys.sizeof_ubyte, get_code(chunk), get_capacity(chunk))
        init(chunk)
    }
}
