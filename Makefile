AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/eeprom.s 

ifeq ($(CC65_HOME),)
        CC = cl65
        AS = ca65
        LD = ld65
        AR = ar65
else
        CC = $(CC65_HOME)/bin/cl65
        AS = $(CC65_HOME)/bin/ca65
        LD = $(CC65_HOME)/bin/ld65
        AR = $(CC65_HOME)/bin/ar65
endif


ifdef TRAVIS_BRANCH
ifeq ($(TRAVIS_BRANCH), master)
RELEASE:=$(shell cat VERSION)
else
RELEASE=alpha
endif
endif


all : srccode code
.PHONY : all

HOMEDIR=/home/travis/bin/

SOURCE=src/$(PROGRAM).c


ifdef TRAVIS_BRANCH
ifeq ($(TRAVIS_BRANCH), master)

RELEASE:=$(shell cat VERSION)
else
RELEASE:=alpha
endif
endif



MYDATE = $(shell date +"%Y-%m-%d %H:%m")
  
code: $(SOURCE)
	$(CC) -I libs/usr/include/ $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM) libs/lib8/ch376.lib libs/lib8/twil.lib


srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/src/$(PROGRAM)/src/
	cp configure build/usr/src/$(PROGRAM)/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp README.md build/usr/src/$(PROGRAM)/	
	cp -adpR src/* build/usr/src/$(PROGRAM)/src/

test:
	mkdir -p build/usr/share/$(PROGRAM)/
	mkdir -p build/usr/share/ipkg/
	mkdir -p build/usr/share/man/  
	mkdir -p build/usr/share/doc/$(PROGRAM)/

	mkdir -p build/usr/src/$(PROGRAM)/src/
	
	mkdir -p build/bin/
	cp $(PROGRAM) build/bin/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp configure build/usr/src/$(PROGRAM)/	
	cp README.md build/usr/src/$(PROGRAM)/	
	cp src/* build/usr/src/$(PROGRAM)/src/ -adpR
	cd build && tar -c * > ../$(PROGRAM).tar &&	cd ..
	gzip $(PROGRAM).tar
	mv $(PROGRAM).tar.gz $(PROGRAM).tgz

	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM).tgz ${hash} 6502 tgz $(RELEASE)

  
  
