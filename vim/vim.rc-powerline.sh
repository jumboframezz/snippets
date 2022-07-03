cat >> ~/.vimrc << EOF

python3 import sys
python3 sys.path.insert(0, "~/.local/lib/python3.10/site-packages/")

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

set laststatus=2
set number
EOF