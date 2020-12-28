#!/bin/sh
tmux new-session -s bitcoin \; \
rename-window "web" \; \
send 'nvim .' ENTER \; \
split-window -h \; \
resize-pane -R 40 \; \
send 'mix test.watch' ENTER \; \
split-window -v \; \
send 'htop' ENTER \; \
attach;
