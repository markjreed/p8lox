default: p8lox.prg

p8lox.prg: main.prg
	mv $< $@

%.prg: %.p8
	prog8c -target cx16 $<
