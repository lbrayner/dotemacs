(setq org-pandoc-options '((standalone . t)
			   (variable "margin-top:15"
				     "margin-bottom:15"
				     "margin-left:15"
				     "margin-right:15")
			   (pdf-engine . "wkhtmltopdf")))

(defvar my-org-pandoc-temporary-css-file nil)

(defun my-org-pandoc-inline-css-hook (exporter)
  "Insert custom inline css (pandoc)"
  (when (eq exporter 'pandoc)
    (let* ((dir (ignore-errors (file-name-directory (buffer-file-name))))
           (filename (concat (file-name-base (buffer-file-name)) ".css"))
           (path (concat dir filename))
           (default (or (null dir) (null (file-exists-p path))))
           (default-file (expand-file-name ".emacs.d/org-style.css" (home-directory)))
           (final (if default "~/.emacs.d/org-style.css" path)))
      (if (file-exists-p final)
	  (setf (alist-get 'include-before-body org-pandoc-options)
		(let ((temp-file (make-temp-name "pandoc-css.")))
		  (setq my-org-pandoc-temporary-css-file temp-file)
		  (with-temp-file temp-file
		    (insert (concat "<style type=\"text/css\">\n"
				    "<!--/*--><![CDATA[/*><!--*/\n"))
		    (save-excursion (insert (concat "/*]]>*/-->\n"
						    "</style>\n")))
		    (insert-file-contents final))
		  temp-file))
	(setq org-pandoc-options (assq-delete-all 'include-before-body org-pandoc-options))))))

(defun my-org-pandoc-delete-temporary-css-file-hook ()
  "Deletes the temporary css file."
  (if my-org-pandoc-temporary-css-file
      (delete-file my-org-pandoc-temporary-css-file))
  (setq my-org-pandoc-temporary-css-file nil))

(add-hook 'org-export-before-processing-hook 'my-org-pandoc-inline-css-hook)
(add-hook 'org-pandoc-after-processing-html5-pdf-hook 'my-org-pandoc-delete-temporary-css-file-hook)
(add-hook 'org-pandoc-after-processing-html5-hook 'my-org-pandoc-delete-temporary-css-file-hook)
