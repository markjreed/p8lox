%import String
%import txt
%import VM
%zeropage basicsafe

repl {
    uword bufString = memory("bufString", String.SIZE, 1)
    ubyte[80] cbuffer

    bool syntaxError
    uword lineNum
    const ubyte max_nesting = 32
    ubyte[max_nesting] nested
    ubyte nestingLevel
    str prompt = "> "
    
    sub init() {
        VM.init()
        String.empty(bufString)
        reset()
    }

    sub reset() {
        lineNum = 0
        syntaxError = false
    }

    sub getExpression() -> uword {
        String.empty(bufString)
        syntaxError = false
        prompt = "> "
        while String.get_length(bufString) == 0 or not isCompleteExpression(bufString) {
            if nestingLevel > 0 {
                prompt[0] = nested[nestingLevel - 1]
            } else {
                prompt[0] = '>'
            }
            txt.print(prompt)
            void txt.input_chars(cbuffer)
            txt.nl()
            lineNum += 1
            String.appendCstring(bufString, cbuffer)
            String.appendChar(bufString, '\n')
        }
        if syntaxError return 0
        return bufString
    }

    sub isCompleteExpression(uword theString) -> bool {
        uword i
        nestingLevel = 0
        bool quoting = false
        uword slen = String.get_length(theString)
        if slen == 0 return true
        for i in 0 to slen - 1 {
            ubyte ch = String.charAt(theString, i)
            if ch == '"' {
                if nestingLevel > 0 and nested[nestingLevel - 1] == '"' {
                    nestingLevel -= 1
                    quoting = false
                } else {
                    nested[nestingLevel] = ch
                    nestingLevel += 1
                    quoting = true
                }
            } else if not quoting {
                if ch == '(' or ch == '[' or ch == iso:'{' {
                    nested[nestingLevel] = ch
                    nestingLevel += 1
                } else if ch == ')' {
                    if nestingLevel == 0 or nested[nestingLevel - 1] != '(' {
                       error("mismatched ')'")
                       return true
                    }
                    nestingLevel -= 1
                } else if ch == ']' {
                    if nestingLevel == 0 or nested[nestingLevel - 1] != '[' {
                       error("mismatched ']'")
                       return true
                    }
                    nestingLevel -= 1
                } else if ch == iso:'}' {
                    if nestingLevel == 0 or nested[nestingLevel - 1] != iso:'{' {
                       error(iso:"mismatched '}'")
                       return true
                    }
                    nestingLevel -= 1
                } 
            }
        }
        return (nestingLevel == 0)
    }

    sub error(uword message) {
        txt.print_suw("syntax error at line ", lineNum, ": ")
        txt.println(message)
        syntaxError = true
    }
    sub free() {
        String.free(bufString)
        VM.free()
    }
}

main {
    sub start() {
        uword expr
        repl.init()
        repeat {
            expr = repl.getExpression()
            if expr[0] != '\n' {
                String.print(expr)
                if String.compareCstring(expr, "exit\n") == 0 {
                    break
                }
                void VM.interpret(expr)
            }
        }
        repl.free()
    }
}
