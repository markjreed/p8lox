%import debug
%import scanner
%import textio
%option ignore_unused

compiler {
    alias Token = scanner.Token
    alias TokenType::EOF = scanner.TokenType::EOF

    sub compile(^^ubyte source) { 
        scanner.init(source)
        uword line = 0
        repeat {
            ^^Token token = scanner.scanToken()
            if token.line != line {
                debug.print_uwpad(token.line, 4)
                txt.chrout(' ')
                line = token.line
            } else {
                txt.print(" | ")
            }

            debug.print_ubpad(token.type, 2)
            txt.chrout(' ')

            ubyte save = @(token.start + token.length)
            @(token.start + token.length) = 0
            txt.print(token.start)
            txt.nl()
            @(token.start + token.length) = save
            if token.type == TokenType::EOF 
                break
        }
    }
}
