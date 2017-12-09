#!/usr/bin/make
all:
	mkdir output
	javac turnos/TurnosDemo.java turnos/TurnosGenAlgoUtil.java -d output -cp ../aima-core.jar
	java output/turnos.TurnosDemo -cp ../aima-core.jar:.:output/*

clean:
	rm -r output