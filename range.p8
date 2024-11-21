%import floats

range {
    sub Byte() {
        const word MIN = -128
        const word MAX = 127
    }
    sub UByte() {
        const word MIN = 0
        const word MAX = 255
    }
    sub Word() {
        const word MIN = -32768
        const word MAX = 32767
    }
    sub UWord() {
        const word MIN = 0
        const uword MAX = 65535
    }
    sub Float() {
        const float MIN = -1.70141183E38
        const float MAX =  1.70141183E38
    }
}
