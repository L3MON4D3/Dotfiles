shopt -s extglob

# don't source wm.sh, it starts the window manager and (potentially) doesn't return.
for file in ~/.bashrc.d/!(wm.sh); do
	source "$file"
done
