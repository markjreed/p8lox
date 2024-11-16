%import Value_def
%import floats

Value {
    sub type(uword value) -> ubyte {
        return get_type(value)
        const ubyte REAL = 0
        const ubyte INT  = 1
    }
     
    %option merge
    uword buffer = memory("Value_buffer", SIZE, 1);

    sub real(float value) -> uword {
        set_type(buffer, Value.type.REAL)
        set_real(buffer, value)
        return buffer;
    }

    sub int(word value) -> uword {
        set_type(buffer, Value.type.INT)
        set_int(buffer, value)
        return buffer;
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
}
