%import syslib
%import textio

util {
    asmsub get_memtop() -> uword @XY {
        %asm{{
            sec
            jmp cbm.MEMTOP
        }}
    }

    sub panic(uword msg) {
        txt.print("PANIC: ")
        txt.print(msg)
        txt.nl()
        sys.exit(1)
    }
}
