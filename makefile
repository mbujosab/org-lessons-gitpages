LECCIONES_SRC = ./org-lessons
LECCIONES = ./lecciones
DOCS = ./docs
CUADERNOS = $(DOCS)/CuadernosElectronicos
TRANSPARENCIAS = $(DOCS)/Transparencias

SRC_FILES = $(LECCIONES_SRC)/Lecc*.org

.PHONY: all clean cleanAll directorios series_formales calendario notebooksYslides

all: notebooksYslides calendario

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
	  -l publica.el
#	# Exportar el archivo .org a .ipynb
#	emacs --batch \
#	  --load ~/.emacs.d/no-tlmgr.el \
#	  --load ~/Software/scimax/init.el \
#	  --eval "(require 'ox-ipynb)" \
#	  $(LECCIONES)/$(@F:.ipynb=.org)
#	# Ejecutar el notebook con jupyter nbconvert
	jupyter nbconvert --execute --inplace $(LECCIONES)/$(@F) 
	cp -a $(LECCIONES)/img $(DOCS)/
	ln -snf -r $(DOCS)/img/ $(TRANSPARENCIAS)/
	ln -snf -r $(DOCS)/img/ $(CUADERNOS)/
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES)/$(@F) 
#	jupyter nbconvert --execute --to html $(LECCIONES)/$(@F) 
#	# Mover los archivos generados
	mv $(LECCIONES)/$(@F) $(CUADERNOS)
	mv $(LECCIONES)/$(@F:.ipynb=.slides.html) $(TRANSPARENCIAS)
#	mv $(LECCIONES)/$(@F:.ipynb=.html) $(DOCS)


series_formales: $(LECCIONES_SRC)/src/implementacion_series_formales.org
	make directorios
	cp $< $(LECCIONES)/src/
	emacs -q --batch $(LECCIONES)/src/implementacion_series_formales.org -l org -f org-babel-tangle
	cp -a $(LECCIONES)/src/implementacion_series_formales.py $(CUADERNOS)/src/
	ln -sf -r $(CUADERNOS)/src/implementacion_series_formales.py $(CUADERNOS)/
	emacs -q --batch \
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
	ln -snf -r ./css/ $(LECCIONES)/
	mkdir -v -p $(DOCS)/img
	mkdir -v -p $(DOCS)/pdfs
	mkdir -v -p $(TRANSPARENCIAS)
	mkdir -v -p $(CUADERNOS)/src
	touch directorios

clean:
	rm -r -f $(LECCIONES)

cleanAll: clean
	find $(DOCS)/ -mindepth 1 ! -name 'README.org' -exec rm -rf {} +
	rm -f directorios
	rm -f series_formales
