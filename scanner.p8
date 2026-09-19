%option ignore_unused
%import strings

scanner {
    struct Scanner {
        ^^ubyte start
        ^^ubyte current
        uword line
    }
    ^^Scanner theScanner = ^^Scanner:[0, 0, 0]
    enum TokenType {
        ; single-character tokens
        LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, DOT, MINUS,
        PLUS, SEMICOLON, SLASH, STAR, 

        ; One or two-character tokens
        BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS,
        LESS_EQUAL, 

        ; Literals
        IDENTIFIER, STRING, NUMBER,

        ; Keywords. 
        AND, CLASS, ELSE, FALSE, FOR, FUN, IF, NIL, OR, PRINT, RETURN, SUPER,
        THIS, TRUE, VAR, WHILE, ERROR, EOF
    }
    struct Token {
        ubyte type
        ^^ubyte start
        uword length
        uword line
    }

    sub init(^^ubyte source) { 
        theScanner.start = source
        theScanner.current = source
        theScanner.line = 1
    }

    sub isAtEnd() -> bool {
        return @(theScanner.current) == 0
    }

    sub makeToken(ubyte type) -> ^^Token {
        ^^Token token = ^^Token:[0,0,0,0]
        token.type = type
        token.start = theScanner.start
        token.length = (theScanner.current as uword) - (theScanner.start as uword)
        token.line = theScanner.line
        return token
    }

    sub errorToken(^^ubyte message) -> ^^Token {
        ^^Token token = ^^Token:[0,0,0,0]
        token.type = TokenType::ERROR
        token.start = message
        token.length = strings.length(message)
        token.line = theScanner.line
        return token
    }

    sub scanToken() -> ^^Token {
        theScanner.start = theScanner.current
        if isAtEnd()
            return makeToken(TokenType::EOF)
        return errorToken("Unexpected character.")
    }


}
