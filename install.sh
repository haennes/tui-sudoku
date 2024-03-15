#! /bin/bash
#Make the shell script executable, and copy it to the $PATH:
chmod +x tui-sudoku.sh
cp tui-sudoku.sh  $HOME/.local/bin/
#Create the necessary directories:
mkdir -p $HOME/.config/tui-sudoku/ $HOME/.cache/tui-sudoku/saved_games/
mkdir -p  $HOME/.cache/tui-sudoku/png/
cp tui-sudoku.config $HOME/.config/tui-sudoku/tui-sudoku.config
touch $HOME/.cache/tui-sudoku/history.txt $HOME/.cache/tui-sudoku/hiscores.txt
cp -r png/ $HOME/.cache/tui-sudoku/
