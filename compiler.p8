%encoding iso
%option ignore_unused

%import chunks
%import debug
%import scanner
%import textio

compiler {
    alias Chunk = chunks.Chunk
    alias Token = scanner.Token
    alias TokenType::EOF = scanner.TokenType::EOF
    alias TokenType::ERROR = scanner.TokenType::ERROR
    alias OpCode::RETURN = chunks.OpCode::RETURN

    struct Parser {
        ^^Token current
        ^^Token previous
        bool hadError
        bool panicMode
    }

    ^^Parser theParser = ^^Parser:[]
    ^^Chunk compilingChunk

    sub currentChunk() -> ^^Chunk {
        return compilingChunk
    }

    sub errorAtCurrent(str message) {
        errorAt(theParser.current, message)
    }

    sub error(str message) {
        errorAt(theParser.previous, message)
    }

    sub errorAt(^^Token token, str message) {
        if theParser.panicMode == true {
            return
        }
        theParser.panicMode = true
        txt.print("[line ")
        txt.print_uw(token.line)
        txt.print("] Error")
        if token.type == TokenType::EOF {
            txt.print(" at end")
        } else if token.type == TokenType::ERROR {
        } else {
            txt.print(" at '")
            @(token.start + token.length) = 0
            txt.print(token.start)
            txt.chrout(39)
        }
        txt.print(": ")
        txt.print(message)
        txt.nl()
        theParser.hadError = true
    }

    sub advance() {
        theParser.previous = theParser.current

        repeat {
            theParser.current = scanner.scanToken()
            if theParser.current.type != TokenType::ERROR
                break
            errorAtCurrent(theParser.current.start)
        }
    }

    sub consume(ubyte type, str message) {
        if theParser.current.type == type {
            advance()
            return
        }
        errorAtCurrent(message)
    }

    sub emitByte(ubyte theByte) {
        chunks.write(currentChunk(), theByte, theParser.previous.line)
    }

    inline sub emitBytes(ubyte byte1, ubyte byte2) {
        emitByte(byte1)
        emitByte(byte2)
    }

    sub emitReturn() {
        emitByte(OpCode::RETURN)
    }

    sub endCompiler() {
        emitReturn()
    }

    sub expression() {
    }

    sub compile(^^ubyte source, ^^Chunk chunk) -> bool { 
        scanner.init(source)
        compilingChunk = chunk
        theParser.hadError = false
        theParser.panicMode = false
        advance()
        expression()
        consume(TokenType::EOF, "Expect end of expression.")
        endCompiler()
        return not theParser.hadError
    }
}
