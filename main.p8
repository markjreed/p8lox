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
        chunks.write(chunk, chunks.OpCode::RETURN)
        debug.disassemble_chunk(chunk,"test chunk")
        chunks.free(chunk)
    }
}
