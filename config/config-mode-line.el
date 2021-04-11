;; slime

(defun slime-pretty-package-name (name)
  "Return a pretty shortened version of a package name NAME."
  (cl-labels ((package-suffix (package-name)
                              (car (reverse (split-string package-name "\\.")))))
    (cond ((string-match "^#?:\\(.*\\)$" name)
           (package-suffix (match-string 1 name)))
          ((string-match "^\"\\(.*\\)\"$" name)
           (package-suffix (match-string 1 name)))
          ((string= name "COMMON-LISP-USER")
           "CL-USER")
          (t name))))

(with-eval-after-load 'slime
  (advice-add 'slime-pretty-package-name :override 'slime-pretty-package-name))

(make-face 'mode-line-read-only-face)
(set-face-attribute 'mode-line-read-only-face nil :inherit 'mode-line
                    :foreground nil
                    :background "Purple")

(make-face 'mode-line-modified-face)
(set-face-attribute 'mode-line-modified-face nil :inherit 'mode-line
                    :foreground nil
                    :background "Red")

(defvar active-window nil
  "The currently active window.")

(defun record-active-window ()
  "Save the currently active window to `active-window'."
  (setq active-window (selected-window)))

(add-hook 'buffer-list-update-hook #'record-active-window)

(defun window-active-p ()
  "Return t if the window is active."
  (eq active-window (selected-window)))

(setq-default mode-line-modified
              '(:eval
                (cond
                 (buffer-read-only
                  (if (window-active-p)
                      (propertize " R" 'face 'mode-line-read-only-face) " R"))
                 ((buffer-modified-p)
                  (if (window-active-p)
                      (propertize " +" 'face 'mode-line-modified-face) " +"))
                 (t "  "))))

(defvar mode-line-vc
  '(:eval (when-let (vc vc-mode)
            (substring vc 5)))
  "Custom mode line construct that holds VC information.")
(put 'mode-line-vc 'risky-local-variable t)

(defun mode-line--path-as-list (path)
  (let* ((path-as-file (directory-file-name path))
         (parent (file-name-directory path-as-file)))
    (if (or (null parent) (equal path-as-file parent))
        (list path-as-file)
      (append (mode-line--path-as-list parent)
              (list (file-name-nondirectory path-as-file))))))

(defun mode-line--truncate-path-component (component)
  (replace-regexp-in-string "\\([^[:alpha:]]*[[:alpha:]]\\).*" "\\1" component))

(defun mode-line--shorten-path-worker (ts ps m)
  (let* ((path (append ts ps))
         (length (apply #'+ (mapcar #'length path))))
    (if (or (null ps) (< length m))
        path
      (let ((remaining-ps (cdr ps))
            (resulting-ts (append ts (list (mode-line--truncate-path-component (car ps))))))
        (mode-line--shorten-path-worker resulting-ts remaining-ps m)))))

;; https://stackoverflow.com/a/13473856
(defun mode-line--joinnodes (root &rest dirs)
  "Joins a series of directories together, like Python's
os.path.join, (dotemacs-joindirs \"/tmp\" \"a\" \"b\" \"c\") =>
/tmp/a/b/c"
  (if (null dirs)
      root
    (apply #'mode-line--joinnodes
           (expand-file-name (car dirs) root)
           (cdr dirs))))

(defun mode-line-shorten-path (path max-length)
  "Shorten a PATH given a MAX-LENGTH for displaying in the mode line."
  (let* ((as-list (mode-line--path-as-list path))
         (shortened (mode-line--shorten-path-worker nil as-list max-length)))
    (abbreviate-file-name (apply #'mode-line--joinnodes shortened))))

(defun mode-line-project-root ()
  "Return either `project-current' or `default-directory' by default.

Dired mode is a special case, in which the parent directory of
`default-directory' is returned."
  (cond ((eq major-mode 'dired-mode)
         (file-name-directory (directory-file-name default-directory)))
        (t
         (or (cdr (project-current)) default-directory))))

(defun mode-line-buffer-file-name ()
  "Return `buffer-file-name' or an equivalent for use in the mode line."
  (if (eq major-mode 'dired-mode)
      (file-name-as-directory (file-name-nondirectory (directory-file-name default-directory)))
    buffer-file-name))

(defun mode-line-buffer-name ()
  "Return the buffer name for use in the mode line."
  (cond ((mode-line-buffer-file-name)
         (s-chop-prefix (abbreviate-file-name (mode-line-project-root))
                        (abbreviate-file-name (mode-line-buffer-file-name))))
        (t "%b")))

(defvar mode-line-custom-buffer-identification
  '(" "
    (:eval (when (mode-line-buffer-file-name)
             (file-name-as-directory
              (mode-line-shorten-path (abbreviate-file-name (mode-line-project-root))
                                      (- (window-width)
                                         (length (mode-line-buffer-name))
                                         (/ (window-total-width) 2))))))
    (:eval (mode-line-buffer-name)))
  "Custom mode line construct for identifying the buffer being displayed.")
(put 'mode-line-custom-buffer-identification 'risky-local-variable t)

;; https://emacs.stackexchange.com/a/26724
(defun total-lines-as-string ()
  "Returns the total number of lines of buffer as a string."
  (save-excursion
    (goto-char (point-max))
    (backward-char)
    (format-mode-line "%l")))

;; Mode line construct for displaying the position in the buffer.
(setq-default mode-line-position
              '((:eval (concat "%"
                               (number-to-string
                                (ceiling (log (string-to-number (total-lines-as-string)) 10)))
                               "l"))
                "," (3 "%C") " " (-3 "%p") " " (:eval (total-lines-as-string))))

;; https://www.gonsie.com/blorg/modeline.html
(defvar mode-line-custom-modes
  '(:eval (let ((mode (format-mode-line
                       '("%[" mode-name mode-line-process "%n%]"))))
            (concat
             (propertize
              " " 'display
              `((space :align-to
                       (- (+ right right-fringe right-margin)
                          ,(+ 3 (string-width mode))))))
             mode)))
  "Custom mode line construct for displaying major and minor modes.")
(put 'mode-line-custom-modes 'risky-local-variable t)

(setq-default mode-line-format '("%e" mode-line-custom-buffer-identification
                                 mode-line-modified "   " mode-line-position
                                 evil-mode-line-tag mode-line-vc mode-line-custom-modes))

;; Reverting buffer-local variable to the global value
(with-current-buffer "*Messages*"
  (setq mode-line-format (default-value 'mode-line-format)))
