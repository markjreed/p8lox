%import Chunk
%import conv
%import txt
%import ValueArray
%import Value

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
            OP.CONSTANT -> { return constantInstruction("OP_CONSTANT", chunk, offset) }
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

    sub constantInstruction(uword name, uword chunk, uword offset) -> uword {
        ubyte constant = Chunk.read(chunk, offset + 1)
        txt.print_lj(16, name)
        txt.chrout(' ')
        txt.print_rj(4, conv.str_ub(constant))
        txt.print(" '")
        Value.print(ValueArray.read(Chunk.get_constants(chunk), constant))
        txt.chrout('\'')
        txt.nl()
        return offset + 2
    }
}
