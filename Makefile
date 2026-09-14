default: p8lox.prg

p8lox.prg: main.prg
	mv $< $@

%.prg: %.p8
	prog8c12 -target cx16 $<
