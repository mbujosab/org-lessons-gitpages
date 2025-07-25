LECCIONES_SRC = ./org-lessons
LECCIONES = ./lecciones
DOCS = ./docs
CUADERNOS = $(DOCS)/CuadernosElectronicos
TRANSPARENCIAS = $(DOCS)/Transparencias

SRC_FILES = $(LECCIONES_SRC)/Lecc*.org

.PHONY: all clean cleanAll directorios series_formales calendario notebooksYslides

all: notebooksYslides calendario
	emacs --batch \
	  --load ~/.emacs.d/no-tlmgr.el \
	  --load ~/Software/scimax/init.el \
	  -l publica.el

calendario: $(DOCS)/Calendario-Econometria-Aplicada.pdf

$(DOCS)/Calendario-Econometria-Aplicada.pdf:
	emacs --batch Calendario/README.org -l org -f org-babel-tangle
	cd Calendario && make Calendario-Econometria-Aplicada.pdf

notebooksYslides: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES)))

$(CUADERNOS)/%.ipynb $(TRANSPARENCIAS)/%.slides.html: $(LECCIONES_SRC)/%.org
	make directorios
	make series_formales
	cp -a $(LECCIONES_SRC)/*.bib $(LECCIONES)
	cp -a $< $(LECCIONES)
	emacs --batch \
	  --load ~/.emacs.d/no-tlmgr.el \
	  --load ~/Software/scimax/init.el \
	  --eval "(require 'ox-ipynb)" \
	  $(LECCIONES)/$(@F:.ipynb=.org) \
	  -f org-babel-execute-buffer --kill
	mv $(LECCIONES)/$(@F:.ipynb=.ipynb) $(CUADERNOS)
	mv $(LECCIONES)/$(@F:.ipynb=.slides.html) $(TRANSPARENCIAS)

#	#emacs -q -l ~/Software/scimax/init.el $(LECCIONES)/$(@F:.ipynb=.org) --batch -f org-babel-execute-buffer --kill

series_formales: $(LECCIONES_SRC)/src/implementacion_series_formales.org
	make directorios
	cp $< $(LECCIONES)/src/
	emacs --batch $(LECCIONES)/src/implementacion_series_formales.org -l org -f org-babel-tangle
	#ln -s -r $(LECCIONES)/src/implementacion_series_formales.py $(LECCIONES)/
	cp -a $(LECCIONES)/src/implementacion_series_formales.py $(CUADERNOS)/src/
	#ln -s -r $(CUADERNOS)/src/implementacion_series_formales.py $(CUADERNOS)/
	emacs --batch \
	  --load ~/.emacs.d/no-tlmgr.el \
	  --load ~/Software/scimax/init.el \
	  --eval "(require 'ox-ipynb)" \
	  --eval "(ox-ipynb-export-org-file-to-ipynb-file \"lecciones/src/implementacion_series_formales.org\")"
	jupyter nbconvert --execute --inplace $(LECCIONES)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --execute --to html $(LECCIONES)/src/implementacion_series_formales.ipynb
	mv $(LECCIONES)/src/implementacion_series_formales.ipynb $(CUADERNOS)
	mv $(LECCIONES)/src/implementacion_series_formales.slides.html $(TRANSPARENCIAS)
	mv $(LECCIONES)/src/implementacion_series_formales.html $(DOCS)
	touch $@

directorios:
	mkdir -v -p $(LECCIONES)/src
	mkdir -v -p $(LECCIONES)/img
	mkdir -v -p $(DOCS)/img
	mkdir -v -p $(DOCS)/pdfs
	mkdir -v -p $(TRANSPARENCIAS)
	mkdir -v -p $(CUADERNOS)/src
	ln -s -r $(DOCS)/img/ $(TRANSPARENCIAS)/ || true
	ln -s -r $(DOCS)/img/ $(CUADERNOS)/ || true
	touch directorios

clean:
	rm -r -f $(LECCIONES)

cleanAll: clean
	find $(DOCS)/ -mindepth 1 ! -name 'README.org' -exec rm -rf {} +
	rm -f directorios
	rm -f series_formales
