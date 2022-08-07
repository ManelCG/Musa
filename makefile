MUSA_VERSION = "Alfa 0"

SDIR = src

IDIR = include
CCCMD = gcc
CFLAGS = -I$(IDIR) `pkg-config --cflags --libs gtk+-3.0` -Wall -Wno-deprecated-declarations

debug: CC = $(CCCMD) -DDEBUG_ALL -DMUSA_VERSION=\"$(MUSA_VERSION)_DEBUG\"
debug: BDIR = debug

release: CC = $(CCCMD) -O2 -DMUSA_VERSION=\"$(MUSA_VERSION)\"
release: BDIR = build

windows: CC = $(CCCMD) -O2 -DMUSA_VERSION=\"$(MUSA_VERSION)\"
windows: BDIR = build

install: CC = $(CCCMD) -O2	-DMAKE_INSTALL -DMUSA_VERSION=\"$(MUSA_VERSION)\"
install: MUSA_DIR = /usr/lib/musa
install: BDIR = $(MUSA_DIR)/bin

archlinux: CC = $(CCCMD) -O2 -DMAKE_INSTALL -DMUSA_VERSION=\"$(MUSA_VERSION)\"

ODIR=.obj
LDIR=lib

LIBS = -lm -lpthread

_DEPS =
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

release: $(OBJ)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/musa $^ $(CFLAGS) $(LIBS)

windows: $(OBJ)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/musa $^ $(CFLAGS) $(LIBS)
	ldd build/musa.exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp "{}" build/

debug: $(OBJ)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/musa $^ $(CFLAGS) $(LIBS)

install: $(OBJ)
	mkdir -p $(MUSA_DIR)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/musa $^ $(CFLAGS) $(LIBS)
	ln -sf $(BDIR)/musa /usr/bin/musa
	# cp assets/musa.desktop /usr/share/applications/
	# cp assets/app_icon/256.png /usr/share/pixmaps/musa.png

archlinux: $(OBJ) $(OBJ_GUI)
	mkdir -p $(BDIR)/usr/lib/musa
	mkdir -p $(BDIR)/usr/share/applications
	mkdir -p $(BDIR)/usr/share/pixmaps
	mkdir -p $(BDIR)/usr/bin/
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/usr/bin/musa $^ $(CFLAGS) $(LIBS)
	# cp -r assets/ $(BDIR)/usr/lib/musa/
	# cp assets/musa.desktop $(BDIR)/usr/share/applications/
	# cp assets/app_icon/256.png $(BDIR)/usr/share/pixmaps/musa.png

.PHONY: clean
clean:
	rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~

.PHONY: all
all: release clean
