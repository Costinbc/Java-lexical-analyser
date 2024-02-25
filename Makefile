# Bosoaga Costin 332CC
lex.yy.c: tema.l
	lex tema.l
	g++ lex.yy.c -o tema -g

clean:
	rm -f tema lex.yy.c