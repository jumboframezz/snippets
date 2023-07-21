#!/bin/bash
# Set system-wide 
cat>> /etc/vimrc << EOF
" .yaml settings for vim"
autocmd FileType yaml setlocal ai ts=2 sw=2 et
autocmd FileType yml setlocal ai ts=2 sw=2 et

" powerline config"
python3 import sys
python3 sys.path.insert(0, "~/.local/lib/python3.10/site-packages/")

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Enable numbers"
set laststatus=2
EOF

# Set per user
cat >> ~/.vimrc << EOF
" .yaml settings for vim"
autocmd FileType yaml setlocal ai ts=2 sw=2 et
autocmd FileType yml setlocal ai ts=2 sw=2 et

" powerline config"
python3 import sys
python3 sys.path.insert(0, "~/.local/lib/python3.10/site-packages/")

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

" Enable numbers"
set laststatus=2

EOF
