%encoding iso
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

    sub advance() -> ubyte {
        ubyte c = theScanner.current^^
        theScanner.current += 1
        return c
    }

    sub peekCurr() -> ubyte {
        return theScanner.current^^
    }

    sub peekNext() -> ubyte {
        if isAtEnd() return 0
        return theScanner.current[1]
    }

    sub match(ubyte expected) -> bool {
        if isAtEnd() return false
        if theScanner.current^^ != expected 
            return false
        theScanner.current += 1
        return true
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

    sub skipWhitespace() {
        repeat {
            ubyte c = peekCurr()
            when c {
                ' ','\t' -> advance()
                '\n' -> { theScanner.line += 1 advance() }
                '/' -> {
                    if peekNext() == '/' {
                        while peekCurr() != '\n' and not isAtEnd() {
                            advance()
                        }
                    } else {
                        return
                    }
                }
                else -> return
            }
        }
    }

    sub scanToken() -> ^^Token {
        skipWhitespace()
        theScanner.start = theScanner.current
        if isAtEnd()
            return makeToken(TokenType::EOF)
        ubyte c = advance()
        when c {
            '(' -> return makeToken(TokenType::LEFT_PAREN)
            ')' -> return makeToken(TokenType::RIGHT_PAREN)
            '{' -> return makeToken(TokenType::LEFT_BRACE)
            '}' -> return makeToken(TokenType::RIGHT_BRACE)
            ';' -> return makeToken(TokenType::SEMICOLON)
            ',' -> return makeToken(TokenType::COMMA)
            '.' -> return makeToken(TokenType::DOT)
            '-' -> return makeToken(TokenType::MINUS)
            '+' -> return makeToken(TokenType::PLUS)
            '/' -> return makeToken(TokenType::SLASH)
            '*' -> return makeToken(TokenType::STAR)
            '!' -> return makeToken(
                if match('=') then TokenType::BANG_EQUAL else TokenType::BANG)
            '=' -> return makeToken(
                if match('=') then TokenType::EQUAL_EQUAL else TokenType::EQUAL)
            '<' -> return makeToken(
                if match('=') then TokenType::LESS_EQUAL else TokenType::LESS)
            '>' -> return makeToken(
                if match('=') then TokenType::GREATER_EQUAL else TokenType::GREATER)
        }
        str errorMessage = "Unexpected character: 'x'" 
        errorMessage[23] = c
        theScanner.current += 1
        return errorToken(errorMessage)
    }
}
