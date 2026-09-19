%import strings
%option ignore_unused
%option no_sysinit

args {
    ubyte[256] buffer
    ^^ubyte[128] argv

    sub standard() -> ubyte {
        cx16.get_program_args(buffer, 255, false)
        ubyte length = strings.length(buffer)
        ubyte argc = 0
        if length > 0 {
            ubyte i
            argv[argc] = &buffer
            argc += 1
            for i in 0 to length {
                if buffer[i] == ';' {
                    buffer[i] = 0
                    argv[argc] = &buffer + i + 1
                    argc += 1
                }
            }
        }
        return argc
    }

    const uword BASIC_INPUT = $200
    sub basic() -> ubyte {
        ^^ubyte inptr = BASIC_INPUT
        while inptr^^ != ':' and inptr^^ != 0 {
            inptr += 1
        }
        if inptr^^ == 0 {
            return 0
        }
        inptr += 1
        ; skip spaces
        while inptr^^ == ' ' {
            inptr += 1
        }
        ; skip any REM
        if inptr^^ == 143 {
            inptr += 1
        }

        ^^ubyte outptr = &buffer
        ubyte argc = 0
        ubyte terminator 
        while inptr^^ != 0 {
            argv[argc] = outptr
            argc += 1
            terminator = ' '
            if inptr^^ == '"' {
                terminator = '"'
                inptr += 1
            }
            while inptr^^ != 0 and inptr^^ != terminator  {
                outptr^^ = inptr^^
                inptr += 1
                outptr += 1
            }
            outptr^^ = 0
            outptr += 1
            if inptr^^ != 0 {
                inptr += 1
                while inptr^^ == ' ' {
                    inptr += 1 
                }
            }
        }
        return argc
    }
}
