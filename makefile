# Directorios
LECCIONES_SRC = ./org-lessons
LECCIONES = ./lecciones
DOCS = ./docs
CUADERNOS = $(DOCS)/CuadernosElectronicos
TRANSPARENCIAS = $(DOCS)/Transparencias

# Patrón para los archivos fuente
SRC_FILES = $(LECCIONES_SRC)/Lecc*.org

# Regla principal
all: notebooksYslides
	emacs -q -l ~/Software/scimax/init.el -batch -nw -l publica.el

notebooksYslides: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES)))

# Regla para generar notebooks y slides
$(CUADERNOS)/%.ipynb $(TRANSPARENCIAS)/%.slides.html: $(LECCIONES_SRC)/%.org
	make directorios 
	make series_formales
	cp -a $(LECCIONES_SRC)/*.bib $(LECCIONES)
	cp -a $< $(LECCIONES)
	emacs -q -l ~/Software/scimax/init.el $(LECCIONES)/$(@F:.ipynb=.org) --batch -f org-babel-execute-buffer --kill
	mv $(LECCIONES)/$(@F:.ipynb=.ipynb) $(CUADERNOS)
	mv $(LECCIONES)/$(@F:.ipynb=.slides.html) $(TRANSPARENCIAS)

series_formales: $(LECCIONES_SRC)/src/implementacion_series_formales.org
	make directorios 
	cp $< $(LECCIONES)/src/
	emacs --batch $(LECCIONES)/src/implementacion_series_formales.org -l org -f org-babel-tangle
	ln -s -r $(LECCIONES)/src/implementacion_series_formales.py $(LECCIONES)/
	cp -a $(LECCIONES)/src/implementacion_series_formales.py $(CUADERNOS)/src/
	ln -s -r $(CUADERNOS)/src/implementacion_series_formales.py $(CUADERNOS)/
	emacs -q -l ~/Software/scimax/init.el -batch -nw --eval "(require 'ox-ipynb)" --eval "(ox-ipynb-export-org-file-to-ipynb-file \"lecciones/src/implementacion_series_formales.org\")"
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
	ln -s -r $(DOCS)/img/ $(TRANSPARENCIAS)/
	ln -s -r $(DOCS)/img/ $(CUADERNOS)/
	touch directorios

clean:
	rm -r -f $(LECCIONES)

cleanAll: clean
	rm -r -f $(DOCS)
	rm -f directorios
	rm -f series_formales
