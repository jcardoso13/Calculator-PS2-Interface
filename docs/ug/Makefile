OBJS = $(patsubst %.odg,%.pdf,$(wildcard ./figures/*.odg))
WAVES = $(wildcard ./wavedrom/*.png)

TRGT = ug
SRC = intro.tex bd.tex isa.tex mem_map.tex is.tex progex.tex periphs.tex


$(TRGT).pdf: $(TRGT).tex $(OBJS) $(SRC) $(WAVES) $(TRGT).cls
	latexmk -pdf $(TRGT).tex


./figures/%.pdf: ./figures/%.odg
	make -C ./figures

clean:
	@rm -f $(addprefix ug, .lof .toc .aux .out .lot .log .bbl .blg .fls .fdb_latexmk) EPSLogo-eps-converted-to.pdf *~
	make -C ./figures clean

.PHONY: clean all

