%import Scanner_def
Scanner {
    %option merge

    uword scanner = memory("scanner", SIZE, 1)
   
    sub init(uword source)  {
        set_start(scanner, source)
        set_current(scanner, source)
        set_line(scanner, 1)
    }

    sub scan(uword token) {
    }
}
