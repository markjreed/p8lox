%zeropage basicsafe
%import chunks
%import debug
%import textio

main {
    alias Chunk = chunks.Chunk
    sub start() {
        txt.iso()
        ^^Chunk chunk = memory("chunk", sizeof(Chunk), 1)
        chunks.init(chunk)
        uword constant = chunks.addConstant(chunk, 1.2)
        chunks.write(chunk, chunks.OpCode::CONSTANT2, 123)
        chunks.write(chunk, lsb(constant), 123)
        chunks.write(chunk, msb(constant), 123)
        chunks.write(chunk, chunks.OpCode::RETURN, 123)

        debug.disassembleChunk(chunk,"test chunk")
        chunks.free(chunk)
    }
}
