%import memory
%import string
%import String_def
%import txt

String {
    %option merge
    sub empty(uword theString) {
        set_capacity(theString, 0)
        set_length(theString, 0)
        set_text(theString, 0)
    }

    sub append(uword theString, uword source, uword count) {
        uword oldLength = get_length(theString)
        uword newLength = oldLength + count
        uword oldCapacity = get_capacity(theString)
        uword newCapacity = oldCapacity
        while newCapacity < newLength {
            newCapacity = memory.GROW_CAPACITY(newCapacity)
        }
        set_text(theString, 
                memory.GROW_ARRAY(sys.sizeof_ubyte, get_text(theString), 
                                  oldCapacity, newCapacity))
        set_capacity(theString, newCapacity)
        set_length(theString, newLength)
        sys.memcopy(source, get_text(theString) + oldLength, count)
    }

    sub appendString(uword theString, uword otherString) {
        append(theString, get_text(otherString), get_length(otherString))
    }

    sub appendCstring(uword theString, uword cstring) {
        txt.println("hello!")
        ubyte length = string.length(cstring)
        txt.println_sub("length is ", length, 0)
        append(theString, cstring, length as uword)
    }

    sub print(uword theString) {
        txt.print_n(get_text(theString), get_length(theString))
    }
         
    sub free(uword theString) {
        memory.FREE_ARRAY(sys.sizeof_ubyte, get_text(theString), get_capacity(theString))
        empty(theString)
    }
}
