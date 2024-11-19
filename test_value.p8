%import String
%import Value
%import txt

%zeropage basicsafe
main {
    sub start() {
        txt.lowercase()
        uword value1 = memory("value1", Value.SIZE, 1)
        uword value2 = memory("value2", Value.SIZE, 1)
        Value.initCstring(value1, "Hello")
        txt.print("value1 is '")
        String.print(Value.get_string(value1))
        txt.println("'")
        txt.print("Value.print: ")
        Value.print(value1)
        txt.nl()
        Value.initCstring(value2, ", world!")
        txt.print("value2 is '")
        String.print(Value.get_string(value2))
        txt.println("'")
        txt.print("Value.print: ")
        Value.print(value2)
        txt.nl()

        if Value.binOp(Value.add, value1, value2, value1) {
            txt.print("success! Value.print(value1):")
            Value.print(value1)
            txt.nl()
        } else {
            txt.println("Error")
        }
    }
}
