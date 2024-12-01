%import String
%import VM
%import Value_def
%import floats
%import txt

Value {
    %option merge

    uword NIL = memory("Value.NIL", SIZE, 1)
    bool initialized = false

    sub getNil() -> uword {
        if not initialized {
            initNil(NIL)
        }
        return NIL
    }

    sub initNil(uword value)  {
        set_type(value, Value.type.NIL)
    }

    sub initBoolean(uword value, bool boolean)  {
        set_type(value, Value.type.BOOLEAN)
        set_boolean(value, boolean)
    }

    sub initReal(uword value, float real)  {
        set_type(value, Value.type.REAL)
        set_real(value, real)
    }

    sub initInt(uword value, word int)  {
        set_type(value, Value.type.INT)
        set_int(value, int)
    }

    sub initString(uword value, uword theString)  {
        set_type(value, Value.type.STRING)
        uword text = String.get_text(theString)
        uword length = String.get_length(theString)
        String.empty(get_string(value))
        String.append(get_string(value), text, length)
    }


    sub initCstring(uword value, uword cstring)  {
        set_type(value, Value.type.STRING)
        String.empty(get_string(value))
        String.appendCstring(get_string(value), cstring)
    }

    uword buffer = memory("Value_buffer", SIZE, 1);

    sub makeBoolean(bool flag) -> uword {
        initBoolean(buffer, flag)
        return buffer
    }

    sub makeReal(float real) -> uword {
        initReal(buffer, real)
        return buffer
    }

    sub makeInt(word int) -> uword {
        initInt(buffer, int)
        return buffer
    }

    sub makeString(uword cstring) -> uword {
        initCstring(buffer, cstring)
        return buffer
    }

    sub print(uword value) {
        when get_type(value) {
            Value.type.NIL     -> txt.print("nil")
            Value.type.REAL    -> txt.print_f(get_real(value))
            Value.type.INT     -> txt.print_w(get_int(value))
            Value.type.STRING  -> String.print(get_string(value))
            Value.type.BOOLEAN -> { 
                if get_boolean(value) { 
                    txt.print("true")
                } else {
                    txt.print("false")
                }
            }
        }
    }

    sub negate(uword value) -> bool {
        when get_type(value) {
            Value.type.REAL -> {
                set_real(value, -get_real(value))
                return true
            }
            Value.type.INT  -> {
                set_int(value, -get_int(value))
                return true
            }
            else -> {
                return typeError()
            }
        }
    }

    sub typeError() -> bool {
        VM.runtimeError("ERROR: Type mismatch")
        return false
    }
        
    uword opSource1
    uword opSource2
    uword opDest
    bool opStatus

    sub binOp(uword op, uword source1, uword source2, uword dest) -> bool {
        opSource1 = source1
        opSource2 = source2
        opDest    = dest

        ubyte type1    = get_type(source1)
        ubyte type2    = get_type(source2)
    
        if type1 == type2 {
            ; do nothing
        } else if type1 == Value.type.REAL and type2 == Value.type.INT {
            set_type(source2, Value.type.REAL)
            set_real(source2, get_int(source2) as float)
        } else if type2 == Value.type.REAL and type1 == Value.type.INT {
            set_type(source1, Value.type.REAL)
            set_real(source1, get_int(source1) as float)
        } else {
            return typeError()
        }
        opStatus = true
        void call(op)
        return opStatus
    }

    sub add() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) + get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) + get_int(opSource2)) }
            Value.type.STRING -> { 
                 initString(opDest, get_string(opSource1))
                 txt.print("after initString, opDest='")
                 String.print(get_string(opDest))
                 txt.println("'")
                 txt.print("about to append '")
                 String.print(get_string(opSource2))
                 txt.println("'")
                 String.appendString(get_string(opDest), get_string(opSource2))
            }
        }
    }

    sub subtract() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) - get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) - get_int(opSource2)) }
            else -> { opStatus = typeError() }
        }
    }

    sub multiply() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) * get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) * get_int(opSource2)) }
            else -> { opStatus = typeError() }
        }
    }

    sub divide() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) / get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) / get_int(opSource2)) }
            else -> { opStatus = typeError() }
        }
    }
}
