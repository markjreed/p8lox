%import Scanner
%import Token
%import conv
%import txt

compiler {
    sub compile(uword source) {
        Scanner.init(source)
        uword line = $ffff
        uword token = memory("token", Token.SIZE, 1)
        repeat {
            Scanner.scan(token)
            if Token.get_line(token) != line {
                line = Token.get_line(token)
                txt.print_rj(4, conv.str_uw(line))
                txt.chrout(' ')
            } else {
                txt.print("  |  ")
            }
            txt.print_rj(2, conv.str_ub(Token.get_type(token)))
            txt.print(" '")
            txt.print_n(Token.get_start(token), Token.get_length(token))
            if Token.get_type(token) == Token.EOF {
                break
            }
        }
    }
}
