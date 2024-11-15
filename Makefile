ENTRYPOINT := main.p8

p8lox.prg: $(ENTRYPOINT)
	prog8c -target cx16 "$<"
