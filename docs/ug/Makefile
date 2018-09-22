OBJS = $(patsubst %.odg,%.pdf,$(wildcard ./drawings/*.odg))
WAVES = $(wildcard ./wavedrom/*.png)

TRGT = rep
SRC = arch.tex intro.tex control.tex isa.tex mem_map.tex is.tex progex.tex

all: $(TRGT).pdf
	evince $(TRGT).pdf

$(TRGT).pdf: $(TRGT).tex $(OBJS) $(SRC) $(WAVES) $(TRGT).cls
	latexmk -pdf $(TRGT).tex


./drawings/%.pdf: ./drawings/%.odg
	make -C ./drawings

clean:
	@rm -f $(addprefix rep, .lof .toc .aux .out .lot .log .bbl .blg .fls .fdb_latexmk) EPSLogo-eps-converted-to.pdf *~
	make -C ./drawings clean

.PHONY: clean all

