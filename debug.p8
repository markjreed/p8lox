%import Chunk
%import txt

debug {
    sub disassembleChunk(uword chunk, uword name) {
        txt.println_ss("== ", name, " ==")
        uword offset = 0
        while offset < Chunk.get_count(chunk) {
            offset = disassembleInstruction(chunk, offset)
        }
    }

    sub disassembleInstruction(uword chunk, uword offset) -> uword {
        txt.print_uwzp(4, offset)
        txt.chrout(' ')
        uword instruction = Chunk.read(chunk, offset)
        when instruction {
            OP.RETURN -> { return simpleInstruction("OP_RETURN", offset) }
            else -> { 
                txt.println_suw("Unknown opcode ", instruction, 0)
                return offset + 1
            }
        }
    }

    sub simpleInstruction(uword name, uword offset) -> uword {
        txt.println(name)
        return offset + 1
    }
}
