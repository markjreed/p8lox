%encoding iso
%option ignore_unused
%option no_symbol_prefixing

%import chunks
%import debug
%import scanner
%import textio
%import values

compiler {
    alias Chunk = chunks.Chunk
    alias Token = scanner.Token
    alias Value = values.Value

    alias TokenType::EOF         = scanner.TokenType::EOF
    alias TokenType::ERROR       = scanner.TokenType::ERROR
    alias TokenType::MINUS       = scanner.TokenType::MINUS
    alias TokenType::PLUS        = scanner.TokenType::PLUS
    alias TokenType::RIGHT_PAREN = scanner.TokenType::RIGHT_PAREN
    alias TokenType::SLASH       = scanner.TokenType::SLASH
    alias TokenType::STAR        = scanner.TokenType::STAR

    alias OpCode::ADD       = chunks.OpCode::ADD
    alias OpCode::CONSTANT  = chunks.OpCode::CONSTANT
    alias OpCode::CONSTANT2 = chunks.OpCode::CONSTANT2
    alias OpCode::DIVIDE    = chunks.OpCode::DIVIDE
    alias OpCode::MULTIPLY  = chunks.OpCode::MULTIPLY
    alias OpCode::NEGATE    = chunks.OpCode::NEGATE
    alias OpCode::RETURN    = chunks.OpCode::RETURN
    alias OpCode::SUBTRACT  = chunks.OpCode::SUBTRACT

    struct Parser {
        ^^Token current
        ^^Token previous
        bool hadError
        bool panicMode
    }

    enum Precedence {
        NONE, ASSIGNMENT, OR, AND, EQUALITY, COMPARISON, 
        TERM, FACTOR, UNARY, CALL, PRIMARY
    }

    struct ParseRule {
        uword prefix
        uword infix
        ubyte precedence
    }

    ^^ParseRule[] rules = [
        ^^ParseRule:[&grouping,  0,        Precedence::NONE],   ;  LEFT_PAREN
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  RIGHT_PAREN
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  LEFT_BRACE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  RIGHT_BRACE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  COMMA
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  DOT
        ^^ParseRule:[&unary,     &binary,  Precedence::TERM],   ;  MINUS
        ^^ParseRule:[0,          &binary,  Precedence::TERM],   ;  PLUS
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  SEMICOLON
        ^^ParseRule:[0,          &binary,  Precedence::FACTOR], ;  SLASH
        ^^ParseRule:[0,          &binary,  Precedence::FACTOR], ;  STAR
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  BANG
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  BANG_EQUAL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  EQUAL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  EQUAL_EQUAL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  GREATER
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  GREATER_EQUAL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  LESS
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  LESS_EQUAL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  IDENTIFIER
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  STRING
        ^^ParseRule:[&number,    0,        Precedence::NONE],   ;  NUMBER
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  AND
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  CLASS
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  ELSE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  FALSE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  FOR
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  FUN
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  IF
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  NIL
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  OR
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  PRINT
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  RETURN
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  SUPER
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  THIS
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  TRUE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  VAR
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  WHILE
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  ERROR
        ^^ParseRule:[0,          0,        Precedence::NONE],   ;  EOF
    ]

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

    sub makeConstant(^^Value value) -> uword {
        return chunks.addConstant(currentChunk(), value)
    }


    sub emitConstant(^^Value value) {
        uword constant = makeConstant(value)
        if constant < 256 {
            emitBytes(OpCode::CONSTANT, lsb(constant))
        } else {
            emitBytes(OpCode::CONSTANT2, lsb(constant))
            emitByte(msb(constant))
        }
    }

    sub endCompiler() {
        emitReturn()
    }

    sub binary() {
        ubyte operatorType = theParser.previous.type
        ^^ParseRule rule = rules[operatorType]
        parsePrecedence(rule.precedence + 1)

        when operatorType {
            TokenType::PLUS  -> emitByte(OpCode::ADD)
            TokenType::MINUS -> emitByte(OpCode::SUBTRACT)
            TokenType::STAR  -> emitByte(OpCode::MULTIPLY)
            TokenType::SLASH -> emitByte(OpCode::DIVIDE)
            else -> return
        }
    }

    sub grouping() {
        expression()
        consume(TokenType::RIGHT_PAREN, "Expect ')' after expression.")
    }

    sub number() {
        float num = floats.parse(theParser.previous.start) 
        ^^Value value = values.makeNum(num)
        emitConstant(value)
    }

    sub unary() {
        ubyte operatorType = theParser.previous.type

        parsePrecedence(Precedence::UNARY)

        when operatorType {
            TokenType::MINUS -> emitByte(OpCode::NEGATE)
            else -> return
        }
    }

    sub parsePrecedence(ubyte precedence) {
    }

    sub expression() {
        parsePrecedence(Precedence::ASSIGNMENT)
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
