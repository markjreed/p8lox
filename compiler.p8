%import Chunk
%import ParseRule
%import Parser
%import Precedence
%import Scanner
%import Token
%import Value
%import conv
%import debug
%import range
%import txt

; local variables for recursive parse calls
stack {
    const ubyte DEPTH = 16
    ubyte[DEPTH] values

    ubyte pointer

    sub push(ubyte value) {
        values[pointer] = value
        pointer += 1
    }

    sub top() -> ubyte {
        return values[pointer - 1]
    }

    sub pop() -> ubyte {
        pointer -= 1
        return values[pointer]
    }
}

compiler {
    uword parser = memory("parser", Parser.SIZE, 1)
    uword compilingChunk

    sub currentChunk() -> uword {
        return compilingChunk
    }

    sub errorAt(uword token, uword message) {
        if Parser.get_panicMode(parser) return
        Parser.set_panicMode(parser, true)
        txt.print_suw("[line ", Token.get_line(token), "] Error")
        if Token.get_type(token) == Token.EOF {
            txt.print(" at end")
        } else if Token.get_type(token) != Token.ERROR  {
            txt.print(" at '")
            txt.print_n(Token.get_start(token), Token.get_length(token))
            txt.chrout('\'')
        }
        txt.println_ss(": ", message, 0)
    }

    sub error(uword message) {
        errorAt(Parser.get_previous(parser), message)
    }
        
    sub errorAtCurrent(uword message) {
        errorAt(Parser.get_current(parser), message)
    }

    sub advance() {
        Token.copy(Parser.get_current(parser), Parser.get_previous(parser))
        repeat {
            Scanner.scan(Parser.get_current(parser))
            if Token.get_type(Parser.get_current(parser)) != Token.ERROR 
                break
            errorAtCurrent(Token.get_start(Parser.get_current(parser)))
        }
    }

    sub consume(ubyte type, uword message) {
        if Token.get_type(Parser.get_current(parser)) == type {
            advance()
            return
        }
        errorAtCurrent(message)
    }

    sub emitByte(ubyte value) {
        Chunk.write(currentChunk(), value, Token.get_line(Parser.get_previous(parser)))
    }

    sub emitBytes(ubyte byte1, ubyte byte2) {
        emitByte(byte1)
        emitByte(byte2)
    }

    sub emitReturn() {
        emitByte(OP.RETURN)
    }

    sub makeConstant(uword value) -> ubyte {
        uword constant = Chunk.addConstant(currentChunk(), value)
        if constant > range.UByte.MAX {
            error("Too many constants in one chunk.")
            return 0
        }
        return constant as ubyte
    }

    sub emitConstant(uword value) {
        emitBytes(OP.CONSTANT, makeConstant(value))
    }

    sub endCompiler() {
        emitReturn()
        if common.DEBUG_PRINT_CODE {
            if not Parser.get_hadError(parser) {
                debug.disassembleChunk(currentChunk(), "code")
            }
        }
    }

    sub binary() {
        stack.push(Token.get_type(Parser.get_previous(parser)))
        uword rule = memory("binary.rule", ParseRule.SIZE, 1)
        ParseRule.getRule(rule, stack.top())
        parsePrecedence(ParseRule.get_precedence(rule) + 1)
        when stack.pop() {
            Token.PLUS  -> emitByte(OP.ADD)
            Token.MINUS -> emitByte(OP.SUBTRACT)
            Token.STAR  -> emitByte(OP.MULTIPLY)
            Token.SLASH -> emitByte(OP.DIVIDE)
            else -> return
        }
    }

    sub grouping() {
        expression()
        consume(Token.RIGHT_PAREN, "Expect ')' after expression.")
    }

    sub number() {
        uword value = memory("numberBuf", Value.SIZE, 1)
        Value.initInt(value, 0)
        uword ptr = Token.get_start(Parser.get_previous(parser))
        bool afterDecimal = false
        float denom = 1.0
        uword i
        for i in 0 to Token.get_length(Parser.get_previous(parser)) - 1 {
            if ptr[i] == '.' {
                afterDecimal = true
                Value.initReal(value, Value.get_real(value) as word)
            } else {
                ubyte digitValue = ptr[i] - '0'
                if afterDecimal {
                    Value.set_real(value, Value.get_real(value) + digitValue * denom)
                    denom /= 10.0
                } else {
                    Value.set_int(value, Value.get_int(value) * 10 + digitValue)
                }
            }
        }
    }

    sub unary() {
        stack.push(Token.get_type(Parser.get_previous(parser)))

        parsePrecedence(Precedence.UNARY);

        when stack.pop() {
            Token.MINUS -> emitByte(OP.NEGATE)
            else -> return
        }
    }

    sub parsePrecedence(ubyte precedence) {
        uword rule = memory("parsePrecedence.rule", ParseRule.SIZE, 1)

        ParseRule.getRule(rule, Token.get_type(Parser.get_previous(parser)))
        uword prefix = ParseRule.get_prefix(rule)

        if prefix == 0 {
            error("Expect expression")
            return
        }

        stack.push(precedence)
        void call(prefix)

        ParseRule.getRule(rule, Token.get_type(Parser.get_current(parser)))

        while stack.top() <= ParseRule.get_precedence(rule) {
            advance()
            ParseRule.getRule(rule, Token.get_type(Parser.get_previous(parser)))
            uword infix = ParseRule.get_infix(rule)
            if infix != 0 {
                call(infix)
            }
            ParseRule.getRule(rule, Token.get_type(Parser.get_current(parser)))
        }

        void stack.pop()
    }

    sub expression() {
        parsePrecedence(Precedence.ASSIGNMENT)
    }

    sub compile(uword source, uword chunk) -> bool {
        Scanner.init(source)
        compilingChunk = chunk
        stack.pointer = 0
        Parser.set_hadError(parser, false)
        Parser.set_panicMode(parser, false)
        advance()
        expression()
        consume(Token.EOF, "Expect end of expression.")
        endCompiler()
        return not Parser.get_hadError(parser)
    }
}
