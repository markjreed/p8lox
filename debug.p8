%encoding iso

%import chunks
%import conv
%import strings
%import textio

debug {
    alias Chunk = chunks.Chunk
    sub disassemble_chunk(^^Chunk chunk, ^^ubyte name) {
        txt.print("== ") txt.print(name) txt.print(" ==\n")
        uword offset = 0
        while offset < chunk.count {
            offset = disassemble_instruction(chunk, offset)
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

    sub disassemble_instruction(^^Chunk chunk, uword offset) -> uword {
        print_uwpad(offset, 4)
        txt.chrout(' ')
        ubyte instruction = @(chunk.code + offset)
        when instruction {
            chunks.OpCode::RETURN -> return simple_instruction("RETURN", offset)
            else -> { 
                txt.print("unknown opcode ") txt.print_ub(instruction) txt.nl()
                return offset + 1
            }
        }
    }

    sub simple_instruction(str label, uword offset) -> uword {
        txt.print(label)
        txt.nl()
        return offset + 1
    }
}
