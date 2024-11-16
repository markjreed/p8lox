%zeropage basicsafe
%import Chunk
%import Value
%import VM
%import debug
%import syslib

main {
    sub start() {
        VM.init()
        uword chunk = memory("main.start.chunk", Chunk.SIZE, 1)
        txt.lowercase()
        Chunk.init(chunk)
        ubyte constant = Chunk.addConstant(chunk, Value.makeReal(1.2)) as ubyte
        Chunk.write(chunk, OP.CONSTANT, 123)
        Chunk.write(chunk, constant, 123)

        constant = Chunk.addConstant(chunk, Value.makeReal(3.4)) as ubyte
        Chunk.write(chunk, OP.CONSTANT, 123);
        Chunk.write(chunk, constant, 123);

        Chunk.write(chunk, OP.ADD, 123)

        constant = Chunk.addConstant(chunk, Value.makeReal(5.6)) as ubyte
        Chunk.write(chunk, OP.CONSTANT, 123);
        Chunk.write(chunk, constant, 123);

        Chunk.write(chunk, OP.DIVIDE, 123)
        Chunk.write(chunk, OP.NEGATE, 123)

        Chunk.write(chunk, OP.RETURN, 123)
        debug.disassembleChunk(chunk, "test chunk")
        VM.interpret(chunk)
        VM.free()
        Chunk.free(chunk)
        sys.exit(0)
    }
}
