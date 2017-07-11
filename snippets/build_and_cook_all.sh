FLAVORS="lime_default lime_zero lime_mini"
COMM=""
export J=1

./cooker --download-all
bash snippets/copy_signing_keys.sh

./cooker --update-feeds
./cooker --build-all # --clean

for F in $FLAVORS; do
	./cooker --cook-all --flavor=$F
	for C in $COMM; do
		./cooker --cook-all --flavor=$F --community=$C
	done
done
