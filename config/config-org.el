;; https://stackoverflow.com/a/37132338/2856535
(defun org-inline-css (exporter)
  "Insert custom inline css"
  (when (eq exporter 'html)
    (let* ((dir (ignore-errors (file-name-directory (buffer-file-name))))
           (filename (concat (file-name-base (buffer-file-name)) ".css"))
           (path (concat dir filename))
           (default (or (null dir) (null (file-exists-p path))))
           (default-file (expand-file-name ".emacs.d/org-style.css" (home-directory)))
           (final (if default "~/.emacs.d/org-style.css" path)))
      (setq org-html-head-include-default-style nil)
      (setq org-html-head "")
      (if (file-exists-p final)
        (setq org-html-head (concat
                              "<style type=\"text/css\">\n"
                              "<!--/*--><![CDATA[/*><!--*/\n"
                              (with-temp-buffer
                                (insert-file-contents final)
                                (buffer-string))
                              "/*]]>*/-->\n"
                              "</style>\n"))))))

(defun org-mode-setup ()
  (visual-line-mode t)
  (setq truncate-lines nil)
  (flyspell-mode)
  (electric-indent-local-mode 0))

(defun org-mode-evil-setup ()
  (setq evil-auto-indent nil))

;; major modes
    ;; org
(setq org-export-time-stamp-file nil)
(setq org-html-validation-link nil)
(setq-default org-export-with-author nil)
(setq-default org-export-with-toc nil)
(setq-default org-use-sub-superscripts '{})
(setq-default org-export-with-sub-superscripts '{})
(add-hook 'org-mode-hook #'org-mode-setup)
(with-eval-after-load 'evil
  (add-hook 'org-mode-hook #'org-mode-evil-setup))
(add-hook 'org-export-before-processing-hook #'org-inline-css)
        ;; babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)))

;; I'm big on org exporting
(with-eval-after-load 'org
  (require 'ox))

;; allows org-time-stamp-custom-formats to be file-local:

;; https://emacs.stackexchange.com/a/2247
(defun org-time-stamp-custom-formats-safep (value)
  (and (consp value)
       (stringp (car value))
       (stringp (cdr value))))

(put 'org-time-stamp-custom-formats 'safe-local-variable
     #'org-time-stamp-custom-formats-safep)

;; creates "my-"-prefixed wrappers for functions inside
(let ((org-export-functions-to-wrap '(org-html-export-as-html
                                      org-html-export-to-html
                                      org-pandoc-export-as-html5
                                      org-pandoc-export-to-html5
                                      org-pandoc-export-to-html5-and-open
                                      org-pandoc-export-to-html5-pdf
                                      org-pandoc-export-to-html5-pdf-and-open)))
  (cl-labels
      ((create-wrapper
        (as)
        (unless (null as)
          (let ((a (car as)))
            (fset (intern (concat "my-" (symbol-name a)))
                  ;; see `org-export-to-file'
                  `(lambda (&optional y s v b e)
                     (interactive)
                     (let ((org-display-custom-times t)
                           (system-time-locale (alist-get
                                                'file-local-time-locale
                                                file-local-variables-alist)))
                       (,a y s v b e))))
            (create-wrapper (cdr as))))))
    (create-wrapper org-export-functions-to-wrap)))

    ;; melpa
        ;; ox-reveal
(require 'ox-reveal)
(setq org-reveal-title-slide "<h1> %t </h1>  <br> %a <br> %e")
