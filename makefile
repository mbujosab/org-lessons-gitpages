LECCIONES_SRC = ./org-lessons
LECCIONES_tmp = ./lecciones
DOCS = ./docs
CUADERNOS = $(DOCS)/CuadernosElectronicos
TRANSPARENCIAS = $(DOCS)/Transparencias

SRC_FILES = $(LECCIONES_SRC)/Lecc*.org

.PHONY: all clean cleanAll directorios series_formales calendario notebooksYslides

all: calendario notebooksYslides publicacion

calendario: $(DOCS)/Calendario-Econometria-Aplicada.pdf

$(DOCS)/Calendario-Econometria-Aplicada.pdf:
	emacs --batch Calendario/README.org -l org -f org-babel-tangle
	cd Calendario && make Calendario-Econometria-Aplicada.pdf

publicacion: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES))) README.org index.org
	echo "FICHEROS EN CuadernosElectronicos y Transparencias?..."
	cp -a $(LECCIONES_tmp)/Lecc*.slides.html $(TRANSPARENCIAS)
	ls $(CUADERNOS)
	ls $(TRANSPARENCIAS)
	cp -a org-practicas $(LECCIONES_tmp)/practicas
	echo "EJECUCIÓN DE publica.el..."
	emacs --batch \
	  --load ~/Software/scimax/init.el \
	  -l publica.el
	#ln -snf -r $(DOCS)/img/ $(DOCS)/org-lessons/img/
	echo "FICHEROS EN Docs?..."
	ls $(DOCS)
	ls $(DOCS)/pdfs
	touch $@

notebooksYslides: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES)))
	touch $@

$(CUADERNOS)/%.ipynb $(TRANSPARENCIAS)/%.slides.html: $(LECCIONES_SRC)/%.org
	make directorios
	make series_formales
	cp -a $(LECCIONES_SRC)/*.bib $(LECCIONES_tmp)
	cp -a $< $(LECCIONES_tmp)
	echo "EJECUCION DEL NOTEBOOK DE ORG: $(LECCIONES_tmp)/$(@F:.ipynb=.org)..."
	emacs -Q -l ~/Software/scimax/init.el $(LECCIONES_tmp)/$(@F:.ipynb=.org) --batch --eval "(org-babel-execute-buffer)" --eval "(save-buffer)" --kill
	echo "FICHEROS EN ./lecciones?..."
	ls $(LECCIONES_tmp)
	echo "FICHEROS IMG?..."
	ls $(LECCIONES_tmp)/img
	echo "FICHEROS EN ./docs/imgs?..."
	cp -a $(LECCIONES_tmp)/img $(DOCS)/
	ls $(DOCS)/img
	ls $(DOCS)/img/lecc01
	echo "Contenido de img tras notebook:"
	find $(LECCIONES_tmp)/img
	echo "COPIO LO QUE SE HA GENERADO (.ipynb sin ejecutar y las imágenes) A ./docs..."
	cp -a $(LECCIONES_tmp)/$(@F) $(CUADERNOS)
	cp -a $(LECCIONES_tmp)/img $(DOCS)/
#	cp -a $(LECCIONES_tmp)/$(@F:.ipynb=.org) $(DOCS)/
	ln -snf -r $(DOCS)/img/ $(TRANSPARENCIAS)/
	ln -snf -r $(DOCS)/img/ $(CUADERNOS)/
	ln -snf -r ./datos/ $(DOCS)
#	# Ejecutar el notebook con jupyter nbconvert
	echo "EJECUCION DEL NOTEBOOK DE JUPYTER..."
	jupyter nbconvert --execute --inplace $(LECCIONES_tmp)/$(@F) 
	echo "CREACIÓN DE LAS SLIDES..."
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES_tmp)/$(@F) 
	echo "FICHEROS EN Docs ANTES DE PUBLICAR?..."
	ls $(DOCS)

series_formales: $(LECCIONES_tmp)/src/implementacion_series_formales.org

$(LECCIONES_tmp)/src/implementacion_series_formales.org: $(LECCIONES_SRC)/src/implementacion_series_formales.org
	echo "INICIO IMPLEMENTACION_SERIES_FORMALES.ipynb..."
	make directorios
	cp $< $(LECCIONES_tmp)/src/
	emacs -q --batch $(LECCIONES_tmp)/src/implementacion_series_formales.org -l org -f org-babel-tangle
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.py $(CUADERNOS)/src/
	ln -sf -r $(CUADERNOS)/src/implementacion_series_formales.py $(CUADERNOS)/
	emacs -q --batch \
	  --load ~/Software/scimax/init.el \
          --load ~/Software/scimax/local-init.el \
	  --eval "(require 'ox-ipynb)" \
	  --eval "(ox-ipynb-export-org-file-to-ipynb-file \"lecciones/src/implementacion_series_formales.org\")"
	jupyter nbconvert --execute --inplace $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --execute --to html $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb $(CUADERNOS)
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.slides.html $(TRANSPARENCIAS)
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.html $(DOCS)
	echo "TERMINADO IMPLEMENTACION_SERIES_FORMALES.ipynb..."

directorios:
	mkdir -v -p $(LECCIONES_tmp)/src
	mkdir -v -p $(LECCIONES_tmp)/img
	ln -snf -r ./css/ $(LECCIONES_tmp)/
	mkdir -v -p $(DOCS)/img
	mkdir -v -p $(DOCS)/pdfs
	mkdir -v -p $(TRANSPARENCIAS)
	mkdir -v -p $(CUADERNOS)/src
	touch directorios

clean:
	rm -r -f $(LECCIONES_tmp)

cleanAll: clean
	find $(DOCS)/ -mindepth 1 ! -name 'README.org' -exec rm -rf {} +
	rm -f directorios
	rm -f series_formales
	rm -f publicacion
	rm -r -f logs
