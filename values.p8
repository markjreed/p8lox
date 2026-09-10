%import floats
%import mem

values {
    struct Value {
        float f_value
    }

    sub makeFloat(float value) -> ^^Value {
        ^^Value result = mem.alloc(0, 0, sizeof(Value))
        result.f_value = value
        return result
    }

    sub print(^^Value value) {
        txt.print_f(value.f_value)
    }

    sub free(^^Value value) {
        void mem.alloc(value, sizeof(Value), 0)
    }

    struct ValueArray {
        uword capacity
        uword count
        ^^Value values
    }

    sub initArray(^^ValueArray array) {
        array.capacity = 0
        array.count = 0
        array.values = 0
    }

    sub writeArray(^^ValueArray array, ^^Value value) {
        if array.capacity < array.count + 1 {
            uword old_capacity = array.capacity
            array.capacity = mem.grow(old_capacity)
            array.values = mem.alloc(array.values, 
                                     old_capacity * sizeof(Value), 
                                     array.capacity * sizeof(Value))
        }
        ^^Value valptr = array.values + array.count
        valptr.f_value = value.f_value
        array.count += 1
    }

    sub freeArray(^^ValueArray array) {
        void mem.alloc(array.values, array.capacity * sizeof(Value), 0)
        initArray(array)
    }
}
