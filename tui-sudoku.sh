#! /bin/bash
#  ╭───╮╭───╮╭───╮ a program written in
#  │ S ││   ││   │ bash by
#  ╰───╯╰───╯╰───╯ Christos Angelopoulos
#  ╭───╮╭───╮╭───╮ under GPLv2 license
#  │ U ││ D ││   │ September 2023
#  ╰───╯╰───╯╰───╯
#  ╭───╮╭───╮╭───╮
#  │ O ││ K ││ U │
#  ╰───╯╰───╯╰───╯


function pause ()
{
	clear
	echo -e "\n${C2}     ╭───╮${C1}╭───╮╭───╮\n${C2}     │ P │${C1}│   ││   │\n${C2}     ╰───╯${C1}╰───╯╰───╯\n${C2}     ╭───╮╭───╮${C1}╭───╮\n${C2}     │ A ││ U │${C1}│   │\n${C2}     ╰───╯╰───╯${C1}╰───╯\n${C1}     ${C2}╭───╮╭───╮╭───╮\n${C1}     ${C2}│ S ││ E ││ D │\n${C1}     ${C2}╰───╯╰───╯╰───╯\n"
	PAUSED_SECONDS_START="$(date +%s)"
	echo -e "\n${C6}Press any key to return to the game${n}"
	read -sN 1 v
	PAUSED_SECONDS_STOP="$(date +%s)"
	PAUSED_SECONDS="$(($PAUSED_SECONDS_STOP-$PAUSED_SECONDS_START))"
	TIMER_START=$(($TIMER_START+$PAUSED_SECONDS))
}

function load_info ()
{
	if [[ $INFO -eq 0 ]]
	then
		INFO_STR[0]=" ╭────────────────────────────╮"
		INFO_STR[1]=" │${C6} hjkl 🠄 🠅🠇🠆    ${C7} Move Cursor ${C1}│"
		INFO_STR[2]=" ├────────────────────────────┤"
		INFO_STR[3]=" │${C6} [1-9]       ${C7} Insert Number ${C1}│"
		INFO_STR[4]=" ├────────────────────────────┤"
		INFO_STR[5]=" │${C6} 0 ␣ ␈       ${C7} Delete Number ${C1}│"
		INFO_STR[6]=" ├────────────────────────────┤"
		INFO_STR[7]=" │${C6} E                 ${C7} Earmark ${C1}│"
		INFO_STR[8]=" ├─────────────┬──────────────┤"
		INFO_STR[9]=" │${C6} H ${C7}Highlight ${C1}│${C6} P     ${C7} Pause ${C1}│"
		INFO_STR[10]=" ├─────────────┼──────────────┤"
		INFO_STR[11]=" │${C6} S      ${C7}Save ${C1}│${C6} I ${C7} Hide Info ${C1}│"
		INFO_STR[12]=" ├─────────────┼──────────────┤"
		INFO_STR[13]=" │${C6} z      ${C7}Undo ${C1}│${C6} Z  ${C7}     Redo ${C1}│"
		INFO_STR[14]=" ├─────────────┼──────────────┤"
		INFO_STR[15]=" │${C6} Q      ${C7}Quit ${C1}│${C6} M  ${C7}Main Menu ${C1}│"
		INFO_STR[16]=" ├─────────────┴──────────────┤"
		INFO_STR[17]=" │${MESSAGE:0:40}${C1}│"
		INFO_STR[18]="${C1} ╰────────────────────────────╯${n}"
		INFO_STR[19]=""
		INFO=1
	else
		for i in {0..18}
		do
			INFO_STR[i]=""
		done
		INFO_STR[19]="${C7}       Enter  ${C6}I  ${C7} to Show Info ${n}"
		INFO=0
	fi
}
function label ()
{
	W=${1^^}
	LABEL0="${C1}╔═══"
	LABEL1="${C1}║ ${C6}${W:0:1} "
	LABEL2="${C1}╚═══"
	WLENGTH="${#W}"
	CHRCTR=1
	while [[ $CHRCTR -lt $WLENGTH ]]
	do
		LABEL0="$LABEL0""╤═══"
		LABEL1="$LABEL1""${C1}│ ${C6}${W:CHRCTR:1} "
		LABEL2="$LABEL2""╧═══"
		((CHRCTR++))
	done
	LABEL0="$LABEL0""╗"
	LABEL1="$LABEL1""${C1}║"
	LABEL2="$LABEL2""╝"
	echo -e "$LABEL0\n$LABEL1\n$LABEL2"
}

function undo_redo ()
{
	HISTORY_LENGTH=$(cat $HOME/.cache/tui-sudoku/history.txt|wc -l)
	if [[ $db == "z" ]]
	then
		if [[ $(($INDEX+1)) -lt $HISTORY_LENGTH ]]
		then
			((INDEX++))
		fi # LENGTH
	elif [[ $db == "Z" ]]
	then
		if [[ $INDEX -ge 1 ]]
		then
			((INDEX--))
		fi # LENGTH
	fi #db
	HIST_LINE="$(tail -$(($INDEX+1)) $HOME/.cache/tui-sudoku/history.txt|head -1)"
	NEW_CURSOR="$(echo $HIST_LINE|awk -F - '{print $1}')"
	G[NEW_CURSOR]="$(echo $HIST_LINE|awk -F - '{print $2}'|sed 's/0/ /g')"
	check_duplicates
	mv_cursor
}

function reg_history ()
{
	if [[ $INDEX -gt 0 ]]
	then
		head -n -$(($INDEX+1))  $HOME/.cache/tui-sudoku/history.txt > $HOME/.cache/tui-sudoku/history_tmp.txt && mv $HOME/.cache/tui-sudoku/history_tmp.txt $HOME/.cache/tui-sudoku/history.txt
		INDEX=0
	fi
	c=${G[CURSOR]// /0}
	echo "$CURSOR-$c-">>$HOME/.cache/tui-sudoku/history.txt
	echo "$CURSOR-$NEW_G-">>$HOME/.cache/tui-sudoku/history.txt
}

function print_9x9
{
	if [[ $INFO -eq 1 ]];then INFO_STR[17]=" │${MESSAGE:0:40}${C1}│";fi
	echo -e "${C1}     1   2   3   4   5   6   7   8   9    "
	echo -e "${C1}   ╔═══╤═══╤═══╦═══╤═══╤═══╦═══╤═══╤═══╗ ${INFO_STR[0]}"
	echo -e "${C1} 1 ║${X[0]}${G[0]}${n}${C1}│${X[1]}${G[1]}${n}${C1}│${X[2]}${G[2]}${n}${C1}║${X[3]}${G[3]}${n}${C1}│${X[4]}${G[4]}${n}${C1}│${X[5]}${G[5]}${n}${C1}║${X[6]}${G[6]}${n}${C1}│${X[7]}${G[7]}${n}${C1}│${X[8]}${G[8]}${n}${C1}║ ${INFO_STR[1]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[2]}"
	echo -e "${C1} 2 ║${X[9]}${G[9]}${n}${C1}│${X[10]}${G[10]}${n}${C1}│${X[11]}${G[11]}${n}${C1}║${X[12]}${G[12]}${n}${C1}│${X[13]}${G[13]}${n}${C1}│${X[14]}${G[14]}${n}${C1}║${X[15]}${G[15]}${n}${C1}│${X[16]}${G[16]}${n}${C1}│${X[17]}${G[17]}${n}${C1}║ ${INFO_STR[3]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[4]}"
	echo -e "${C1} 3 ║${X[18]}${G[18]}${n}${C1}│${X[19]}${G[19]}${n}${C1}│${X[20]}${G[20]}${n}${C1}║${X[21]}${G[21]}${n}${C1}│${X[22]}${G[22]}${n}${C1}│${X[23]}${G[23]}${n}${C1}║${X[24]}${G[24]}${n}${C1}│${X[25]}${G[25]}${n}${C1}│${X[26]}${G[26]}${n}${C1}║ ${INFO_STR[5]}"
	echo -e "${C1}   ╠═══╪═══╪═══╬═══╪═══╪═══╬═══╪═══╪═══╣ ${INFO_STR[6]}"
	echo -e "${C1} 4 ║${X[27]}${G[27]}${n}${C1}│${X[28]}${G[28]}${n}${C1}│${X[29]}${G[29]}${n}${C1}║${X[30]}${G[30]}${n}${C1}│${X[31]}${G[31]}${n}${C1}│${X[32]}${G[32]}${n}${C1}║${X[33]}${G[33]}${n}${C1}│${X[34]}${G[34]}${n}${C1}│${X[35]}${G[35]}${n}${C1}║ ${INFO_STR[7]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[8]}"
	echo -e "${C1} 5 ║${X[36]}${G[36]}${n}${C1}│${X[37]}${G[37]}${n}${C1}│${X[38]}${G[38]}${n}${C1}║${X[39]}${G[39]}${n}${C1}│${X[40]}${G[40]}${n}${C1}│${X[41]}${G[41]}${n}${C1}║${X[42]}${G[42]}${n}${C1}│${X[43]}${G[43]}${n}${C1}│${X[44]}${G[44]}${n}${C1}║ ${INFO_STR[9]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[10]}"
	echo -e "${C1} 6 ║${X[45]}${G[45]}${n}${C1}│${X[46]}${G[46]}${n}${C1}│${X[47]}${G[47]}${n}${C1}║${X[48]}${G[48]}${n}${C1}│${X[49]}${G[49]}${n}${C1}│${X[50]}${G[50]}${n}${C1}║${X[51]}${G[51]}${n}${C1}│${X[52]}${G[52]}${n}${C1}│${X[53]}${G[53]}${n}${C1}║ ${INFO_STR[11]}"
	echo -e "${C1}   ╠═══╪═══╪═══╬═══╪═══╪═══╬═══╪═══╪═══╣ ${INFO_STR[12]}"
	echo -e "${C1} 7 ║${X[54]}${G[54]}${n}${C1}│${X[55]}${G[55]}${n}${C1}│${X[56]}${G[56]}${n}${C1}║${X[57]}${G[57]}${n}${C1}│${X[58]}${G[58]}${n}${C1}│${X[59]}${G[59]}${n}${C1}║${X[60]}${G[60]}${n}${C1}│${X[61]}${G[61]}${n}${C1}│${X[62]}${G[62]}${n}${C1}║ ${INFO_STR[13]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[14]}"
	echo -e "${C1} 8 ║${X[63]}${G[63]}${n}${C1}│${X[64]}${G[64]}${n}${C1}│${X[65]}${G[65]}${n}${C1}║${X[66]}${G[66]}${n}${C1}│${X[67]}${G[67]}${n}${C1}│${X[68]}${G[68]}${n}${C1}║${X[69]}${G[69]}${n}${C1}│${X[70]}${G[70]}${n}${C1}│${X[71]}${G[71]}${n}${C1}║ ${INFO_STR[15]}"
	echo -e "${C1}   ╟───┼───┼───╫───┼───┼───╫───┼───┼───╢ ${INFO_STR[16]}"
	echo -e "${C1} 9 ║${X[72]}${G[72]}${n}${C1}│${X[73]}${G[73]}${n}${C1}│${X[74]}${G[74]}${n}${C1}║${X[75]}${G[75]}${n}${C1}│${X[76]}${G[76]}${n}${C1}│${X[77]}${G[77]}${n}${C1}║${X[78]}${G[78]}${n}${C1}│${X[79]}${G[79]}${n}${C1}│${X[80]}${G[80]}${n}${C1}║ ${INFO_STR[17]}"
	echo -e "${C1}   ╚═══╧═══╧═══╩═══╧═══╧═══╩═══╧═══╧═══╝ ${INFO_STR[18]} \n ${INFO_STR[19]}"
}
function show_hiscores ()
{
	echo -e "${C1}╔═══╤═══╤═══╦═══╤═══╤═══╦═══╤═══╤═══╗ \n║   │ ${C2}T${C1} │ ${C2}O${C1} ║ ${C2}P${C1} │   │ ${C2}T${C1} ║ ${C2}E${C1} │ ${C2}N${C1} │   ║\n╚═══╧═══╧═══╩═══╧═══╧═══╩═══╧═══╧═══╝\n╔═══╤═══╤═══╤═══╤═══╤═══╗\n║ ${C2}L ${C1}│ ${C2}E ${C1}│ ${C2}V ${C1}│ ${C2}E ${C1}│ ${C2}L ${C1}│   ║\n╚═══╧═══╧═══╧═══╧═══╧═══╝"
	label $LEVEL
	sort -h $HOME/.cache/tui-sudoku/hiscores.txt|grep $LEVEL|cat -n|head -10|awk '{print $1" "$3" "$4" "$5" "$6" "$7" "$8}' |column -t|lolcat -p 3000 -a -s 40 -F 0.3
}

function win_game ()
{
	clear
	TIMER_STOP="$(date +%s)"
	SECONDS=$(($TIMER_STOP-$TIMER_START))
	MINUTES="$(( $SECONDS / 60 ))"
	SECMLEFT="$(( $SECONDS - $((MINUTES * 60 )) ))"
	TIME="$MINUTES mins $SECMLEFT secs"
	if [[ $(grep $LEVEL $HOME/.cache/tui-sudoku/hiscores.txt|wc -l) -lt 1 ]]
	then
		TENTH=$(($SECONDS+100)); #avoid first time error
	else
		TENTH="$(sort -h $HOME/.cache/tui-sudoku/hiscores.txt|grep $LEVEL|head -10|tail -1|awk '{print $1}')"
	fi
	SCORELINE="$SECONDS $TIME $(date +%Y-%m-%d\ %T) $LEVEL"
	echo -e "${C2}Gongratulations!\nYou solved the puzzle in $MINUTES mins $SECMLEFT secs${n}"
	if [ "$SECONDS" -lt "$TENTH" ]||[[ "$(grep $LEVEL $HOME/.cache/tui-sudoku/hiscores.txt|wc -l)" -lt 10 ]]
	then
		echo $SCORELINE>>$HOME/.cache/tui-sudoku/hiscores.txt
		echo -e "${C2}That's right, you made it to the${n}"
		show_hiscores
	fi
	echo -e "\n${C6}Press any key to return${n}";read -sN 1 v;clear;
	db="M"
}


function main_menu ()
{
	while [[ "$mm" != "q" ]]
	do
		echo -e "${C2}     ╭───╮${C1}╭───╮╭───╮        ╭──────────────────────────────╮"
		echo -e "${C2}     │ S │${C1}│   ││   │        │${C6} n                 ${n}${C7} New Game  ${C1}│"
		echo -e "${C2}     ╰───╯${C1}╰───╯╰───╯        ├──────────────────────────────┤"
		echo -e "${C2}     ╭───╮╭───╮${C1}╭───╮        │${C6} l                ${n}${C7} Load Game  ${C1}│"
		echo -e "${C2}     │ U ││ D │${C1}│   │        ├──────────────────────────────┤"
		echo -e "${C2}     ╰───╯╰───╯${C1}╰───╯        │${C6} c                ${n}${C7} Configure  ${C1}│"
		echo -e "${C2}     ╭───╮╭───╮╭───╮        ${C1}├──────────────────────────────┤"
		echo -e "${C2}     │ O ││ K ││ U │        ${C1}│${C6} s                ${n}${C7}Show Top 10 ${C1}│"
		echo -e "${C2}     ╰───╯╰───╯╰───╯        ${C1}├──────────────────────────────┤${n}"
		echo -e "${C2}                            ${C1}│${C6} q                ${n}${C7}    Exit    ${C1}│"
		echo -e "                            ╰──────────────────────────────╯${n}"
		read -sn 1 mm
		case $mm in
			n) clear;enter_level;new_game;play_menu;
			;;
			l) load_game;MESSAGE="        ${C5}Game Loaded         ";play_menu;
			;;
			c) clear;notify-send -t 5000 -i $HOME/.cache/tui-sudoku/png/"$PREFFERED_PNG" "Configuring tui-sudoku"&eval $PREFERRED_EDITOR $HOME/.config/tui-sudoku/tui-sudoku.config;load_config
			;;
			s) clear;enter_level;show_hiscores;LEVEL="";echo -e "\n${C6}Press any key to return${n}";read -sN 1 v;clear;
			;;
			q) clear;notify-send -t 5000 -i $HOME/.cache/tui-sudoku/png/"$PREFFERED_PNG" "Exited tui-sudoku";
			;;
			*)clear;
		esac
	done
}

function enter_level ()
{
	LEVEL="$(echo -e "simple\neasy\nintermediate\nexpert"|fzf --disabled --cycle --info=hidden --reverse +i +m --color='gutter:-1' --ansi  --preview-window=left,30%,border-none --prompt="Select game difficulty:" --preview='echo -e "\n${C2}     ╭───╮${C1}╭───╮╭───╮\n${C2}     │ L │${C1}│   ││   │\n${C2}     ╰───╯${C1}╰───╯╰───╯\n${C2}     ╭───╮╭───╮${C1}╭───╮\n${C2}     │ E ││ V │${C1}│   │\n${C2}     ╰───╯╰───╯${C1}╰───╯\n${C1}     ╭───╮${C2}╭───╮╭───╮\n${C1}     │   │${C2}│ E ││ L │\n${C1}     ╰───╯${C2}╰───╯╰───╯\n"')"

}


function check_duplicates ()
{
	for i in {0..80} #this loop refreshes wrong color values, ready to be parsed anew
	do
		if [[ "${X[$i]}" == *${C4}* ]]
		then
			X[$i]=${C3}
		fi


	if [[ "${G[$i]}" == *${C4}* ]]||[[ "${G[$i]}" == *${C3}* ]] ##this loop does the same for earmarks
	then
		G[$i]=${G[$i]//"${C4}"/}
		G[$i]=${G[$i]//"${C3}"/}
		X[$i]=${C3}
	fi
	done
	EARMARKS=( ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ )
	for DIGIT in {1..9} #all possible numbers
	do
		EARMARK=${EARMARKS[DIGIT-1]}
		for ROW0 in {0..80..9} #first row cell ROW CHECK
		do
			ROW_STRING=""
			for i in {0..8} #all row cells
			do
				if [[ ${G[$(($ROW0+$i))]} == " $DIGIT " ]]
				then
					ROW_STRING="$ROW_STRING""$DIGIT"
				fi
			done
			#check ROW_STRING length
			if [[ "${#ROW_STRING}" -gt 1 ]]
			then
				MESSAGE="    ${C4}Illegal input : $DIGIT       "
				for i in {0..8}
				do
					if [[ ${G[$(($ROW0+$i))]} == " $DIGIT " ]]&&[[ ${F[$(($ROW0+$i))]} == " 0 " ]]
					then
						X[$(($ROW0+$i))]=${C4}
					fi
					if [[ ${G[$(($ROW0+$i))]} == " $DIGIT " ]]&&[[ ${F[$(($ROW0+$i))]} == " 0 " ]]&&[[ $CURSOR -eq $(($ROW0+$i)) ]]
					then
						X[$(($ROW0+$i))]=${I}${C4}
					fi
				done
			fi
			if [[ "${#ROW_STRING}" -ge 1 ]] #earmark duplicate row check
			then
				for i in {0..8}
				do
					if [[ ${G[$(($ROW0+$i))]} == *"$EARMARK"* ]]
					then
						MESSAGE="     ${C4}Illegal earmark : $DIGIT    "
						#X[$(($ROW0+$i))]=${C4}
						G[ROW0+i]=${G[$(($ROW0+$i))]/$EARMARK/${C4}$EARMARK${C3}} ##################################
					fi
					if [[ ${G[$(($ROW0+$i))]} == *"$EARMARK"* ]]&&[[ $CURSOR -eq $(($ROW0+$i)) ]]
					then
						#X[$(($ROW0+$i))]=${I}${C4}
						X[$(($ROW0+$i))]=${I}${X[$(($ROW0+$i))]}
					fi
				done
			fi #earmark duplicate row check
		done #ROW0
		for COLUMN0 in {0..8} # first column cell COLUMN CHECK
		do
			COLUMN_STRING=""
			for i in {0..72..9} # all column cells
			do
				if [[ ${G[$(($COLUMN0+$i))]} == " $DIGIT " ]]
				then
					COLUMN_STRING="$COLUMN_STRING""$DIGIT"
				fi
			done
			if [[ "${#COLUMN_STRING}" -gt 1 ]]
			then
				MESSAGE="    ${C4}Illegal input : $DIGIT       "
				for i in {0..72..9}
				do
					if [[ ${G[$(($COLUMN0+$i))]} == " $DIGIT " ]]&&[[ ${F[$(($COLUMN0+$i))]} == " 0 " ]]
					then
						X[$(($COLUMN0+$i))]=${C4}
					fi
					if [[ ${G[$(($COLUMN0+$i))]} == " $DIGIT " ]]&&[[ ${F[$(($COLUMN0+$i))]} == " 0 " ]]&&[[ $CURSOR -eq $(($COLUMN0+$i)) ]]
					then
						X[$(($COLUMN0+$i))]=${I}${C4}
					fi
				done
			fi
			if [[ "${#COLUMN_STRING}" -ge 1 ]] #earmark duplicate column check
			then
				for i in {0..72..9}
				do
					if [[ ${G[$(($COLUMN0+$i))]} == *"$EARMARK"* ]]
					then
						MESSAGE="     ${C4}Illegal earmark : $DIGIT    "
#						X[$(($COLUMN0+$i))]=${C4}
						G[COLUMN0+i]=${G[$(($COLUMN0+$i))]/$EARMARK/${C4}$EARMARK${C3}} ##################################
					fi
					if [[ ${G[$(($COLUMN0+$i))]} == *"$EARMARK"* ]]&&[[ $CURSOR -eq $(($COLUMN0+$i)) ]]
					then
						X[$(($COLUMN0+$i))]=${I}${X[$(($COLUMN0+$i))]}
					fi
				done
			fi #earmark duplicate column check
		done #COLUMN0

		for i in {0..80..27} # 3x3SQUARE CHECK
		do
			for ii in {0..6..3}
			do
				SQUARE_STRING=""
				for iii in {0..18..9}
				do
					for iv in {0..2}
					do
						if [[ ${G[$(($i+$ii+$iii+$iv))]} == " $DIGIT " ]]
						then
							SQUARE_STRING="$SQUARE_STRING""$DIGIT"
						fi
					done
				done
				if [[ "${#SQUARE_STRING}" -gt 1 ]]
				then
					MESSAGE="     ${C4}Illegal input : $DIGIT      "
					for iii in {0..18..9}
					do
						for iv in {0..2}
						do
							if [[ ${G[$(($i+$ii+$iii+$iv))]} == " $DIGIT " ]]&&[[ ${F[$(($i+$ii+$iii+$iv))]} == " 0 " ]]
							then
								X[$(($i+$ii+$iii+$iv))]=${C4}
							fi
							if [[ ${G[$(($i+$ii+$iii+$iv))]} == " $DIGIT " ]]&&[[ ${F[$(($i+$ii+$iii+$iv))]} == " 0 " ]]&&[[ $CURSOR -eq $(($i+$ii+$iii+$iv)) ]]
							then
								X[$(($i+$ii+$iii+$iv))]=${I}${C4}
							fi
						done #iv
					done #iii
				fi
				if [[ "${#SQUARE_STRING}" -ge 1 ]] #earmark duplicate square check
				then
					for iii in {0..18..9}
					do
						for iv in {0..2}
						do
							if [[ ${G[$(($i+$ii+$iii+$iv))]} == *"$EARMARK"* ]]
							then
								MESSAGE="     ${C4}Illegal earmark : $DIGIT    "
#								X[$(($i+$ii+$iii+$iv))]=${C4}
						G[i+ii+iii+iv]=${G[$(($i+$ii+$iii+$iv))]/$EARMARK/${C4}$EARMARK${C3}} ##################################
							fi
							if [[ ${G[$(($i+$ii+$iii+$iv))]} == *"$EARMARK"* ]]&&[[ $CURSOR -eq $(($i+$ii+$iii+$iv)) ]]
							then
								X[$(($i+$ii+$iii+$iv))]=${I}${X[$(($i+$ii+$iii+$iv))]}

							fi
						done #iv
					done #iii
				fi #earmark duplicate square check
			done #sq ii
		done #sq i
	done ##DIGIT
	if [[ $high_switch -eq 1 ]]
	then
		highlight_on
	fi
	if [[ ${G[@]} == ${F0[@]} ]];then win_game;fi
	X[CURSOR]=${I}${X[CURSOR]}
}

function save_game ()
{
	FILE="$(date +%Y-%m-%d,%T).sdk"
	for i in {0..80}
	do
		echo "${G[$i]// /0} ${F[$i]// /} ${F0[$i]}">> $HOME/.cache/tui-sudoku/saved_games/"$FILE"
	done
	SAVED_TIMER_STOP="$(date +%s)"
	SAVED_SECONDS=$(($SAVED_TIMER_STOP-$TIMER_START))
	echo "SAVED_SECONDS $SAVED_SECONDS">> $HOME/.cache/tui-sudoku/saved_games/"$FILE"
}

function load_game ()
{
	cat /dev/null>$HOME/.cache/tui-sudoku/history.txt
	cd $HOME/.cache/tui-sudoku/saved_games/
	LOAD="$(ls *sdk|fzf --disabled --info=hidden --cycle --reverse +i +m --color='gutter:-1' --ansi  --preview-window=left,30%,border-none --prompt="Select game to load:" --preview='echo -e "\n${C2}""     ╭───╮"${C1}"╭───╮╭───╮\n"${C2}"     │ L │"${C1}"│   ││   │\n"${C2}"     ╰───╯"${C1}"╰───╯╰───╯\n     ╭───╮"${C2}"╭───╮╭───╮\n"${C1}"     │   │"${C2}"│ O ││ A │\n"${C1}"     ╰───╯"${C2}"╰───╯╰───╯\n"${C1}"     ╭───╮╭───╮"${C2}"╭───╮\n"${C1}"     │   ││   │"${C2}"│ D │\n"${C1}"     ╰───╯╰───╯"${C2}"╰───╯";')"
	cd -

	LINE=1
	while [[ "$LINE" -le 81 ]]
	do
		G[$((LINE-1))]="$(head -$LINE $HOME/.cache/tui-sudoku/saved_games/"$LOAD"|tail +$LINE|awk '{print $1}'|sed 's/0//g')"
		if [[ ${#G[$((LINE-1))]} -eq 0 ]]; then G[$((LINE-1))]="   "
		elif [[ ${#G[$((LINE-1))]} -eq 1 ]]; then G[$((LINE-1))]=" ""${G[$((LINE-1))]}"" "
		elif [[ ${#G[$((LINE-1))]} -eq 2 ]]; then G[$((LINE-1))]="${G[$((LINE-1))]}"" "
		elif [[ ${#G[$((LINE-1))]} -eq 3 ]]; then G[$((LINE-1))]="${G[$((LINE-1))]}";fi
		F[$((LINE-1))]=" ""$(head -$LINE $HOME/.cache/tui-sudoku/saved_games/"$LOAD"|tail +$LINE|awk '{print $2}')"" "
		F0[$((LINE-1))]=" ""$(head -$LINE $HOME/.cache/tui-sudoku/saved_games/"$LOAD"|tail +$LINE|awk '{print $3}')"" "
		if [[ ${F[$((LINE-1))]} == " 0 " ]]
		then
			X[$((LINE-1))]="${C3}"
		else
			X[$((LINE-1))]="${C2}"
		fi
		((LINE++))
	done
	check_duplicates
	SAVED_SECONDS="$(grep "SAVED_SECONDS" $HOME/.cache/tui-sudoku/saved_games/"$LOAD"|awk '{print $2}')"
	TIMER_START=$(($(date +%s)-$SAVED_SECONDS))
	clear
}

function earmark ()
{
	if [[ ${F[$CURSOR]} == " 0 " ]]
	then
		echo -e "${C6}Enter numbers(max 3 digits):${n}"
		read ears
		ears="$(echo "$ears"|sed 's/[a-z]//g;s/[A-Z]//g;s/[[:punct:]]//g;s/1/₁/g;s/2/₂/g;s/3/₃/g;s/4/₄/g;s/5/₅/g;s/6/₆/g;s/7/₇/g;s/8/₈/g;s/9/₉/g;s/ //g')""   "
		ears="${ears:0:3}"
		NEW_G=$ears
		reg_history
		G[CURSOR]="$ears"
	fi
	MESSAGE="        ${C5}Earmarked   $ears     ${n}"
}

function highlight_on ()
{
	for i in {0..80}
	do
		if [[ ${G[$i]} == " $high " ]]
		then
			if [[ ${X[$i]} == *"${C2}"* ]]||[[ ${X[$i]} == *"${C3}"* ]]
			then
				X[i]=${I}${C5}
			fi
		fi
	done
}

function highlight ()
{
	if [[ $high_switch -eq 0 ]]
	then
		if [[ -n "$(echo ${G[$CURSOR]}|grep -E [1-9])" ]]
		then
			high="${G[$CURSOR]// /}"
		fi
		clear
		MESSAGE="  ${C5}Highlight  toggle on      "
		if [[ -z $(echo $high|sed 's/[1-9]//') ]]
		then
		highlight_on
		high_switch=1
		fi
	else
		MESSAGE="  ${C5}Highlight  toggle off     "
		clear
		for i in {0..80}
		do
			if [[ ${X[$i]} != ${I}${C5} ]]&&[[ ${F[$i]} == " 0 " ]]
			then
				X[i]="${C3}"
			fi
			if [[ ${X[$i]} != ${I}${C5} ]]&&[[ ${F[$i]} != " 0 " ]]
			then
				X[i]="${C2}"
			fi
			high_switch=0
			high=""
		done
		X[CURSOR]=${I}${X[CURSOR]}
	fi
}

function load_colors ()
{
LINE=1
	while [[ "$LINE" -le 81 ]]
	do
		if [[ ${F[$((LINE-1))]} == "   " ]]
		then
		X[$((LINE-1))]="${C3}"
		else
		X[$((LINE-1))]="${C2}"
		fi
		((LINE++))
	done
}

function mv_cursor ()
{
	if [[ ${F[$CURSOR]} == " 0 " ]]&&[[ ${X[$CURSOR]} != *"${C4}"* ]]
	then
		X[$CURSOR]=${C3}
	fi
	if [[ ${X[$CURSOR]} != *"${C4}"* ]]&&[[ $high_switch -eq 1 ]]&&[[ ${G[$CURSOR]} == " $high " ]]
	then
		X[$CURSOR]=${I}${C5}
	fi
	if [[ ${X[$CURSOR]} == *"${C4}"* ]]
	then
		X[$CURSOR]=${C4}
	fi
	if [[ ${F[$CURSOR]} != " 0 " ]]&&[[ ${G[$CURSOR]} != " $high " ]]
	then
		X[$CURSOR]=${C2}
	fi
	if [[ ${F[$NEW_CURSOR]} == " 0 " ]]&&[[ ${X[$NEW_CURSOR]} != "${C4}" ]]
	then
		X[$NEW_CURSOR]="${I}${C3}"
	fi
	if [[ ${F[$NEW_CURSOR]} != " 0 " ]]
	then
		X[$NEW_CURSOR]="${I}${C2}"
	fi
	if [[ ${X[$NEW_CURSOR]} == "${C4}" ]]
	then
		X[$NEW_CURSOR]="${I}${C4}"
	fi
	CURSOR="$NEW_CURSOR"
}

function new_game
{
	MESSAGE="          ${C5}GOOD LUCK!        "
	cat /dev/null>$HOME/.cache/tui-sudoku/saved_games/Last_Game.sdk
	cat /dev/null>$HOME/.cache/tui-sudoku/history.txt
	INDEX=0
	INFO=0
	load_info
	Q="$(qqwing --generate 1 --difficulty $LEVEL --symmetry $SYMMETRY --csv --solution|tail -1|sed 's/\./0/g')"
	for x in {0..80}
	do
		F0[x]=" ""${Q:82+x:1}"" "
		F[x]=" ""${Q:x:1}"" "
		G[x]="${F[x]}"
		if [[ ${F[x]} == " 0 " ]]
		then
			G[x]="   "
			X[x]="${C3}"
		else
			X[x]="${C2}"
		fi
		echo "${Q:x:1}"" ""${Q:x:1}"" ""${Q:82+x:1}"" ">>$HOME/.cache/tui-sudoku/saved_games/Last_Game.sdk
	done
	TIMER_START="$(date +%s)"
	clear
}

function play_menu ()
{
	high_switch=0
	db="";
	CURSOR="0"
	X[0]="${I}"${X[0]}
	while [[ "$db" != "M" ]]
	do
		print_9x9
		read -sn 1 db
		if [[ $(echo "$db" | od) = "$backspace" ]]||[[ $(echo "$db" | od) = "$space" ]];then  db="0";fi;
		case $db in
			[j,A]) if  [[ $CURSOR -gt "8" ]]; then NEW_CURSOR=$((CURSOR-9));mv_cursor;fi;clear;
			;;
			[k,B]) if  [[ $CURSOR -le "71" ]]; then NEW_CURSOR=$((CURSOR+9));mv_cursor;fi;clear;
			;;
			[l,C]) if  [[ $CURSOR != "80" ]]; then NEW_CURSOR=$(($CURSOR+1));mv_cursor;fi;clear;
			;;
			[h,D]) if  [[ $CURSOR != "0" ]]; then NEW_CURSOR=$(($CURSOR-1));mv_cursor;fi;clear;
			;;
			[1-9]) if [[ "${F[CURSOR]}" == " 0 " ]];then NEW_G="0""$db""0";reg_history;G[CURSOR]=" ""$db"" ";MESSAGE="     ${C5}Entered number : $db     ";check_duplicates;fi;clear;
			;;
			E) earmark;check_duplicates;clear;
			;;
			H) highlight;
			;;
			S) save_game;MESSAGE="        ${C5}Game Saved          ";clear;
			;;
			P) pause;    MESSAGE="       ${C5}Game Unpaused        ";clear;
			;;
			M) clear;
			;;
			[z,Z]) undo_redo;clear;
			;;
			"0") if [[ ${X[$CURSOR]} != *"${C2}"* ]]&&[[ ${X[$CURSOR]} != *"${C5}"* ]]&&[[ ${G[$CURSOR]} != "   " ]];then NEW_G="000";reg_history;G[CURSOR]="   ";check_duplicates;X[CURSOR]="${I}${C3}";MESSAGE="      ${C5}Cleared Cell          ";fi;clear;
			;;
			Q) clear;G=("${F0[@]}");high_switch=1;highlight;INFO=1;load_info;INFO_STR[19]="\e[3m${C2}El arte de vencer se aprende en las derrotas\n\t\t\t\t${C2}Simón Bolívar${n}${n}";print_9x9;notify-send -t 5000 -i $HOME/.cache/tui-sudoku/png/"$PREFFERED_PNG" "Exited tui-sudoku";echo -e "${C6}Press any key to exit${n}";read -sn 1 v;exit;
			;;
			I) load_info;clear;
			;;
			*)clear;
		esac
# if [[ $db = "W" ]];then win_game;fi ## for debugging reasons
	done
}
function load_config ()
{
	#Loading Grid Color(C1), Given Numbers Color(C2), Found Numbers Color(C3), Wrong Numbers Color(C4), Highlight Color(C5), Text Color1(C6), Text Color2(C7) from $HOME/.config/tui-sudoku/tui-sudoku.config.
	# If there is no such file, default values are given.
	if [[ -f $HOME/.config/tui-sudoku/tui-sudoku.config ]]|| [[ -z "$($HOME/.config/tui-sudoku/tui-sudoku.config)" ]]
	then
		C1="$(grep "GRID_COLOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C2="$(grep "GIVEN_NUMBERS_COLOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C3="$(grep "FOUND_NUMBERS_COLOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C4="$(grep "WRONG_NUMBERS_COLOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C5="$(grep "HIGHLIGHT_COLOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C6="$(grep "TEXT_COLOR1" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		C7="$(grep "TEXT_COLOR2" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		PREFERRED_EDITOR="$(grep "PREFERRED_EDITOR" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		SYMMETRY="$(grep "SYMMETRY" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
		PREFFERED_PNG="$(grep "PREFFERED_PNG" $HOME/.config/tui-sudoku/tui-sudoku.config|awk '{print $2}' )"
	else
		#DEFAULT VALUES
		C1="\x1b[38;5;60m" #Grid Color
		C2="\e[1;33m" #Given Numbers Color
		C3="\e[1;36m" #Found Numbers Color
		C4="\e[1;31m" #Wrong Numbers Color
		C5="\e[1;32m" #Highlight Color
		C6="\e[35m" #TextColor1
		C7="\e[36m" #TextColor1
		PREFERRED_EDITOR="nano"
		SYMMETRY="rotate90"
		PREFFERED_PNG="2sudoku.png"
	fi
}

#########################################################
load_config
I="\e[7m"
n=`tput sgr0`
export C1 C2 C3 C4 C5 C6 C7 I n
backspace=$(cat << eof
0000000 005177
0000002
eof
)
space=$(cat << eof
0000000 000012
0000001
eof
)
clear
main_menu
