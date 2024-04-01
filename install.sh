#! /bin/bash
#make sh executable, copy it to the $PATH
chmod +x tui-sudoku.sh
[[ -d $HOME/.local/bin/ ]]&&cp tui-sudoku.sh $HOME/.local/bin/&&INSTALL_MESSAGE="The script was copied to\n\e[33m $HOME/.local/bin/\e[m\nProvided that this directory is included in the '\$PATH', the user can run the script with\n\e[33m$ tui-sudoku.sh\e[m\nfrom any directory.\nAlternatively, the script can be run with\n\e[33m$ ./tui-sudoku.sh\e[m\nfrom the tui-sudoku/ directory."||INSTALL_MESSAGE="The script has been made executable and the user can run it with:\n\e[33m$ ./tui-sudoku.sh\e[m\nfrom the tui-sudoku/ directory."


# create the necessary directories and files:
mkdir -p $HOME/.local/share/tui-sudoku/ $HOME/.local/share/tui-sudoku/saved_games/  $HOME/.config/tui-sudoku/
touch $HOME/.local/share/tui-sudoku/history.txt $HOME/.local/share/tui-sudoku/hiscores.txt
cp -r png/ $HOME/.local/share/tui-sudoku/


echo -e "#This variable configures the symmetry of the given cells
# in the puzzle. Valid options are:
# none, rotate90, rotate180, mirror, flip, or random

SYMMETRY=random

#Text editor to open config file
PREFERRED_EDITOR=${EDITOR-nano}

#This variable defines the png that shows in the notifications
#These images are in the $HOME/.local/share/tui-sudoku/png/ directory.
PREFERRED_PNG=2sudoku.png">$HOME/.config/tui-sudoku/tui-sudoku.config
echo -e "$INSTALL_MESSAGE"
