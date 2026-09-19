%encoding iso
%option ignore_unused
%zeropage basicsafe

%import args
%import files
%import chunks
%import common
%import debug
%import mem
%import textio
%import vm

main {
    alias Chunk = chunks.Chunk
    alias InterpretResult::OK = vm.InterpretResult::OK
    alias InterpretResult::COMPILE_ERROR = vm.InterpretResult::COMPILE_ERROR
    alias InterpretResult::RUNTIME_ERROR = vm.InterpretResult::RUNTIME_ERROR

    sub repl() {
        ubyte[256] line
        ubyte length
        repeat {
            txt.print("> ")
            length = txt.input_chars(line) 
            txt.nl()
            if length > 0 {
                void vm.interpret(line)
            }
        }
    }

    sub runFile(str path) {
        ^^ubyte source = files.slurp(path)
        if source == 0 {
            txt.print("could not load '") txt.print(path) txt.print("'\n")
            sys.exit(74)
        }
        ubyte result = vm.interpret(source)
        mem.free(source)
        if result == InterpretResult::COMPILE_ERROR {
            sys.exit(65)
        }
        if result == InterpretResult::RUNTIME_ERROR {
            sys.exit(70)
        }
    }

    sub start() {
        txt.iso()
        vm.init()
        ubyte argc = args.basic()

        if argc == 0 {
            repl()
        } else if argc == 1 {
            runFile(args.argv[0])
        } else {
            txt.print("Usage: RUN [filename]\n")
            sys.exit(64)
        }

        vm.free()
    }
}
