#!/bin/sh

TARGETS="HTML5 Linux32 Linux64 Windows32 Windows64 Mac"

mkdir export


for t in $TARGETS; do
    mkdir export/$t
    godot src/project.godot --export $t export/$t 
done
