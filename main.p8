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
        chunks.write(chunk, chunks.OpCode::CONSTANT, 123)
        chunks.write(chunk, lsb(constant), 123)

        constant = chunks.addConstant(chunk, 3.4)
        chunks.write(chunk, chunks.OpCode::CONSTANT, 123)
        chunks.write(chunk, lsb(constant), 123)

        chunks.write(chunk, chunks.OpCode::ADD, 123)

        constant = chunks.addConstant(chunk, 5.6)
        chunks.write(chunk, chunks.OpCode::CONSTANT, 123)
        chunks.write(chunk, lsb(constant), 123)

        chunks.write(chunk, chunks.OpCode::DIVIDE, 123)

        chunks.write(chunk, chunks.OpCode::NEGATE, 123)

        chunks.write(chunk, chunks.OpCode::RETURN, 123)

        debug.disassembleChunk(chunk,"test chunk")
        void vm.interpret(chunk)
        vm.free()
        chunks.free(chunk)
    }
}
