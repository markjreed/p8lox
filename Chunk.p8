%import memory
%import syslib
%import Chunk_def
%import OP_def
%import ValueArray

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
                memory.GROW_ARRAY(sys.SIZEOF_UBYTE, get_code(chunk), 
                                  oldCapacity, newCapacity))
            set_lines(chunk, 
                memory.GROW_ARRAY(sys.SIZEOF_UWORD, get_lines(chunk), 
                                  oldCapacity, newCapacity))
        }
        @(get_code(chunk) + get_count(chunk)) = value
        pokew(get_lines(chunk) + get_count(chunk) * sys.SIZEOF_UWORD, line)
        set_count(chunk, get_count(chunk) + 1)
    }

    sub read(uword chunk, uword offset) -> ubyte {
        return @(get_code(chunk) + offset)
    }

    sub readLine(uword chunk, uword offset) -> uword {
        return peekw(get_lines(chunk) + offset * sys.SIZEOF_UWORD)
    }

    sub addConstant(uword chunk, uword value) -> uword {
        ValueArray.write(get_constants(chunk), value)
        return ValueArray.get_count(get_constants(chunk)) - 1
    }

    sub free(uword chunk) {
        memory.FREE_ARRAY(sys.SIZEOF_UBYTE, get_code(chunk), get_capacity(chunk))
        memory.FREE_ARRAY(sys.SIZEOF_UWORD, get_lines(chunk), get_capacity(chunk))
        ValueArray.free(get_constants(chunk))
        init(chunk)
    }
}
