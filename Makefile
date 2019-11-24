# (GNU) Makefile for a simple Hello World program
# from "Neo-Geo Assembly Programming for the Absolute Beginner" by freem
# http://ajworld.net/neogeodev/beginner/
################################################################################
# tool binaries #
#################
# CP - copy tool
CP=cp

# TOOL_VASM68K - filename and/or path to vasm (m68k with mot syntax)
TOOL_VASM68K = tools/vasmm68k_mot_win32.exe

# TOOL_VASMZ80 - filename and/or path to vasm (z80 with oldstyle syntax)
TOOL_VASMZ80 = tools/vasmz80_oldstyle_win32.exe

# TOOL_MKISOFS - filename and/or path to mkisofs
TOOL_MKISOFS = tools/mkisofs.exe

# TOOL_ROMWAK - filename and/or path to romwak
TOOL_ROMWAK = tools/romwak_x86.exe

################################################################################
# input paths and filenames #
#############################

# SOURCE_68K, SOURCE_Z80 - base paths for source code directories
SOURCE_68K = src_68k
SOURCE_Z80 = src_z80

# INPUT_68K - filename of main 68K code file
INPUT_68K = $(SOURCE_68K)/main.asm

# INPUT_Z80 - filename of main Z80 code file
INPUT_Z80 = $(SOURCE_Z80)/simple.asm

# INPUT_FIX - filename of Fix layer tile data file
INPUT_FIX = hello.fix

# INPUT_SPR - filename of Sprite tile data file (4BPP SMS/GG/WSC format)
INPUT_SPR = spr/out.spr

################################################################################
# output paths and filenames #
##############################

# OUTPUT_CART, OUTPUT_CD - base output paths for cart and CD targets
OUTPUT_CD   = _cd
OUTPUT_PRG_CD=$(OUTPUT_CD)/HELLO.PRG
OUTPUT_FIX_CD=$(OUTPUT_CD)/HELLO.FIX
OUTPUT_Z80_CD=$(OUTPUT_CD)/HELLO.Z80
OUTPUT_SPR_CD=$(OUTPUT_CD)/OUT.SPR
OUTPUT_PCM_CD=$(OUTPUT_CD)/HELLO.PCM

################################################################################
# CD layout and output #
########################
# FLAGS_MKISOFS - Flags for mkisofs
# Mode 1 ISO (-iso-level 1); pad to multiple of 32K (-pad); Omit version number (-N)
FLAGS_MKISOFS=-iso-level 1 -pad -N

# NGCD_IMAGENAME - output image/ISO name
NGCD_IMAGENAME=out

# NGCD_DISCLABEL - Disc label (8 characters maximum)
NGCD_DISCLABEL=OUT

# CDFILES - the list of files to include on the CD (used with mkisofs)
CDFILES = \
	$(OUTPUT_CD)/ABS.TXT \
	$(OUTPUT_CD)/BIB.TXT \
	$(OUTPUT_CD)/CPY.TXT \
	$(OUTPUT_CD)/IPL.TXT \
	$(OUTPUT_FIX_CD) \
	$(OUTPUT_PCM_CD) \
	$(OUTPUT_PRG_CD) \
	$(OUTPUT_SPR_CD) \
	$(OUTPUT_Z80_CD)

# OUTPUT_CDIMAGE - output path for .iso image
OUTPUT_CDIMAGE=$(NGCD_IMAGENAME).iso

################################################################################
# targets #
###########

FLAGS_TARGET_CD   = TARGET_CD

#==============================================================================#
# cd - .iso file (for Neo-Geo CD)

cd: cdfix cdprg cdz80 cdspr
	$(TOOL_MKISOFS) $(FLAGS_MKISOFS) -o $(OUTPUT_CDIMAGE) -V "$(NGCD_DISCLABEL)" $(CDFILES)

#==============================================================================#
# Shared flags for vasm 68K
#==============================================================================#
# FLAGS_VASM68K - Shared flags for vasm 68K
# -m68000 : compile for Motorola 68000 (and not anything higher)
# -devpac : devpac compatibility mode (used to disable optimizations)
# -Fbin   : set output format to binary
FLAGS_VASM68K = -m68000 -devpac -Fbin -L out.lst

#==============================================================================#
# cdprg - cd program file

cdprg:
	$(TOOL_VASM68K) $(FLAGS_VASM68K) -D$(FLAGS_TARGET_CD) -o $(OUTPUT_PRG_CD) $(INPUT_68K)

#==============================================================================#
# Shared flags for vasm z80
#==============================================================================#
# FLAGS_VASMZ80 - Shared flags for vasm Z80
# -Fbin   : set output format to binary
# -nosym  : don't include symbols in output
FLAGS_VASMZ80 = -Fbin -nosym


#==============================================================================#
# cdz80 - cd .z80 file

cdz80:
	$(TOOL_VASMZ80) $(FLAGS_VASMZ80) -D$(FLAGS_TARGET_CD) -o $(OUTPUT_Z80_CD) $(INPUT_Z80)


#==============================================================================#
# cdfix - cd fix layer data

cdfix:
	$(CP) $(INPUT_FIX) $(OUTPUT_FIX_CD)

#==============================================================================#
# cdspr - cd sprite data

cdspr:
	$(CP) $(INPUT_SPR) $(OUTPUT_SPR_CD)
