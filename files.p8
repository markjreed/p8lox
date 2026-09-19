%option ignore_unused

%import diskio
%import mem
%import strings
%import textio

files {

    ; get size of file
    sub stat(str filename) -> long {
        ^^ubyte buffer = memory("buffer",1024,1)
        ubyte length = strings.length(filename)
        ^^ubyte command = mem.alloc(length + 5)
        ^^ubyte p
        ubyte digit, value
        long size = 0

        void strings.copy("$=l:", command)
        void strings.append(command, filename)
        if diskio.f_open(command) {
            void diskio.f_read_all(buffer)
            diskio.f_close()
            if buffer[6] != 18 or buffer[7] != 34 {
                txt.print("error reading dir entry")
                sys.exit(1)
            }
            p = buffer + 8
            while p^^ != 34 { p += 1 }
            while p^^ != 0 { p += 1 }
            p += 5
            while p^^ != 34 { p += 1 }
            p += 1
            while p^^ != 34 { p^^ += 1 }
            while p^^ != 'p' { p += 1 }
            p += 28
            size = 0
            txt.nl()
            repeat 8 {
                digit = p^^
                p += 1
                if digit >= '0' and digit <= '9' {
                    value = digit - '0'
                } else if digit >= 'a' and digit <= 'f' {
                    value = digit - 'a' + 10
                } else if digit >= 'A' and digit <= 'F' {
                    value = digit - 'A' + 10
                }
                size = size * 16 + value
            }
            txt.nl()
        } 
        return size
    }

    ; read whole file into memory and return pointer to contents
    sub slurp(str filename) -> ^^ubyte {
        uword size = lsw(stat(filename))
        txt.print_uw(size) txt.nl()
        ^^ubyte result = 0
        if size > 0 and diskio.f_open(filename) {
            result = mem.alloc(size + 1)
            txt.print_uwhex(result, true) txt.nl()
            void diskio.f_read_all(result)
            @(result + size) = 0
            diskio.f_close()
        }
        return result
    }
}
