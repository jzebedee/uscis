all:
	./build_db.sh

clean:
	rm -f *.json *.db *.txt *.cookies

#del /Q *.JSON *.DB *.TXT 2>nul || rm -f *.JSON *.DB *.TXT