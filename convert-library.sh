#/bin/bash

#Exit or errors, undefined variables are errors
set -e
set -u
shopt -s globstar

#Syntax help
usage(){
	echo "Usage: $0 -i [iput directory] -o [output directory]"
}

#Get input options
while getopts 'i:o:h' opt; do
	case $opt in
		i) 
			inf=$OPTARG
			;;
		o) 
			outf=$OPTARG
			;;
		h|?)
			usage
			exit 1
			;;

	esac
done

#Get count of files and directories to process
count="$(find ./ | wc -l)"

declare -i x="$count"
x=$((x-1))

declare -i iter=0


for f in $inf/**/*; do
	fn=${f#"$inf"}

	iter=$((iter+1))

	if [[ -d $f ]]; then
		echo "$iter/$x Creating Directory $outf$fn"
		mkdir -p "$outf$fn"
	elif [[ $f = *.flac ]] || [[ $f = *.FLAC ]]; then
		if [[ ! -f $outf${fn::-4}ogg ]]; then
			echo "$iter/$x Converting file $f"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${fn::-4}ogg" 
		else
			echo "$iter/$x File $outf${fn::-4}ogg exists, Skipping"
		fi
	
	elif [[ $f = *.wav ]] || [[ $f = *.WAV ]]; then
		if [[ ! -f $outf${fn::-3}ogg ]]; then
			echo "$iter/$x Converting file $fn"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${fn::-3}ogg"
		else
			echo "$iter/$x File $outf${fn::-3}ogg exists, Skipping"
		fi
	elif [[ $f = *.mp3 ]] || [[ $f = *.MP3 ]]; then
		if [[ ! -f $outf${fn::-3}ogg ]]; then
			echo "$iter/$x Converting LOSSY file $fn"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${fn::-3}ogg"
		else
			echo "$iter/$x File $outf${fn::-3}ogg exists, Skipping"
		fi
	else

		if [[ ! -f $outf$fn ]]; then
			echo "$iter/$x Non FLAC/WAV file $outf$fn, copying"
			cp "$f" "$outf$fn"
		else
			echo "Non FLAC/WAV file $outf$fn exists, skipping"
		fi
	fi
done


