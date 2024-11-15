%zeropage basicsafe
%import syslib
%import Chunk

main {
    sub start() {
        uword chunk = memory("main.start.chunk", Chunk.SIZE, 1)
        Chunk.init(chunk)
        Chunk.write(chunk, OP.RETURN)
        Chunk.free(chunk)
        sys.exit(0)
    }
}
