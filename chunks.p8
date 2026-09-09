%import mem

chunks {
    struct Chunk {
        uword count
        uword capacity
        ^^ubyte code
    }

    sub init(^^Chunk chunk) {
        chunk.count = 0
        chunk.capacity = 0
    }

    sub write(^^Chunk chunk, ubyte value) {
        if chunk.capacity < chunk.count + 1 {
            uword old_capacity = chunk.capacity
            chunk.capacity = mem.grow(old_capacity)
            chunk.code = mem.alloc(chunk.code, old_capacity, chunk.capacity)
            if chunk.code == 0 {
                sys.exit(1)
            }
        }
        @(chunk.code + chunk.count) = value
        chunk.count += 1
    }

    sub free(^^Chunk chunk) {
        mem.alloc(chunk.code, chunk.capacity, 0)
        init(chunk)
    }

}
