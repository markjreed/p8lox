%import Token_def 
%import syslib

Token {
    %option merge
    sub copy(uword source, uword dest) {
        sys.memcopy(source, dest, SIZE)
    }
}
