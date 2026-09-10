%zeropage basicsafe
%import chunks
%import common
%import debug
%import textio
%import vm

main {
    alias Chunk = chunks.Chunk
    sub start() {
        txt.iso()
        vm.init()
        ^^Chunk chunk = memory("chunk", sizeof(Chunk), 1)
        chunks.init(chunk)
        uword constant = chunks.addConstant(chunk, 1.2)
        chunks.write(chunk, chunks.OpCode::CONSTANT2, 123)
        chunks.write(chunk, lsb(constant), 123)
        chunks.write(chunk, msb(constant), 123)
        chunks.write(chunk, chunks.OpCode::NEGATE, 125)
        chunks.write(chunk, chunks.OpCode::RETURN, 125)

        debug.disassembleChunk(chunk,"test chunk")
        void vm.interpret(chunk)
        vm.free()
        chunks.free(chunk)
    }
}
