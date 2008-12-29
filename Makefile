PKGNAME=grabcd
VERSION=0009

DISTDIR=$(PKGNAME)-$(VERSION)
DISTFILE=$(DISTDIR).tar.gz

BINARIES=grabcd-encode grabcd-rip grabcd-scan
CONFIG=
DOCUMENTS=HISTORY README

DIRS=Grabcd

FILES=$(BINARIES) $(CONFIG) $(DOCUMENTS)

#MANDIR=./manpages
#POD2MANOPTS=--release=$(VERSION) --center=$(PKGNAME) --section=1

all:	dist

clean:
	rm -f *~
#	rm -rf $(MANDIR)

#generate-manpages:
#	rm -rf $(MANDIR)
#	mkdir $(MANDIR)
#	for FILE in $(BINARIES); do pod2man $(POD2MANOPTS) $$FILE $(MANDIR)/$$FILE.1; done

dist:	clean # generate-manpages
	rm -rf $(DISTDIR)
	mkdir $(DISTDIR)
	cp $(FILES) $(DISTDIR)
	cp -R $(DIRS) $(DISTDIR)
#	set version
	for FILE in $(FILES); do \
		sed --in-place --expression="s/@@git@@/$(VERSION)/" $(DISTDIR)/"$$FILE"; \
	done
#	cp $(MANDIR)/* $(DISTDIR)
	tar -czvf $(DISTFILE) $(DISTDIR)
	rm -rf $(DISTDIR)

#	Debian convenience
	ln $(DISTFILE) $(PKGNAME)_$(VERSION).orig.tar.gz
