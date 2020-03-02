(setq org-pandoc-options '((standalone . t)
                           (variable "margin-top:15"
                                     "margin-bottom:15"
                                     "margin-left:15"
                                     "margin-right:15")
                           (pdf-engine . "wkhtmltopdf")))

(defvar my-org-pandoc-temporary-css-file nil
  "Temporary css file to be deleted.")

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

(add-hook 'org-export-before-processing-hook #'my-org-pandoc-inline-css-hook)
(add-hook 'org-pandoc-after-processing-html5-pdf-hook
          #'my-org-pandoc-delete-temporary-css-file-hook)
(add-hook 'org-pandoc-after-processing-html5-hook
          #'my-org-pandoc-delete-temporary-css-file-hook)

;; custom vars

(defvar-local file-local-time-locale nil
  "Overrides system-time-locale.")

(defun file-local-time-locale-safep (value)
  (stringp value))

(put 'file-local-time-locale 'safe-local-variable
     #'file-local-time-locale-safep)

;; filters timestamps through org-timestamp-translate

(defun my-org-pandoc-timestamp (timestamp _contents info)
  (org-timestamp-translate timestamp))

;; interprets the title of a headline before sending it to the
;; underlying transcoder
(defun my-org-pandoc-headline (headline contents info)
  (let* ((text (org-export-data
                (org-element-property :title headline) info))
        (alt-headline (org-element-put-property
                       headline :title text)))
    (org-org-headline alt-headline contents info)))

(with-eval-after-load 'ox-pandoc
  ;; https://lists.gnu.org/archive/html/emacs-devel/2018-03/msg00557.html
  (eval
   '(progn
      (setf (alist-get 'timestamp
                            ;; org-export-backend is a struct
                            ;; and transcoders a slot
                            (org-export-backend-transcoders
                             (org-export-get-backend 'pandoc)))
            'my-org-pandoc-timestamp)
      (setf (alist-get 'headline
                            (org-export-backend-transcoders
                             (org-export-get-backend 'pandoc)))
            'my-org-pandoc-headline))))

;; customizing the export menu
;; for each menu key in my-org-pandoc-menu-keys, replace the current
;; action with a "my-" prefixed function
(with-eval-after-load 'ox-pandoc
  (cl-labels ((my-org-pandoc-menu-keys
               () '(?$ ?4 ?% ?5))
              (customize-menu-entries
               (as)
               (unless (null as)
                 (let* ((a (car as))
                        (description-action (alist-get a org-pandoc-menu-entry))
                        (description (car description-action))
                        (action (car (cdr description-action))))
                   (setf
                    (alist-get a org-pandoc-menu-entry)
                    (list description
                          (intern-soft
                           (concat "my-" (symbol-name action)))))
                   (customize-menu-entries (cdr as))))))
    (customize-menu-entries (my-org-pandoc-menu-keys))))
