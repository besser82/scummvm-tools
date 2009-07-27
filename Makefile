# $URL$
# $Id$

#######################################################################
# Default compilation parameters. Normally don't edit these           #
#######################################################################

srcdir      ?= .

DEFINES     := -DUNIX
STANDALONE  := 
# This one will go away once all tools are converted
NO_MAIN     := -DEXPORT_MAIN
LDFLAGS     := $(LDFLAGS)
INCLUDES    := -I. -I$(srcdir)
LIBS        :=
OBJS        :=
DEPDIR      := .deps

# Load the make rules generated by configure
# HACK: We don't yet support configure in the tools SVN module, but at least one can
# manually create a config.mk files with overrides, if needed.
-include config.mk

CXXFLAGS  += -g -O

# Additional warnings
CXXFLAGS:= -Wall $(CXXFLAGS)
# Turn off some annoying and not-so-useful warnings
CXXFLAGS+= -Wno-long-long -Wno-multichar -Wno-unknown-pragmas -Wno-reorder
# Enable even more warnings...
#CXXFLAGS+= -pedantic	# -pedantic is too pedantic, at least on Mac OS X
CXXFLAGS+= -Wpointer-arith -Wuninitialized -Wcast-align
CXXFLAGS+= -Wshadow -Wimplicit -Wundef -Wnon-virtual-dtor -Wwrite-strings

# Enable checking of pointers returned by "new"
CXXFLAGS+= -fcheck-new

#######################################################################
# Default commands - put the necessary replacements in config.mk      #
#######################################################################

CAT     ?= cat
CP      ?= cp
ECHO    ?= printf
INSTALL ?= install
MKDIR   ?= mkdir -p
RM      ?= rm -f
RM_REC  ?= $(RM) -r
ZIP     ?= zip -q

CC      := gcc
CXX     := g++

#######################################################################

# HACK: Until we get proper module support, add these "module dirs" to 
# get the dependency tracking code working.
MODULE_DIRS := ./ utils/

#######################################################################

TARGETS := \
	decine$(EXEEXT) \
	dekyra$(EXEEXT) \
	descumm$(EXEEXT) \
	desword2$(EXEEXT) \
	degob$(EXEEXT) \
	tools_cli$(EXEEXT) \
	tools_gui$(EXEEXT)

UTILS := \
	utils/adpcm.o \
	utils/audiostream.o \
	utils/file.o \
	utils/md5.o \
	utils/voc.o \
	utils/wave.o

all: $(TARGETS)

install: $(TARGETS)
	for i in $^ ; do install -p -m 0755 $$i $(DESTDIR) ; done

bundle_name = ScummVM\ Tools\ GUI.app
bundle: $(TARGETS)
	mkdir -p $(bundle_name)
	mkdir -p $(bundle_name)/Contents
	mkdir -p $(bundle_name)/Contents/MacOS
	mkdir -p $(bundle_name)/Contents/Resources
	echo "APPL????" > $(bundle_name)/Contents/PkgInfo
	cp $(srcdir)/dist/macosx/Info.plist $(bundle_name)/Contents/
	cp $(TARGETS) $(bundle_name)/Contents/Resources/
	mv $(bundle_name)/Contents/Resources/tools_gui $(bundle_name)/Contents/MacOS/

#compress_agos$(EXEEXT): compress_agos.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_gob$(EXEEXT): compress_gob.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#compress_kyra$(EXEEXT): compress_kyra.o kyra_pak.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_queen$(EXEEXT): compress_queen.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_saga$(EXEEXT): compress_saga.o compress.o util.o tool.o $(UTILS)
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_scumm_bun$(EXEEXT): compress_scumm_bun.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_scumm_san$(EXEEXT): compress_scumm_san.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lz -lvorbis -logg -lvorbisenc -lFLAC

#compress_scumm_sou$(EXEEXT): compress_scumm_sou.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_sword1$(EXEEXT): compress_sword1.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_sword2$(EXEEXT): compress_sword2.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_tinsel$(EXEEXT): compress_tinsel.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_touche$(EXEEXT): compress_touche.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

#compress_tucker$(EXEEXT): compress_tucker.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lvorbis -logg -lvorbisenc -lFLAC

decine$(EXEEXT): decine.o
	$(CXX) $(LDFLAGS) -o $@ $+

dekyra$(EXEEXT): dekyra.o dekyra_v1.o util.o
	$(CXX) $(LDFLAGS) -o $@ $+

descumm$(EXEEXT): descumm-tool.o descumm.o descumm6.o descumm-common.o util.o tool.o
	$(CXX) $(LDFLAGS) -o $@ $+

desword2$(EXEEXT): desword2.o util.o tool.o
	$(CXX) $(LDFLAGS) -o $@ $+

degob$(EXEEXT): degob.o degob_script.o degob_script_v1.o degob_script_v2.o degob_script_v3.o degob_script_v4.o degob_script_v5.o degob_script_v6.o degob_script_bargon.o util.o tool.o
	$(CXX) $(LDFLAGS) -o $@ $+

#encode_dxa$(EXEEXT): encode_dxa.o compress.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+ -lpng -lz -lvorbis -logg -lvorbisenc -lFLAC

#extract_cine$(EXEEXT): extract_cine.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_agos$(EXEEXT): extract_agos.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_gob_stk$(EXEEXT): extract_gob_stk.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_kyra$(EXEEXT): extract_kyra.o kyra_pak.o kyra_ins.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_loom_tg16$(EXEEXT): extract_loom_tg16.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_mm_apple$(EXEEXT): extract_mm_apple.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_mm_c64$(EXEEXT): extract_mm_c64.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_mm_nes$(EXEEXT): extract_mm_nes.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_parallaction$(EXEEXT): extract_parallaction.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_scumm_mac$(EXEEXT): extract_scumm_mac.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_t7g_mac$(EXEEXT): extract_t7g_mac.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

#extract_zak_c64$(EXEEXT): extract_zak_c64.o util.o tool.o
#	$(CXX) $(LDFLAGS) -o $@ $+

tools_gui$(EXEEXT): gui/main.o gui/pages.o gui/gui_tools.o compress_agos.o compress_gob.o compress_kyra.o \
	compress_queen.o compress_saga.o compress_scumm_bun.o compress_scumm_san.o compress_scumm_sou.o \
	compress_sword1.o compress_sword2.o compress_touche.o compress_tucker.o compress_tinsel.o \
	extract_agos.o extract_gob_stk.o extract_kyra.o extract_loom_tg16.o extract_mm_apple.o \
	extract_mm_c64.o extract_mm_nes.o extract_parallaction.o extract_scumm_mac.o encode_dxa.o \
	extract_zak_c64.o kyra_pak.o kyra_ins.o compress.o util.o tool.o tools.o $(UTILS)
	$(CXX) $(LDFLAGS) -o $@ $+ `wx-config --libs` -lpng -lz -lvorbis -logg -lvorbisenc -lFLAC

tools_cli$(EXEEXT): main_cli.o tools_cli.o compress_agos.o compress_gob.o compress_kyra.o \
	compress_queen.o compress_saga.o compress_scumm_bun.o compress_scumm_san.o compress_scumm_sou.o \
	compress_sword1.o compress_sword2.o compress_touche.o compress_tucker.o compress_tinsel.o \
	extract_agos.o extract_gob_stk.o extract_kyra.o extract_loom_tg16.o extract_mm_apple.o \
	extract_mm_c64.o extract_mm_nes.o extract_parallaction.o extract_scumm_mac.o encode_dxa.o \
	extract_zak_c64.o kyra_pak.o kyra_ins.o compress.o util.o tool.o tools.o $(UTILS)
	$(CXX) $(LDFLAGS) -o $@ $+ -lpng -lz -lvorbis -logg -lvorbisenc -lFLAC

sword2_clue$(EXEEXT): sword2_clue.o util.o
	$(CXX) $(LDFLAGS) -o $@ $+ `pkg-config --libs gtk+-2.0`

gui/main.o: gui/main.cpp gui/main.h gui/configuration.h gui/pages.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) `wx-config --cxxflags` -c gui/main.cpp -o gui/main.o

gui/pages.o: gui/pages.cpp gui/pages.h gui/main.h gui/gui_tools.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) `wx-config --cxxflags` -c gui/pages.cpp -o gui/pages.o

gui/gui_tools.o: gui/gui_tools.cpp gui/gui_tools.h
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) `wx-config --cxxflags` -c gui/gui_tools.cpp -o gui/gui_tools.o

sword2_clue.o: sword2_clue.cpp
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) `pkg-config --cflags gtk+-2.0` -c sword2_clue.cpp

clean:
	rm -f *.o utils/*.o $(TARGETS)

######################################################################
# The build rules follow - normally you should have no need to
# touch whatever comes after here.
######################################################################

# Concat DEFINES and INCLUDES to form the CPPFLAGS
CPPFLAGS := $(DEFINES) $(INCLUDES)

# Include the build instructions for all modules
#-include $(addprefix $(srcdir)/, $(addsuffix /module.mk,$(MODULES)))

# Depdir information
DEPDIRS = $(addsuffix $(DEPDIR),$(MODULE_DIRS))
DEPFILES =

%.o: %.cpp
	$(MKDIR) $(*D)/$(DEPDIR)
	$(CXX) $(NO_MAIN) -Wp,-MMD,"$(*D)/$(DEPDIR)/$(*F).d",-MQ,"$@",-MP $(CXXFLAGS) $(CPPFLAGS) -c $(<) -o $*.o

# Include the dependency tracking files.
-include $(wildcard $(addsuffix /*.d,$(DEPDIRS)))
