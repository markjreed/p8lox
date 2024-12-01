%import Chunk
%import conv
%import txt
%import ValueArray
%import Value
%import VM

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
        uword lineNo = Chunk.readLine(chunk, offset)
        if offset > 0 and lineNo == Chunk.readLine(chunk, offset - 1) {
            txt.print("  |  ")
        } else {
            txt.print_rj(4, conv.str_uw(lineNo))
            txt.chrout(' ')
        }
        uword instruction = Chunk.read(chunk, offset)
        when instruction {
            OP.CONSTANT -> { return constantInstruction("OP_CONSTANT", chunk,  offset) }
            OP.NIL      -> { return simpleInstruction("OP_NIL",        offset) }
            OP.TRUE     -> { return simpleInstruction("OP_TRUE",        offset) }
            OP.FALSE    -> { return simpleInstruction("OP_FALSE",        offset) }
            OP.ADD      -> { return simpleInstruction("OP_ADD",        offset) }
            OP.SUBTRACT -> { return simpleInstruction("OP_SUBTRACT",   offset) }
            OP.MULTIPLY -> { return simpleInstruction("OP_MULTIPLY",   offset) }
            OP.DIVIDE   -> { return simpleInstruction("OP_DIVIDE",     offset) }
            OP.NEGATE   -> { return simpleInstruction("OP_NEGATE",     offset) }
            OP.RETURN   -> { return simpleInstruction("OP_RETURN",     offset) }
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
