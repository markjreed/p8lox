ENTRYPOINT := repl.p8 
FILES := Chunk.p8 Chunk_def.p8 INTERPRET_def.p8 OP_def.p8 Scanner.p8 \
		 Scanner_def.p8 String.p8 String_def.p8 Token.p8 Token_def.p8 VM.p8 \
		 VM_def.p8 Value.p8 ValueArray.p8 ValueArray_def.p8 Value_def.p8 \
		 common.p8 compiler.p8 debug.p8 interpret.p8 memory.p8 palloc.p8 \
		 repl.p8 test_string.p8 test_value.p8 txt.p8 util.p8

p8lox.prg: $(ENTRYPOINT) $(FILES)
	prog8c -target cx16 "$<"
	mv repl.prg $@

%_def.p8: %.def ~/bin/mkp8class
	mkp8class $* $<
