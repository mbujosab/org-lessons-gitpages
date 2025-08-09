LECCIONES_SRC = ./org-lessons
LECCIONES_tmp = ./Lecciones
DOCS = ./docs
CUADERNOS = $(DOCS)/CuadernosElectronicos
TRANSPARENCIAS = $(DOCS)/Transparencias

SRC_FILES = $(LECCIONES_SRC)/Lecc*.org

.PHONY: all clean cleanAll directorios series_formales calendario notebooksYslides

all: calendario notebooksYslides practicas publicacion

calendario: $(DOCS)/Calendario-Econometria-Aplicada.pdf

$(DOCS)/Calendario-Econometria-Aplicada.pdf:
	emacs --batch Calendario/README.org -l org -f org-babel-tangle
	cd Calendario && make Calendario-Econometria-Aplicada.pdf

publicacion: $(patsubst $(LECCIONES_SRC)/%.org,$(CUADERNOS)/%.ipynb,$(wildcard $(SRC_FILES))) README.org index.org
	echo "FICHEROS EN CuadernosElectronicos y Transparencias?..."
	cp -a $(LECCIONES_tmp)/Lecc*.slides.html $(TRANSPARENCIAS)
	ls $(CUADERNOS)
	ls $(TRANSPARENCIAS)
	echo "EJECUCIÓN DE publica.el..."
	emacs --batch \
	  --load ~/Software/scimax/init.el \
	  -l publica.el
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
	find $(LECCIONES_tmp)
	echo "FICHEROS EN ./docs/Lecciones/img?..."
	cp -a $(LECCIONES_tmp)/img $(DOCS)/Lecciones
	find $(DOCS)/Lecciones/img
	find $(DOCS)/Lecciones/img/lecc01
	echo "Contenido de img tras notebook:"
	find $(LECCIONES_tmp)/img
	echo "COPIO LO QUE SE HA GENERADO (.ipynb sin ejecutar y las imágenes) A ./docs..."
	cp -a $(LECCIONES_tmp)/$(@F) $(CUADERNOS)
	ln -snf -r $(DOCS)/Lecciones/img/ $(TRANSPARENCIAS)/
	ln -snf -r $(DOCS)/Lecciones/img/ $(CUADERNOS)/
	ln -snf -r ./datos/ $(DOCS)
#	# Ejecutar el notebook con jupyter nbconvert
	echo "EJECUCION DEL NOTEBOOK DE JUPYTER..."
	jupyter nbconvert --execute --inplace $(LECCIONES_tmp)/$(@F) 
	echo "CREACIÓN DE LAS SLIDES..."
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES_tmp)/$(@F) 
	echo "➡️ FICHEROS EN docs/ TRAS GENERAR SLIDES Y NOTEBOOKS DE JUPYTER..."
	find $(DOCS)


# Lista de archivos fuente .org en org-practicas
PRACTICAS_SRC = $(wildcard org-practicas/*.org)

# Ficheros .done como señal de que fueron tanglados
PRACTICAS_DONE = $(patsubst org-practicas/%.org, $(LECCIONES_tmp)/Practicas/%.done, $(PRACTICAS_SRC))

# Objetivo principal
practicas: $(PRACTICAS_DONE)
	@echo "✅ Todas las prácticas actualizadas."

$(LECCIONES_tmp)/Practicas/%.done: org-practicas/%.org
	echo "➡️ Copiando y ejecutando $< ..."
	mkdir -p $(LECCIONES_tmp)/Practicas/guiones
	cp $< $(LECCIONES_tmp)/Practicas/
	cp -a org-practicas/hansl.tex $(LECCIONES_tmp)/Practicas/
	cp -a ./datos $(LECCIONES_tmp)/Practicas
	echo "🧠 Ejecutando org-babel-tangle y eval..."
	set -e; \
	if emacs --batch \
	  --load ~/Software/scimax/init.el \
	  $(LECCIONES_tmp)/Practicas/$*.org \
	  --eval "(org-babel-execute-buffer)" \
	  --eval "(save-buffer)" \
	  --kill; then \
	    echo "✅ Correcto: $<"; \
	    touch $@; \
	else \
	    echo "❌ Error al procesar $<"; \
	    rm -f $@; \
	    exit 1; \
	fi
	echo "➡️ listado de ficheros en el subdirectorio guiones"
	ls -lR $(LECCIONES_tmp)/Practicas/guiones  # Debug para Actions

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
	  --eval "(require 'ox-ipynb)" \
	  --eval "(ox-ipynb-export-org-file-to-ipynb-file \"Lecciones/src/implementacion_series_formales.org\")"
	jupyter nbconvert --execute --inplace $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --config mycfg-GitHubPages.py --to slides --reveal-prefix "https://unpkg.com/reveal.js@5.2.1" --execute $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	jupyter nbconvert --execute --to html $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.ipynb $(CUADERNOS)
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.slides.html $(TRANSPARENCIAS)
	cp -a $(LECCIONES_tmp)/src/implementacion_series_formales.html $(DOCS)/Lecciones/src/
	echo "TERMINADO IMPLEMENTACION_SERIES_FORMALES.ipynb..."

directorios:
	mkdir -v -p $(LECCIONES_tmp)/src
	mkdir -v -p $(LECCIONES_tmp)/img
	ln -snf -r ./css/ $(LECCIONES_tmp)/
	mkdir -v -p $(DOCS)/pdfs
	mkdir -v -p $(DOCS)/Lecciones/img
	mkdir -v -p $(DOCS)/Lecciones/src
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
	rm -f practicas
	rm -r -f logs
