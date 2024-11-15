ENTRYPOINT := main.p8 

p8lox.prg: $(ENTRYPOINT) Chunk.p8 Chunk_def.p8 memory.p8 palloc.p8 util.p8
	prog8c -target cx16 "$<"
	mv main.prg $@

%_def.p8: %.def
	mkp8class $* $< >$@
