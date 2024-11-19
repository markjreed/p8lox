%import String
%import txt

%zeropage basicsafe
main {
    sub start() {
        txt.lowercase()
        uword theString = memory("theString", String.SIZE, 1)
        String.empty(theString)
        String.appendCstring(theString, "Hello")
        String.print(theString)
        txt.nl()
        txt.nl()
        String.appendCstring(theString, ", world!")
        String.print(theString)
        txt.nl()
        txt.nl()
        txt.println_suw("final capacity: ", String.get_capacity(theString), 0)
    }
}
