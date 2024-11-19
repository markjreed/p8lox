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
        ubyte constant = Chunk.addConstant(chunk, Value.makeString("Hello")) as ubyte
        Chunk.write(chunk, OP.CONSTANT, 123)
        Chunk.write(chunk, constant, 123)

        constant = Chunk.addConstant(chunk, Value.makeString(", world!")) as ubyte
        Chunk.write(chunk, OP.CONSTANT, 123);
        Chunk.write(chunk, constant, 123);

        Chunk.write(chunk, OP.ADD, 123)

        Chunk.write(chunk, OP.RETURN, 123)

        VM.interpret(chunk)
        VM.free()
        Chunk.free(chunk)
        sys.exit(0)
    }
}
