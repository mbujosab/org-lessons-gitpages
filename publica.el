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

(let* ((base-directory "./"))
  (setq org-publish-project-alist
        (append org-publish-project-alist
                `(("index"
                   :base-directory ,base-directory
                   :base-extension "org"
                   :publishing-directory ,(concat base-directory "docs")
                   :exclude "src\\|Calendario\\|org-lessons\\|org-practicas\\|docs\\|chatCopilot.org\\|org-publish.org\\|README.org"
                   :recursive t
                   :publishing-function org-html-publish-to-html
                   :auto-preamble t
                   :auto-sitemap t
                   :with-author nil
                   :with-creator nil
                   :with-toc t
                   :section-numbers nil)

                  ("pdf"
                   :base-directory "./Lecciones/"
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
                   :exclude "src\\|Calendario\\|org-lessons\\|org-practicas\\|docs\\|chatCopilot.*\\|org-publish.*\\|README.org"
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
