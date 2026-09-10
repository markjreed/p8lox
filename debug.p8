%encoding iso

%import chunks
%import conv
%import strings
%import textio

debug {
    alias Chunk = chunks.Chunk
    sub disassembleChunk(^^Chunk chunk, ^^ubyte name) {
        txt.print("== ") txt.print(name) txt.print(" ==\n")
        uword offset = 0
        while offset < chunk.count {
            offset = disassembleInstruction(chunk, offset)
        }
    }

    sub print_uwpad(uword value, ubyte width) {
        ubyte actual = strings.length(conv.str_uw(value))
        while actual < width {
            txt.chrout('0')
            actual += 1
        }
        txt.print_uw(value)
    }

    sub print_pad(str value, ubyte width) {
        ubyte actual = strings.length(value)
        txt.print(value)
        while actual < width {
            txt.chrout(' ')
            actual += 1
        }
    }

    sub disassembleInstruction(^^Chunk chunk, uword offset) -> uword {
        print_uwpad(offset, 4)
        txt.chrout(' ')
        if offset > 0 and peekw(chunk.lines+offset) == peekw(chunk.lines+offset - 1) {
            txt.print(" |  ")
        } else {
            print_uwpad(peekw(chunk.lines+offset), 4)
        }
        txt.chrout(' ')
        ubyte instruction = @(chunk.code + offset)
        when instruction {
            chunks.OpCode::CONSTANT -> return constantInstruction("CONSTANT", chunk, offset)
            chunks.OpCode::CONSTANT2 -> return constant2Instruction("CONSTANT2", chunk, offset)
            chunks.OpCode::RETURN -> return simpleInstruction("RETURN", offset)
            else -> { 
                txt.print("unknown opcode ") txt.print_ub(instruction) txt.nl()
                return offset + 1
            }
        }
    }

    sub simpleInstruction(str label, uword offset) -> uword {
        txt.print(label)
        txt.nl()
        return offset + 1
    }

    sub constantInstruction(str label, ^^Chunk chunk, uword offset) -> uword {
        ubyte constant = @(chunk.code + offset + 1)
        print_pad(label, 17)
        print_uwpad(constant, 3)
        txt.chrout(' ')
        values.print(chunk.constants.values + constant)
        txt.nl()
        return offset + 2
    }

    sub constant2Instruction(str label, ^^Chunk chunk, uword offset) -> uword {
        uword constant = peekw(chunk.code + offset + 1)
        print_pad(label, 17)
        print_uwpad(constant, 3)
        txt.chrout(' ')
        values.print(chunk.constants.values + constant)
        txt.nl()
        return offset + 3
    }
}
