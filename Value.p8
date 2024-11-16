%import Value_def
%import floats

Value {
    %option merge
    uword buffer = memory("Value_buffer", SIZE, 1);

    sub real(float value) -> uword {
        set_real(buffer, value)
        return buffer;
    }

    sub int(uword value) -> uword {
        set_int(buffer, value)
        return buffer;
    }

    sub print(uword value) {
        floats.print(get_real(value))
    }

}
