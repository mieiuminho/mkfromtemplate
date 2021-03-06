#==============================================================================
SHELL   = bash
#------------------------------------------------------------------------------
CC      = gcc
LD      = gcc
CFLAGS  = -O2 -Wall -Wextra
CFLAGS += -Wno-unused-parameter -Wno-unused-function -Wno-unused-result
LIBS    = `pkg-config --cflags --libs glib-2.0`
INCLDS  = -I $(INC_DIR)
#------------------------------------------------------------------------------
BIN_DIR = bin
BLD_DIR = build
DOC_DIR = docs
INC_DIR = includes
OUT_DIR = out
SRC_DIR = src
TPL_DIR = templates
TST_DIR = tests
UTI_DIR = scripts
#------------------------------------------------------------------------------
TRASH   = $(BIN_DIR) $(BLD_DIR) $(DOC_DIR)/{html,latex} $(OUT_DIR)
#------------------------------------------------------------------------------
SRC     = $(wildcard $(SRC_DIR)/*.c)
LEX     = $(wildcard $(SRC_DIR)/*.l)
CLEX    = $(patsubst $(SRC_DIR)/%.l,$(OUT_DIR)/%.c,$(LEX))
OBJS    = $(patsubst $(SRC_DIR)/%.c,$(BLD_DIR)/%.o,$(SRC))
OBJS   += $(patsubst $(OUT_DIR)/%.c,$(BLD_DIR)/%.o,$(wildcard $(OUT_DIR)/*.c))
#------------------------------------------------------------------------------
PROGRAM = mkfromtemplate
#==============================================================================

vpath %.c $(SRC_DIR) $(OUT_DIR)

.DEFAULT_GOAL = build

.PHONY: build setup clean debug doc fmt lex bench benchmark test install

define show
	@./$(UTI_DIR)/change_output_color.sh $(1) $(2)
endef

$(OUT_DIR)/%.c: $(SRC_DIR)/%.l
	$(call show,magenta)
	flex -o $@ $<
	$(call show,,reset)

$(BLD_DIR)/%.o: LIBS += -lfl
$(BLD_DIR)/%.o: %.c
	$(call show,blue)
	$(CC) -c $(INCLDS) $(CFLAGS) $(LIBS) $< -o $@
	$(call show,,reset)

$(BIN_DIR)/$(PROGRAM): $(CLEX) $(OBJS)
	$(CC) $(INCLDS) $(LIBS) $(OBJS) -o $@

lex: setup $(CLEX)

build: setup $(BIN_DIR)/$(PROGRAM)

fmt:
	@echo "C and Headers files:"
	@-clang-format -verbose -i $(SRC_DIR)/*.c $(INC_DIR)/*.h
	@echo ""
	@echo "Shell files:"
	@shfmt -l -w -i 2 .

debug: CFLAGS = -Wall -Wextra -ansi -pedantic -O0 -g
debug: build
	gdb ./$(BIN_DIR)/$(PROGRAM)

doc:
	@doxygen $(DOC_DIR)/Doxyfile

test: build
	@./$(TST_DIR)/test_template.sh -o $(OUT_DIR)/nome_da_pasta -t $(TPL_DIR)/flex.tmpl flexample
	@./$(TST_DIR)/test_template.sh -o $(OUT_DIR)/pastas_nodejs -t $(TPL_DIR)/node.tmpl nodexample
	@./$(TST_DIR)/test_template.sh -o $(OUT_DIR)/projeto_em_c -t $(TPL_DIR)/c.tmpl cemple
	@./$(TST_DIR)/test_template.sh -o $(OUT_DIR)/java_is_verbose -t $(TPL_DIR)/java.tmpl javexample

bench: benchmark
benchmark:
	@./$(TST_DIR)/benchmark.sh

install: build
	mkdir -p ~/.config/mkfromtemplate/
	cp -r $(TPL_DIR) ~/.config/mkfromtemplate/
	cp config.ini ~/.config/mkfromtemplate/
	sudo cp $(BIN_DIR)/$(PROGRAM) /usr/bin/
	sudo cp $(UTI_DIR)/mkft /usr/bin/

setup:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(BLD_DIR)
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning..."
	@echo ""
	@cat .art/maid.ascii
	@-rm -rf $(TRASH)
	@echo ""
	@echo "...✓ done!"
