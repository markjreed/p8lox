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

    sub appendChar(uword theString, ubyte char) {
        append(theString, &char, 1)
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
        ubyte length = string.length(cstring)
        txt.println_sub("length is ", length, 0)
        append(theString, cstring, length as uword)
    }

    sub charAt(uword theString, uword index) -> ubyte {
        return @(get_text(theString) + index)
    }

    sub compare(uword theString, uword ptr2, uword count) -> byte {
        byte result = 0
        uword ptr1 = get_text(theString)
        uword i
        for i in 0 to count - 1 {
            result = (@(ptr1 + i) - @(ptr2 + i)) as byte
            if result != 0 {
                return result as byte
            }
        }
        return 0
    }

    sub compareString(uword theString, uword otherString) -> byte {
        uword length1 = get_length(theString)
        uword length2 = get_length(otherString)
        if length1 != length2 {
            return if length1 < length2 -1 else (1 as byte)
        }
        return compare(theString, get_text(otherString), length1)
    }

    sub compareCstring(uword theString, uword cstring) -> byte {
        uword length1 = get_length(theString)
        uword length2 = string.length(cstring) as uword
        if length1 != length2 {
            return if length1 < length2 (-1 as byte) else (1 as byte)
        }
        return compare(theString, cstring, length1)
    }

    sub print(uword theString) {
        txt.print_n(get_text(theString), get_length(theString))
    }
         
    sub free(uword theString) {
        memory.FREE_ARRAY(sys.sizeof_ubyte, get_text(theString), get_capacity(theString))
        empty(theString)
    }
}
