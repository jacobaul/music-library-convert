#/bin/bash
shopt -s globstar
outf=/mnt/slowdisk/oggMusic
count="$(find ./ | wc -l)"

declare -i x="$count"
x=$((x-1))

declare -i iter=0

for f in ./**/*; do

	iter=$((iter+1))

	if [[ -d $f ]]; then
		echo "$iter/$x Creating Directory $outf${f: 1}"
		mkdir -p "$outf${f: 1}"
	elif [[ $f = *.flac ]] || [[ $f = *.FLAC ]]; then
		if [[ ! -f $outf${f:1:-4}ogg ]]; then
			echo "$iter/$x Converting file ${f: 1}"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${f:1:-4}ogg" 
		else
			echo "$iter/$x File $outf${f:1:-4}ogg exists, Skipping"
		fi
	
	elif [[ $f = *.wav ]] || [[ $f = *.WAV ]]; then
		if [[ ! -f $outf${f:1:-3}ogg ]]; then
			echo "$iter/$x Converting file ${f: 1}"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${f:1:-3}ogg"
		else
			echo "$iter/$x File $outf${f:1:-3}ogg exists, Skipping"
		fi
	elif [[ $f = *.mp3 ]] || [[ $f = *.MP3 ]]; then
		if [[ ! -f $outf${f:1:-3}ogg ]]; then
			echo "$iter/$x Converting LOSSY file ${f: 1}"
			ffmpeg -loglevel error -i "$f" -c:a libopus -vn -b:a 96K "$outf${f:1:-3}ogg"
		else
			echo "$iter/$x File $outf${f:1:-3}ogg exists, Skipping"
		fi
	else

		if [[ ! -f $outf${f: 1} ]]; then
			echo "$iter/$x Non FLAC/WAV file $outf${f: 1}, copying"
			cp "$f" "$outf${f: 1}"
		else
			echo "Non FLAC/WAV file $outf${f: 1} exists, skipping"
		fi
	fi
done
