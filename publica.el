;;; publica.el --- Publicación HTML y PDF para el repositorio Scimax-ELN

(require 'ox-publish)

(setq org-confirm-babel-evaluate nil
      org-export-with-broken-links t
      org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil)

(defun my-org-latex-publish-to-pdf (plist filename pub-dir)
  "Publica un archivo Org como PDF tras ejecutar bloques de código."
  (message "Exportando a PDF: %s" filename)
  (with-current-buffer (find-file-noselect filename)
    ;(org-babel-execute-buffer)
    (org-latex-publish-to-pdf plist filename pub-dir)))

;(let* ((base-directory "./lecciones/")
;       (public-directory "./docs/"))
;  (setq org-publish-project-alist
;        `(("images"
;           :base-directory "./lecciones/img/"
;           :base-extension "jpg\\|gif\\|png"
;           :publishing-directory ,(concat public-directory "img")
;           :publishing-function org-publish-attachment)
;
;          ("html"
;           :base-directory ,base-directory
;           :base-extension "org"
;           :publishing-directory ,public-directory
;           :exclude "src"
;           :recursive t
;           :publishing-function org-html-publish-to-html
;           :auto-preamble t)
;
;          ("pdf"
;           :base-directory ,base-directory
;           :base-extension "org"
;           :publishing-directory ,(concat public-directory "pdfs")
;           :exclude "src"
;           :recursive t
;           :publishing-function my-org-latex-publish-to-pdf
;           :auto-preamble t)
;
;          ("static-html"
;           :base-directory ,base-directory
;           :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|txt\\|svg\\|aiff\\|csv\\|gdt\\|inp"
;           :publishing-directory ,public-directory
;           :exclude "src"
;           :recursive t
;           :publishing-function org-publish-attachment)
;
;          ("scimax-eln" :components ("html" "static-html" "pdf" "images"))))
;
;  (message "🟢 Iniciando publicación de lecciones (scimax-eln)...")
;  (org-publish "scimax-eln" t)
;  (message "✅ Publicación de lecciones completada."))

(let* ((base-directory "./"))
  (setq org-publish-project-alist
        (append org-publish-project-alist
                `(("images"
                   :base-directory "./lecciones/img/"
                   :base-extension "jpg\\|gif\\|png"
                   :publishing-directory ,(concat base-directory "docs/img")
                   :publishing-function org-publish-attachment)

                  ("index"
                   :base-directory ,base-directory
                   :base-extension "org"
                   :publishing-directory ,(concat base-directory "docs")
                   :exclude "Calendario\\|org-lessons\\|org-practicas\\|docs\\|chatCopilot.org\\|org-publish.org\\|README.org"
                   :recursive t
                   :publishing-function org-html-publish-to-html
                   :auto-preamble t
                   :auto-sitemap t
                   :with-author nil
                   :with-creator nil
                   :with-toc t
                   :section-numbers nil)

                  ("pdf"
                   :base-directory "./lecciones/"
                   :base-extension "org"
                   :publishing-directory ,(concat base-directory "docs/pdfs")
                   :exclude "src\\|org-lessons\\|org-practicas"
                   :recursive t
                   :publishing-function my-org-latex-publish-to-pdf
                   :auto-preamble t)

                  ("static-index"
                   :base-directory ,base-directory
                   :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|dat\\|mov\\|txt\\|svg\\|aiff"
                   :publishing-directory ,(concat base-directory "docs")
                   :exclude "Calendario\\|org-lessons\\|org-practicas\\|docs\\|chatCopilot.*\\|org-publish.*\\|README.org"
                   :recursive t
                   :publishing-function org-publish-attachment)

                  ("web-repositorio" :components ("index" "pdf" "static-index")))))

  (message "🟢 Iniciando publicación del índice (web-repositorio)...")
  (org-publish "web-repositorio" t)
  (message "✅ Publicación del índice completada."))

(unless (file-directory-p "logs")
  (make-directory "logs"))
(with-temp-file "logs/publica.log"
  (insert (format "Publicado el %s\n" (current-time-string))))
