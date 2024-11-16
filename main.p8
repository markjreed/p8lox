%zeropage basicsafe
%import Chunk
%import Value
%import debug
%import syslib

main {
    sub start() {
        uword chunk = memory("main.start.chunk", Chunk.SIZE, 1)
        txt.lowercase()
        Chunk.init(chunk)
        ubyte constant = Chunk.addConstant(chunk, Value.real(1.2)) as ubyte
        Chunk.write(chunk, OP.CONSTANT)
        Chunk.write(chunk, constant)
        debug.disassembleChunk(chunk, "test chunk")
        Chunk.free(chunk)
        sys.exit(0)
    }
}
