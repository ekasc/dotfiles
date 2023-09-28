sketchybar -m \
	--add item date center \
	--set date update_freq=60 \
	background.color=$BACKGROUND \
	background.height=30 \
	label.color=$WHITE \
	icon.padding_right=10 \
	label.font.style="Regular"\
	label.padding_right=10 \
	script="~/.config/sketchybar/plugins/date.sh" \
	--add item time center\
	--set time update_freq=2 \
	icon.padding_right=0 \
	background.height=30 \
	label.padding_left=10 \
	label.padding_right=10 \
	background.color=$BACKGROUND \
	script="~/.config/sketchybar/plugins/time.sh" \
