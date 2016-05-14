all: 
	make clean build upload
clean:
	touch icinga2-config.tgz ; rm icinga2-config.tgz
build:
	tar -cvzf icinga2-config.tgz etc opt
upload:
	s3put -p `pwd` -b icinga2-deploy  icinga2-config.tgz 

