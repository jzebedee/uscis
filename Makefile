all:
	./build_db.sh

clean:
	rm -f *.json *.db *.cookies sqldiff.txt changelog.txt

#del /Q *.JSON *.DB *.TXT 2>nul || rm -f *.JSON *.DB *.TXT