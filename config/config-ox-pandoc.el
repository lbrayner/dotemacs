(setq org-pandoc-options '((standalone . t)
                           (variable "margin-top:15"
                                     "margin-bottom:15"
                                     "margin-left:15"
                                     "margin-right:15")
                           (pdf-engine . "wkhtmltopdf")))

(defvar org-pandoc-temporary-css-file nil
  "Temporary css file to be deleted.")

(defun org-pandoc-inline-css (exporter)
  "Insert custom inline css (pandoc)"
  (when (eq exporter 'pandoc)
    (let* ((dir (ignore-errors (file-name-directory (buffer-file-name))))
           (filename (concat (file-name-base (buffer-file-name)) ".css"))
           (path (expand-file-name filename dir))
           (default (or (null dir) (null (file-exists-p path))))
           (default-file (expand-file-name "org-style.css" user-emacs-directory))
           (final (if default default-file path)))
      (if (file-exists-p final)
          (setf (alist-get 'include-before-body org-pandoc-options)
                (let ((temp-file (make-temp-name "pandoc-css.")))
                  (setq org-pandoc-temporary-css-file temp-file)
                  (with-temp-file temp-file
                    (insert (concat "<style type=\"text/css\">\n"
                                    "<!--/*--><![CDATA[/*><!--*/\n"))
                    (save-excursion (insert (concat "/*]]>*/-->\n"
                                                    "</style>\n")))
                    (insert-file-contents final))
                  temp-file))
        (setq org-pandoc-options (assq-delete-all 'include-before-body org-pandoc-options))))))

(add-hook 'org-export-before-processing-hook #'org-pandoc-inline-css)

(defun org-pandoc-delete-temporary-css-file ()
  "Delete the temporary css file."
  (if org-pandoc-temporary-css-file
      (delete-file org-pandoc-temporary-css-file))
  (setq org-pandoc-temporary-css-file nil))

(add-hook 'org-pandoc-after-processing-html5-pdf-hook
          #'org-pandoc-delete-temporary-css-file)
(add-hook 'org-pandoc-after-processing-html5-hook
          #'org-pandoc-delete-temporary-css-file)

(defun org-pandoc-timestamp-transcoder (timestamp _contents info)
  "Filter TIMESTAMP through `org-timestamp-translate'."
  (org-timestamp-translate timestamp))

(defun org-pandoc-headline-transcoder (headline contents info)
  "Interpret the title of HEADLINE before sending it to the underlying transcoder."
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
                       ;; and transcoders, a slot
                       (org-export-backend-transcoders (org-export-get-backend
                                                        'pandoc)))
            'org-pandoc-timestamp-transcoder)
      (setf (alist-get 'headline
                       (org-export-backend-transcoders (org-export-get-backend
                                                        'pandoc)))
            'org-pandoc-headline-transcoder))))

(defvar-local file-local-time-locale nil
  "To override `system-time-locale' in ox commands.")

(defun file-local-time-locale-safep (value)
  (stringp value))

(put 'file-local-time-locale 'safe-local-variable
     #'file-local-time-locale-safep)

(with-eval-after-load 'ox-pandoc
  (let ((org-export-functions-to-wrap '(org-html-export-as-html
                                        org-html-export-to-html
                                        org-pandoc-export-as-html5
                                        org-pandoc-export-to-html5
                                        org-pandoc-export-to-html5-and-open
                                        org-pandoc-export-to-html5-pdf
                                        org-pandoc-export-to-html5-pdf-and-open)))
    (cl-labels
        ((create-wrappers
          (as)
          "Create 'my-'-prefixed wrappers for ox commands."
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
              (create-wrappers (cdr as))))))
      (create-wrappers org-export-functions-to-wrap))))

;; customizing the export dispatcher
;; for each menu key in org-pandoc-menu-keys, replace the current
;; action with a "my-" prefixed command
(with-eval-after-load 'ox-pandoc
  (let ((org-pandoc-menu-keys '(?$ ?4 ?% ?5)))
    (cl-labels ((customize-menu-entries
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
      (customize-menu-entries org-pandoc-menu-keys))))
