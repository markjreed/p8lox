%import textio
%option ignore_unused

txt {
    %option merge

    ; print string, but skip it if the pointer is zero
    sub optprint(uword s) { if s != 0 txt.print(s) }

    ; print N characters starting at a given address
    sub print_n(uword start, uword length) { 
        while length > 0 {
            length -= 1
            txt.chrout(@(start))
            start += 1
        }
    }
            
    ; print numbers with zero-padding
    sub print_bzp(ubyte digits, byte value) {
        if value < 0 {
            txt.chrout('-')
            print_ubzp(digits - 1, (-value) as ubyte)
        }
    }
    sub print_ubzp(ubyte digits, ubyte value) {
        while digits > 3 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 2 and value < 100 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 1 and value < 10 {
            txt.chrout('0')
            digits -= 1
        }
        txt.print_ub(value)
    }

    sub print_wzp(ubyte digits, word value) {
        if value < 0 {
            txt.chrout('-')
            print_uwzp(digits - 1, (-value) as uword)
        }
    }
    sub print_uwzp(ubyte digits, uword value) {
        while digits > 5 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 4 and value < 10000 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 3 and value < 1000 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 2 and value < 100 {
            txt.chrout('0')
            digits -= 1
        }
        if digits > 1 and value < 10 {
            txt.chrout('0')
            digits -= 1
        }
        txt.print_uw(value)
    }

    ; txt.print_* functions with a newline at the end; these could be implemented with
    ; calls to the println_s* functions below with 0s on either side, but I
    ; figure they're used enough to warrant a slightly more optimized direct
    ; implementation.
    sub println      (uword value)              { optprint(value)               txt.nl() }
    sub println_ub0  (ubyte value)              { txt.print_ub0(value)           txt.nl() }
    sub println_ub   (ubyte value)              { txt.print_ub(value)            txt.nl() }
    sub println_b    ( byte value)              { txt.print_b(value)             txt.nl() }
    sub println_ubhex(ubyte value, bool prefix) { txt.print_ubhex(value, prefix) txt.nl() }
    sub println_ubbin(ubyte value, bool prefix) { txt.print_ubbin(value, prefix) txt.nl() }
    sub println_uwbin(uword value, bool prefix) { txt.print_uwbin(value, prefix) txt.nl() }
    sub println_uwhex(uword value, bool prefix) { txt.print_uwhex(value, prefix) txt.nl() }
    sub println_uw0  (uword value)              { txt.print_uw0(value)           txt.nl() }
    sub println_uw   (uword value)              { txt.print_uw(value)            txt.nl() }
    sub println_w    ( word value)              { txt.print_w(value)             txt.nl() }

    ; txt.print_* functions with a (possibly null) string on either side
    sub print_ss    (uword before, uword value, uword after)              { optprint(before) optprint(value)                optprint(after) }
    sub print_sub0  (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub0(value)           optprint(after) }
    sub print_sub   (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub(value)            optprint(after) }
    sub print_sb    (uword before,  byte value, uword after)              { optprint(before) txt.print_b(value)             optprint(after) }
    sub print_subhex(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubhex(value, prefix) optprint(after) }
    sub print_subbin(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubbin(value, prefix) optprint(after) }
    sub print_suwbin(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwbin(value, prefix) optprint(after) }
    sub print_suwhex(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwhex(value, prefix) optprint(after) }
    sub print_suw0  (uword before, uword value, uword after)              { optprint(before) txt.print_uw0(value)           optprint(after) }
    sub print_suw   (uword before, uword value, uword after)              { optprint(before) txt.print_uw(value)            optprint(after) }
    sub print_sw    (uword before,  word value, uword after)              { optprint(before) txt.print_w(value)             optprint(after) }

    ; txt.print_* functions with a (possibly null) string on either side and a newline at the end
    sub println_ss    (uword before, uword value, uword after)              { optprint(before) optprint(value)                optprint(after) txt.nl() }
    sub println_sub0  (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub0(value)           optprint(after) txt.nl() }
    sub println_sub   (uword before, ubyte value, uword after)              { optprint(before) txt.print_ub(value)            optprint(after) txt.nl() }
    sub println_sb    (uword before,  byte value, uword after)              { optprint(before) txt.print_b(value)             optprint(after) txt.nl() }
    sub println_subhex(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubhex(value, prefix) optprint(after) txt.nl() }
    sub println_subbin(uword before, ubyte value, bool prefix, uword after) { optprint(before) txt.print_ubbin(value, prefix) optprint(after) txt.nl() }
    sub println_suwbin(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwbin(value, prefix) optprint(after) txt.nl() }
    sub println_suwhex(uword before, uword value, bool prefix, uword after) { optprint(before) txt.print_uwhex(value, prefix) optprint(after) txt.nl() }
    sub println_suw0  (uword before, uword value, uword after)              { optprint(before) txt.print_uw0(value)           optprint(after) txt.nl() }
    sub println_suw   (uword before, uword value, uword after)              { optprint(before) txt.print_uw(value)            optprint(after) txt.nl() }
    sub println_sw    (uword before,  word value, uword after)              { optprint(before) txt.print_w(value)             optprint(after) txt.nl() }
}
