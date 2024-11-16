ENTRYPOINT := main.p8 
FILES := Chunk.p8 Chunk_def.p8 VM.p8 VM_def.p8 Value.p8 ValueArray.p8 \
         ValueArray_def.p8 Value_def.p8 debug.p8 main.p8 memory.p8 \
         palloc.p8 txt.p8 util.p8

p8lox.prg: $(ENTRYPOINT) $(FILES)
	prog8c -target cx16 "$<"
	mv main.prg $@

%_def.p8: %.def
	mkp8class $* $<
