#!/bin/bash

if [ ! -d "$HOME/Desktop" ]; then
	mkdir -p "$HOME/Desktop"
fi

ln -s /usr/share/applications/*ael* $HOME/Desktop/
