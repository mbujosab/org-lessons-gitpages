(require 'ox-publish)

(defun my-org-babel-execute-buffer ()
  "Ejecuta todos los bloques de código en el buffer actual."
  (org-babel-execute-buffer))

(defun my-org-html-publish-to-html (plist filename pub-dir)
  "Publica un archivo Org como HTML después de ejecutar los bloques de código."
  (with-current-buffer (find-file-noselect filename)
    ;(my-org-babel-execute-buffer) ; Ejecuta los bloques
    (org-html-publish-to-html plist filename pub-dir)))

(defun my-org-latex-publish-to-pdf (plist filename pub-dir)
  "Publica un archivo Org como PDF después de ejecutar los bloques de código."
  (with-current-buffer (find-file-noselect filename)
    ;(my-org-babel-execute-buffer) ; Ejecuta los bloques
    (org-latex-publish-to-pdf plist filename pub-dir)))

(let* ((base-directory "./lecciones/")
       (public-directory "./docs/")
       (org-export-with-broken-links t)
       (org-publish-project-alist `(("html"
                                     :base-directory ,base-directory
                                     :base-extension "org"
                                     :publishing-directory ,public-directory
                                     :exclude ".ipynb_checkpoints\\|00Notas.*\\|org-publisg.*\\|kk.*\\|src"
                                     :recursive t
                                     :auto-preamble t
                                     :auto-sitemap t
				     :sitemap-title "Lecciones"
                                     :publishing-function my-org-html-publish-to-html
    				     :exclude-tags ("pdf"))
                                   
                                    ("pdf"
                                     :base-directory ,base-directory
                                     :base-extension "org"
                                     :publishing-directory ,(concat public-directory "pdfs")
                                     :exclude ".ipynb_checkpoints\\|src\\|sitemap.pdf"
                                     :recursive t
                                     :auto-preamble t
                                     :auto-sitemap nil
                                     :publishing-function my-org-latex-publish-to-pdf)
                                    
                                    ("static-html"
                                     :base-directory ,base-directory
                                     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|svg\\|aiff\\|csv\\|gdt\\|inp\\|ipynb\\|html"
                                     :publishing-directory ,public-directory
                                     :exclude "docs\\|src\\|EjerciciosHide\\|.ipynb_checkpoints\\|org-publisg.*\\|kk.*\\|Lecc*.pdf\\|sitemap.pdf"
                                     :recursive t
                                     :publishing-function org-publish-attachment)

                                    ("scimax-eln" :components ("html" "static-html" "pdf")))))

  (org-publish "scimax-eln" t))
