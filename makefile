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

publicacion: notebooksYslides
	echo "Verificación del log de emacs..."
	emacs -q -l ~/Software/scimax/init.el ./lecciones/Lecc01.org --batch -f org-babel-execute-buffer --kill > emacs_build.log 2>&1
	cat emacs_build.log
	cp ./lecciones/Lecc01.org ./docs/
	echo "FICHEROS EN CuadernosElectronicos y Transparencias?..."
	mv $(LECCIONES_tmp)/Lecc*.slides.html $(TRANSPARENCIAS)
	ls $(CUADERNOS)
	ls $(TRANSPARENCIAS)
	echo "EJECUCIÓN DE publica.el..."
	emacs --batch \
	  --load ~/.emacs.d/no-tlmgr.el \
	  --load ~/Software/scimax/init.el \
	  -l publica.el
	echo "FICHEROS EN Docs?..."
	ls $(DOCS)
	ls $(DOCS)/pdfs

notebooksYslides: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES)))
	touch $@

$(CUADERNOS)/%.ipynb $(TRANSPARENCIAS)/%.slides.html: $(LECCIONES_SRC)/%.org
	make directorios
	make series_formales
	cp -a $(LECCIONES_SRC)/*.bib $(LECCIONES_tmp)
	cp -a $< $(LECCIONES_tmp)
	echo "EJECUCION DEL NOTEBOOK DE ORG: $(LECCIONES_tmp)/$(@F:.ipynb=.org)..."
	emacs -q -l ~/Software/scimax/init.el $(LECCIONES_tmp)/$(@F:.ipynb=.org) --batch -f org-babel-execute-buffer --kill
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
	echo "COPIO LO QUE SE HA GENERADO (.ipynb sin ejecutar y las imágenes) A /docs..."
	cp -a $(LECCIONES_tmp)/$(@F) $(CUADERNOS)
	cp -a $(LECCIONES_tmp)/img $(DOCS)/
	ln -snf -r $(DOCS)/img/ $(TRANSPARENCIAS)/
	ln -snf -r $(DOCS)/img/ $(CUADERNOS)/
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
	  --load ~/.emacs.d/no-tlmgr.el \
	  --load ~/Software/scimax/init.el \
	  --eval "(require 'ox-ipynb)" \
	  --eval "(ox-ipynb-export-org-file-to-ipynb-file \"lecciones/src/implementacion_series_formales.org\")"
	jupyter nbconvert --execute --inplace $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --execute --to html $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	mv $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb $(CUADERNOS)
	mv $(LECCIONES_tmp)/src/implementacion_series_formales.slides.html $(TRANSPARENCIAS)
	mv $(LECCIONES_tmp)/src/implementacion_series_formales.html $(DOCS)
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
