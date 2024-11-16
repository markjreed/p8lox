%import Value_def
%import floats

Value {
    %option merge

    sub type(uword value) -> ubyte {
        return get_type(value)
        const ubyte REAL = 0
        const ubyte INT  = 1
    }

    sub copy(uword source, uword dest) {
        sys.memcopy(source, dest, SIZE)
    }
     
    sub initReal(uword value, float real)  {
        set_type(value, Value.type.REAL)
        set_real(value, real)
    }

    sub initInt(uword value, word int)  {
        set_type(value, Value.type.INT)
        set_int(value, int)
    }

    uword buffer = memory("Value_buffer", SIZE, 1);

    sub makeReal(float real) -> uword {
        initReal(buffer, real)
        return buffer
    }

    sub makeInt(word int) -> uword {
        initInt(buffer, int)
        return buffer
    }

    sub print(uword value) {
        floats.print(get_real(value))
    }

    sub negate(uword value) {
        when get_type(value) {
            Value.type.REAL -> set_real(value, -get_real(value))
            Value.type.INT  -> set_int(value, -get_int(value))
        }
    }

    uword opSource1
    uword opSource2
    uword opDest

    sub binOp(uword op, uword source1, uword source2, uword dest) {
        opSource1 = source1
        opSource2 = source2
        opDest    = dest

        ubyte type1    = get_type(source1)
        ubyte type2    = get_type(source2)
        ubyte newtype
        if type1 == type2 {
            newtype = type1
        } else if type1 == Value.type.REAL and type2 == Value.type.INT {
            set_type(source2, Value.type.REAL)
            set_real(source2, get_int(source2) as float)
        } else if type2 == Value.type.REAL and type1 == Value.type.INT {
            set_type(source1, Value.type.REAL)
            set_real(source1, get_int(source1) as float)
        } else {
            txt.print("type mismatch error")
            return
        }
        void call(op)
    }

    sub add() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) + get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) + get_int(opSource2)) }
        }
    }

    sub subtract() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) - get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) - get_int(opSource2)) }
        }
    }

    sub multiply() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) * get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) * get_int(opSource2)) }
        }
    }

    sub divide() {
        when get_type(opSource1) {
            Value.type.REAL -> { initReal(opDest, get_real(opSource1) / get_real(opSource2)) }
            Value.type.INT -> { initInt(opDest, get_int(opSource1) / get_int(opSource2)) }
        }
    }
}
