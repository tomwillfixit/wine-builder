# Makefile to build wine and create an extracted version of League of Legends

wine:
	./build_wine.sh

league:
	./extract_league_exe.sh ${exe}

clean-wine:
	rm -rf wine

clean-league:
	rm -rf LoL_installed

cleanall: clean-wine clean-league
