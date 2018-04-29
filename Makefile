NAME=hell_of_a_mess

all: love

love:
	zip -r ${NAME}.love *.lua \
		credits.txt Makefile \
		LICENSE README.md

clean:
	rm -f *.love
