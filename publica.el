(require 'ox-publish)

(defun my-org-latex-publish-to-pdf (plist filename pub-dir)
  "Publica un archivo Org como PDF después de ejecutar los bloques de código."
  (with-current-buffer (find-file-noselect filename)
    (org-latex-publish-to-pdf plist filename pub-dir)))

(let* ((base-directory "./lecciones/")
       (public-directory "./docs/")
       (org-export-with-broken-links t)
       (org-publish-project-alist `(("html"
				     :base-directory ,base-directory
				     :base-extension "org"
                                     :publishing-directory ,public-directory
				     :exclude "src\\|docs\\|Calendario"
				     :recursive t
				     :publishing-function org-html-publish-to-html
				     :auto-preamble t
				     :auto-sitemap nil)
				    
				    ("pdf"
				     :base-directory ,base-directory
				     :base-extension "org"
				     :publishing-directory ,(concat public-directory "pdfs")
 				     :exclude "src\\|docs\\|Calendario"
				     :recursive t
				     :publishing-function my-org-latex-publish-to-pdf
				     :auto-preamble t
				     :auto-sitemap nil)
				    
				    ("static-html"
				     :base-directory ,base-directory
				     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|txt\\|svg\\|aiff\\|csv\\|gdt\\|inp\\|ipynb"
				     :publishing-directory ,public-directory
				     :exclude "src\\|docs\\|Calendario"
				     :recursive t
				     :publishing-function org-publish-attachment)

				    ;; ... all the components ...
				    ("scimax-eln" :components ("html" "static-html" "pdf")))))

  (org-publish "scimax-eln" t))
