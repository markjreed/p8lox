%import floats
%import mem

values {
    enum ValueType {
        NIL, BOOL, NUM, STRING, FUN
    }

    sub typeName(ubyte type) -> str {
        when type {
           ValueType::NIL ->  return "nil"
           ValueType::BOOL ->  return "bool"
           ValueType::NUM ->  return "num"
           ValueType::STRING ->  return "string"
           ValueType::FUN ->  return "function"
        }
    }

    struct Value {
        ubyte type
        ubyte[5] bytes
    }

    ^^Value NIL = ^^Value:[ValueType::NIL, [0, 0, 0, 0, 0]]

    sub bytesPtr(^^Value value) -> ^^ubyte {
        return value as ^^ubyte + offsetof(Value.bytes)
    }

    sub new() -> ^^Value {
        return mem.alloc(0, 0, sizeof(Value))
    }

    sub duplicate(^^Value value) -> ^^Value {
        ^^Value result = new()
        assign(result, value)
        return result
    }

    sub makeBool(bool value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::BOOL
        pokebool(bytesPtr(result), value)
        return result
    }

    sub makeNum(float value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::NUM
        pokef(bytesPtr(result), value)
        return result
    }

    sub makeString(str value) -> ^^Value {
        ^^Value result = new()
        result.type = ValueType::STRING
        result.bytes[0] = strings.length(value)
        pokew(bytesPtr(result)+1, value)
        return result
    }

    sub print(^^Value value) {
        ^^ubyte bytes = bytesPtr(value)
        when value.type {
            ValueType::NIL    -> txt.print("NIL") 
            ValueType::BOOL   -> txt.print_bool(peekbool(bytes))
            ValueType::NUM    -> txt.print_f(peekf(bytes))
            ValueType::STRING -> txt.print(peekw(bytes))
            ValueType::FUN    -> txt.print("(function)")
            else -> { txt.print("unrecognized value type ") txt.print_ub(value.type) sys.exit(1) }
        }
    }

    sub negate(^^Value value) -> ^^Value {
        if value.type != ValueType::BOOL and value.type != ValueType::NUM {
            return value
        }

        ^^Value result = duplicate(value)
        ^^ubyte src = bytesPtr(value)
        ^^ubyte dest = bytesPtr(result)
        when value.type {
            ValueType::BOOL  -> pokebool(dest, not peekbool(src))
            ValueType::NUM    -> pokef(dest, -peekf(src))
        }
        return result
    }

    sub add(^^Value value1, ^^Value value2) -> ^^Value {
        if value1.type != value2.type {
            txt.print("mismatched types for addition: ")
            txt.print(typeName(value1.type)) txt.print(" and ")
            txt.print(typeName(value2.type)) txt.nl()
            sys.exit(1)
        }

        if value1.type != ValueType::BOOL and value1.type != ValueType::NUM {
            txt.print("unsupported type for addition: ")
            txt.print(typeName(value1.type)) txt.nl()
            sys.exit(1)
        }

        ^^Value result = duplicate(value1)
        ^^ubyte src = bytesPtr(value2)
        ^^ubyte dest = bytesPtr(result)
        when value1.type {
            ValueType::BOOL  -> pokebool(dest, peekbool(src) or peekbool(dest))
            ValueType::NUM   -> pokef(dest, peekf(src) + peekf(dest))
        }
        return result
    }

    sub subtract(^^Value value1, ^^Value value2) -> ^^Value {
        if value1.type != value2.type {
            txt.print("mismatched types for subtraction: ")
            txt.print(typeName(value1.type)) txt.print(" and ")
            txt.print(typeName(value2.type)) txt.nl()
            sys.exit(1)
        }

        if value1.type != ValueType::NUM {
            txt.print("unsupported type for subtraction: ")
            txt.print(typeName(value1.type)) txt.nl()
            sys.exit(1)
        }

        ^^Value result = negate(value2)
        return add(value1, result)
        return result
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

    sub assign(^^Value dest, ^^Value src) -> ^^Value {
        sys.memcopy(src, dest, sizeof(Value))
        return dest
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
        void assign(valptr, value)
        array.count += 1
    }

    sub freeArray(^^ValueArray array) {
        void mem.alloc(array.values, array.capacity * sizeof(Value), 0)
        initArray(array)
    }
}
