%import ValueArray_def
%import Value

ValueArray {
    %option merge
    sub init(uword array) {
        set_count(array, 0)
        set_capacity(array, 0)
        set_values(array, 0)
    }

    sub write(uword array, uword value) {
        uword oldCapacity = get_capacity(array)
        if oldCapacity < get_count(array) + 1 {
            set_capacity(array, memory.GROW_CAPACITY(oldCapacity))
            set_values(array, 
                memory.GROW_ARRAY(Value.SIZE, get_values(array), 
                                  oldCapacity, get_capacity(array)))
        }
        sys.memcopy(value, get_values(array) + get_count(array) * Value.SIZE, Value.SIZE)
        set_count(array, get_count(array) + 1)
    }

    sub read(uword array, uword index) -> uword {
        return get_values(array) + index * Value.SIZE
    }

    sub free(uword array) {
        memory.FREE_ARRAY(Value.SIZE, get_values(array), get_capacity(array))
        init(array)
    }
}
