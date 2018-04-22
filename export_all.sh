#!/bin/sh

TARGETS="HTML5 Linux32 Linux64 Windows32 Windows64 Mac"
GAME_NAME=Blind_Faith

mkdir export

for t in $TARGETS; do
    mkdir export/$t
    rm -f export/$t/*
    godot src/project.godot --export $t $GAME_NAME
    mv src/$GAME_NAME* export/$t
done

# Ouch...
mv export/Windows32/$GAME_NAME export/Windows32/$GAME_NAME.exe
mv export/Windows64/$GAME_NAME export/Windows64/$GAME_NAME.exe
mv export/Mac/$GAME_NAME export/Mac/$GAME_NAME.zip
mv export/HTML5/$GAME_NAME export/HTML5/$GAME_NAME.html

