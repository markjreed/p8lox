%import floats
%import mem

values {
    enum ValueType {
        NIL, BOOL, NUM, STRING, FUN
    }

    struct Value {
        ubyte type
        ubyte[5] bytes
    }

    ^^Value NIL = ^^Value:[ValueType::NIL, [0, 0, 0, 0, 0]]

    sub new() -> ^^Value {
        return mem.alloc(0, 0, sizeof(Value))
    }

    sub makeBool(bool value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::BOOL
        pokebool(result as ^^ubyte + offsetof(Value.bytes), value)
        return result
    }

    sub makeNum(float value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::NUM
        pokef(result as ^^ubyte + offsetof(Value.bytes), value)
        return result
    }

    sub makeString(str value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::STRING
        result.bytes[0] = strings.length(value)
        pokew(result as ^^ubyte + offsetof(Value.bytes) + 1, value)
        return result
    }

    sub print(^^Value value) {
        when value.type {
            ValueType::NIL    -> txt.print("NIL") 
            ValueType::BOOL   -> txt.print_bool(peekbool(value as ^^ubyte + offsetof(Value.bytes)))
            ValueType::NUM    -> txt.print_f(peekf(value as ^^ubyte + offsetof(Value.bytes)))
            ValueType::STRING -> txt.print(value as ^^ubyte + offsetof(Value.bytes) + 1)
            ValueType::FUN    -> txt.print("(function)")
            else -> { txt.print("unrecognized value type ") txt.print_ub(value.type) sys.exit(1) }
        }
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
        sys.memcopy(value, valptr, sizeof(Value))
        array.count += 1
    }

    sub freeArray(^^ValueArray array) {
        void mem.alloc(array.values, array.capacity * sizeof(Value), 0)
        initArray(array)
    }
}
