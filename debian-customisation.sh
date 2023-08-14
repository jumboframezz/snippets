#!/bin/bash

! grep -q "aslias ll" /etc/profile && echo "alias ll='ls -lh'" >> /etc/profile

echo "set nocompatible" > ~/.vimrc
