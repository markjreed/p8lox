%zeropage basicsafe
%import Chunk
%import debug
%import syslib

main {
    sub start() {
        uword chunk = memory("main.start.chunk", Chunk.SIZE, 1)
        txt.lowercase()
        Chunk.init(chunk)
        Chunk.write(chunk, OP.RETURN)
        debug.disassembleChunk(chunk, "test chunk")
        Chunk.free(chunk)
        sys.exit(0)
    }
}
