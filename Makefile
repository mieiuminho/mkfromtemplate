CC      = gcc
LD      = gcc
CFLAGS  = -O2 -Wall -Wextra
CFLAGS += -Wno-unused-parameter -Wno-unused-function -Wno-unused-result
LIBS    = `pkg-config --cflags --libs glib-2.0` -lfl
INCLDS  = -I $(INC_DIR)
BIN_DIR = bin
BLD_DIR = build
DOC_DIR = docs
TPL_DIR = templates
INC_DIR = includes
LOG_DIR = log
OUT_DIR = out
SRC_DIR = src
TST_DIR = tests
SRC     = $(wildcard $(SRC_DIR)/*.c)
LEX     = $(wildcard $(SRC_DIR)/*.l)
CLEX    = $(patsubst $(SRC_DIR)/%.l,$(OUT_DIR)/%.c,$(LEX))
OBJS    = $(patsubst $(SRC_DIR)/%.c,$(BLD_DIR)/%.o,$(SRC))
OBJS   += $(patsubst $(OUT_DIR)/%.c,$(BLD_DIR)/%.o,$(wildcard $(OUT_DIR)/*.c))
DEPS    = $(patsubst $(BLD_DIR)/%.o,$(BLD_DIR)/%.d,$(OBJS))
DEPS   += $(patsubst $(BLD_DIR)/%.o,$(BLD_DIR)/%.d,$(OBJS))
PROGRAM = mkfromtemplate

vpath %.c $(SRC_DIR) $(OUT_DIR)

.DEFAULT_GOAL = build

.PHONY: build setup clean debug doc fmt run test

$(OUT_DIR)/%.c: $(SRC_DIR)/%.l
	flex -o $@ $<

$(BLD_DIR)/%.d: %.c
	$(CC) -M $(INCLDS) $(CFLAGS) $(LIBS) $< -o $@

$(BLD_DIR)/%.o: %.c
	$(CC) -c $(INCLDS) $(CFLAGS) $(LIBS) $< -o $@

$(BIN_DIR)/$(PROGRAM): $(CLEX) $(DEPS) $(OBJS)
	$(CC) $(INCLDS) $(LIBS) $(OBJS) -o $@

build: setup $(BIN_DIR)/$(PROGRAM)

run: build
	@./$(BIN_DIR)/$(PROGRAM)

fmt:
	@echo "C and Headers files:"
	@-clang-format -style="{BasedOnStyle: Google, IndentWidth: 4}" -verbose -i \
		$(SRC_DIR)/*.c $(INC_DIR)/*.h
	@echo ""
	@echo "Shell files:"
	@shfmt -l -w -i 2 .

debug: CFLAGS = -Wall -Wextra -ansi -pedantic -O0 -g
debug: build
	gdb ./$(BIN_DIR)/$(PROGRAM)

doc:
	@doxygen $(DOC_DIR)/Doxyfile

test: build
	@./$(TST_DIR)/test_template.sh -o $(OUT_DIR) -t $(TPL_DIR)/flex.tmpl -n flexample

setup:
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(BLD_DIR)
	@mkdir -p $(DOC_DIR)
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning..."
	@echo ""
	@cat .art/maid.ascii
	@-rm -rf $(BLD_DIR)/* $(BIN_DIR)/* $(OUT_DIR)/* $(LOG_DIR)/* \
		$(DOC_DIR)/html $(DOC_DIR)/latex
	@echo ""
	@echo "...✓ done!"

