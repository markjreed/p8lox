%import Token
%import Scanner_def
%import String
%import string

Scanner {
    %option merge

    uword scanner = memory("scanner", SIZE, 1)
   
    sub init(uword source)  {
        set_start(scanner, String.get_text(source))
        set_current(scanner, get_start(scanner))
        set_end(scanner, get_start(scanner) + String.get_length(source))
        set_line(scanner, 1)
    }

    sub isAlpha(ubyte c) -> bool {
        return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_'
    }
 
    sub isDigit(ubyte c) -> bool {
        return c >= '0' and c <= '9'
    }

    sub scan(uword token) {
        skipWhitespace()
        Token.set_start(token, get_current(scanner))
        if isAtEnd() {
            makeToken(token, Token.EOF)
            return
        }
        ubyte c = advance()
        if isAlpha(c) { makeIdentifier(token) return }
        if isDigit(c) { makeNumber(token) return }
        when c {
            '(' -> { makeToken(token, Token.LEFT_PAREN) return }
            ')' -> { makeToken(token, Token.RIGHT_PAREN) return }
            '{' -> { makeToken(token, Token.LEFT_BRACE) return }
            '}' -> { makeToken(token, Token.RIGHT_BRACE) return }
            '[' -> { makeToken(token, Token.LEFT_BRACKET) return }
            ']' -> { makeToken(token, Token.RIGHT_BRACKET) return }
            ';' -> { makeToken(token, Token.SEMICOLON) return }
            ',' -> { makeToken(token, Token.COMMA) return }
            '.' -> { makeToken(token, Token.DOT) return }
            '-' -> { makeToken(token, Token.MINUS) return }
            '+' -> { makeToken(token, Token.PLUS) return }
            '/' -> { makeToken(token, Token.SLASH) return }
            '*' -> { makeToken(token, Token.STAR) return }
            '!' -> {
                makeToken(token, 
                    if match('=') Token.BANG_EQUAL else Token.BANG)
                return
             }
            '=' -> {
                makeToken(token, 
                    if match('=') Token.EQUAL_EQUAL else Token.EQUAL)
                return
             }
            '<' -> {
                makeToken(token, 
                    if match('=') Token.LESS_EQUAL else Token.LESS)
                return
             }
            '>' -> {
                makeToken(token, 
                    if match('=') Token.GREATER_EQUAL else Token.GREATER)
                return
             }
             '"' -> { makeString(token) return }
        }
        errorToken(token, "Unexpected character.")
    }

    sub isAtEnd() -> bool {
        return get_current(scanner) == get_end(scanner)
    }

    sub advance() -> ubyte {
        set_current(scanner, get_current(scanner) + 1)
        return @(get_current(scanner) - 1)
    }

    sub peekCurrent() -> ubyte {
        return @(get_current(scanner))
    }

    sub peekNext() -> ubyte {
        if isAtEnd() return 0
        return @(get_current(scanner) + 1)
    }

    sub match(ubyte expected) -> bool {
        if isAtEnd() return false
        if @(get_current(scanner)) != expected return false
        set_current(scanner, get_current(scanner) + 1)
        return true
    }

    sub makeToken(uword token, ubyte type) {
        Token.set_type(token, type)
        Token.set_start(token, get_start(scanner))
        Token.set_length(token, get_current(scanner) - get_start(scanner))
        Token.set_line(token, get_line(scanner))
    }

    sub errorToken(uword token, uword msg) {
        Token.set_type(token, Token.ERROR)
        Token.set_start(token, msg)
        Token.set_length(token, string.length(msg))
        Token.set_line(token, get_line(scanner))
    }

    sub skipWhitespace() {
        repeat {
            ubyte c = peekCurrent()
            when c {
                ' ',9 -> void advance()
                '\n' -> { 
                    set_line(scanner, get_line(scanner) + 1)
                    void advance()
                }
                '/' -> {
                    if peekNext() == '/' {
                        while peekCurrent() != '\n' and not isAtEnd() { void advance() }
                    } else {
                        return
                    }
                }
                else -> return
            }
        }
    }

    sub checkKeyword(uword start, uword length, uword rest, ubyte type) -> ubyte {
        if get_current(scanner) - get_start(scanner) == start + length and
           sys.memcmp(get_start(scanner) + start, rest, length) == 0 {
            return type
        } else {
            return Token.IDENTIFIER
        }
    }

    sub identifierType() -> ubyte {
        when @(get_start(scanner)) {
            'a' -> { return checkKeyword(1, 2, "nd", Token.AND) }
            'c' -> { return checkKeyword(1, 4, "lass", Token.CLASS) }
            'e' -> { return checkKeyword(1, 3, "lse", Token.ELSE) }
            'f' -> {
                if get_current(scanner) - get_start(scanner) > 1 {
                    when @(get_start(scanner) + 1) {
                        'a' -> return checkKeyword(2, 3, "lse", Token.ELSE)
                        'o' -> return checkKeyword(2, 1, "r", Token.FOR)
                        'u' -> return checkKeyword(2, 1, "n", Token.FUN)
                    }
                }
            }
            'i' -> { return checkKeyword(1, 1, "f", Token.IF) }
            'n' -> { return checkKeyword(1, 2, "il", Token.NIL) }
            'o' -> { return checkKeyword(1, 1, "r", Token.OR) }
            'p' -> { return checkKeyword(1, 4, "rint", Token.PRINT) }
            'r' -> { return checkKeyword(1, 5, "eturn", Token.RETURN) }
            's' -> { return checkKeyword(1, 4, "uper", Token.SUPER) }
            't' -> {
                if get_current(scanner) - get_start(scanner) > 1 {
                    when @(get_start(scanner) + 1) {
                        'h' -> return checkKeyword(2, 2, "is", Token.THIS)
                        'o' -> return checkKeyword(2, 2, "ue", Token.TRUE)
                    }
                }
            }
            'v' -> { return checkKeyword(1, 2, "ar", Token.VAR) }
            'w' -> { return checkKeyword(1, 4, "hile", Token.WHILE) }
        }
        return Token.IDENTIFIER
    }

    sub makeIdentifier(uword token) {
        while isAlpha(peekCurrent()) or isDigit(peekCurrent()) void advance()
        makeToken(token, identifierType())
    }

    sub makeNumber(uword token) {
        while isDigit(peekCurrent()) void advance()

        if peekCurrent() == '.' and isDigit(peekNext()) {
            void advance()
            while isDigit(peekCurrent())
                void advance()
        }
        makeToken(token, Token.NUMBER)
    }
      
    sub makeString(uword token) {
        while peekCurrent() != '"' and not isAtEnd() {
            if peekCurrent() == '\n' { set_line(scanner, get_line(scanner) + 1) }
            void advance()
        }
        if isAtEnd() {
            errorToken(token, "Unterminated string.")
            return
        }
        void advance()
        makeToken(token, Token.STRING)
    }

}
