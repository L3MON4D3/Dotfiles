shopt -s extglob

# source in alphanumerically ascending order.
for file in ~/.bashrc.d/*; do
	source "$file"
done
