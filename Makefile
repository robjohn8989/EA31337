MQL=mql.exe
SRC=$(wildcard src/*.mq4)
EA="EA31337"
EX4="src/$(EA).ex4"
EX5="src/$(EA).ex5"
VER=$(shell grep 'define ea_version' src/include/EA/ea-properties.mqh | grep -o '[0-9].*[0-9]')
FILE=$(lastword $(MAKEFILE_LIST)) # Determine this makefile's path.
OUT="releases"
MKFILE=$(abspath $(lastword $(MAKEFILE_LIST)))
CWD=$(notdir $(patsubst %/,%,$(dir $(MKFILE))))
all: requirements $(MQL) mql4

requirements:
	type -a git
	type -a ex
	type -a wine

mql4: requirements $(MQL) src/%.ex4
mql5: requirements $(MQL) src/%.ex5

test: requirements set-mode $(MQL)
	wine mql.exe /s /i:src /mql4 $(SRC)
	wine mql.exe /s /i:src /mql5 $(SRC)

src/%.ex4: set-mode $(SRC)
	wine mql.exe /o /i:src /mql4 $(SRC)

src/%.ex5: set-mode $(SRC)
	wine mql.exe /o /i:src /mql5 $(SRC)

mql.exe:
	curl -O http://files.metaquotes.net/metaquotes.software.corp/mt5/mql.exe

set-mode:
# E.g.: make set-mode MODE="__advanced__"
ifdef MODE
	git checkout -- src/include/EA/ea-mode.mqh
	ex -s +"%s@^\zs.*\ze#define \($(MODE)\)@@g" -cwq src/include/EA/ea-mode.mqh
endif

set-none:
	git checkout -- src/include/EA/ea-mode.mqh

set-lite:
	@$(MAKE) -f $(FILE) set-mode MODE="__release__\|__backtest__"

set-advanced:
	@$(MAKE) -f $(FILE) set-mode MODE="__release__\|__backtest__\|__advanced__"

set-rider:
	@$(MAKE) -f $(FILE) set-mode MODE="__release__\|__backtest__\|__rider__"

clean:
	find . '(' -name '*.ex4' -or -name '*.ex5' ')' -delete

release: mql.exe \
		clean \
		$(OUT)/$(EA)-Backtest-Lite-%.ex4 \
		$(OUT)/$(EA)-Backtest-Advanced-%.ex4 \
		$(OUT)/$(EA)-Backtest-Rider-%.ex4
		git --git-dir=$(OUT)/.git add -v -A
		$(eval GIT_EXTRAS := $(shell git --git-dir=$(OUT)/.git tag "v$(VER)" || echo "--amend"))
		@echo $(GIT_EXTRAS)
		git --git-dir=$(OUT)/.git commit -v -m "$(EA) v${VER} released." -a $(GIT_EXTRAS)
		git --git-dir=$(OUT)/.git tag -f "v$(VER)"
		eval $(shell cd $(OUT) && sha1sum *.* > .files.crc)
		@$(MAKE) -f $(FILE) set-none
		@echo "$(EA) v${VER} released."

$(OUT)/$(EA)-Backtest-Lite-%.ex4: set-lite
	wine mql.exe /o /i:src /mql4 $(SRC) && cp -v "$(EX4)" "$(OUT)/$(EA)-Backtest-Lite-v$(VER).ex4"

$(OUT)/$(EA)-Backtest-Advanced-%.ex4: set-advanced
	wine mql.exe /o /i:src /mql4 $(SRC) && cp -v "$(EX4)" "$(OUT)/$(EA)-Backtest-Advanced-v$(VER).ex4"

$(OUT)/$(EA)-Backtest-Rider-%.ex4: set-rider
	wine mql.exe /o /i:src /mql4 $(SRC) && cp -v "$(EX4)" "$(OUT)/$(EA)-Backtest-Rider-v$(VER).ex4"
