%import ParseRule_def
%import Precedence
%import Token

ParseRule {
    %option merge
    uword[Token.EOF+1] prefix = [ 
        &compiler.grouping, 0, 0, 0, 0, 0, &compiler.unary, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, &compiler.number, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0
    ]
     
    uword [Token.EOF+1] infix = [
        0, 0, 0, 0, 0, 0, &compiler.binary, &compiler.binary, 0,
        &compiler.binary, &compiler.binary, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    ]

    alias NONE = Precedence.NONE

    ubyte[Token.EOF+1] precedence = [
        NONE, NONE, NONE, NONE, NONE, NONE, Precedence.TERM, NONE,
        Precedence.FACTOR, Precedence.FACTOR, NONE, NONE, NONE, NONE, NONE,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
        NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, 
        NONE
    ]

    uword buffer = memory("ParseRule.buffer", SIZE, 1)

    sub getRule(ubyte type) -> uword {
        set_prefix(buffer, prefix[type])
        set_infix(buffer, infix[type])
        set_precedence(buffer, precedence[type])
        return buffer
    }
}
