all:
	./build_db.sh

clean:
	rm -f *.json *.db *.cookies sqldiff.txt changelog.txt

publish:
	mv prev/*.db prev/old.db.bak
	mkdir -p pub/
	mv changelog.txt pub/
	cp *.db pub/
	cp *.db prev/

clean-publish:
	rm -rf pub/
	rm prev/*.bak

clean-all: clean clean-publish

examine-responses:
	mkdir -p _examine/
	unzip responses-db.zip -d _examine/ && rm responses-db.zip
	sqlite3 _examine/responses.db -Ax _examine/ && rm _examine/responses.db
