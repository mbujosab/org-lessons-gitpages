(require 'ox-publish)

(let* ((base-directory "./lecciones/")
       (public-directory "./docs/")
       (org-export-with-broken-links t)
       (org-publish-project-alist `(("html"
				     :base-directory ,base-directory
				     :base-extension "org"
                                     :publishing-directory ,public-directory
				     :exclude "EjerciciosHide\\|SeriesSimuladas4\\|SeriesSimuladas12\\|Calendario\\|ucarima.*\\|.ipynb_checkpoints\\|00Notas.*\\|org-publisg.*\\|kk.*"
				     :recursive t
				     :publishing-function org-html-publish-to-html
				     :auto-preamble t
				     :auto-sitemap nil)
				    ("pdf"
				     :base-directory ,base-directory
				     :base-extension "org"
				     :publishing-directory , (concat public-directory "pdfs")
				     :exclude "Calendario"
				     :exclude ".ipynb_checkpoints"
				     :recursive t
				     :publishing-function org-latex-publish-to-pdf
				     :auto-preamble t
				     :auto-sitemap nil)
				    
				    ("static-html"
				     :base-directory ,base-directory
				     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|txt\\|svg\\|aiff\\|csv\\|gdt\\|inp\\|ipynb"
				     :publishing-directory ,public-directory
				     :exclude "docs"
				     :exclude "Calendario"
				     :exclude ".ipynb_checkpoints"
				     :recursive t
				     :publishing-function org-publish-attachment)

				    ;; ... all the components ...
				    ("scimax-eln" :components ("html" "static-html" "pdf")))))

  (org-publish "scimax-eln" t))
