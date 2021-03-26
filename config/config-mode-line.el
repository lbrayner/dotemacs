;; (defun get-line-mode-column-mode-format (mode-line-position)
;;   "Gets `mode-line-position's construct when both `line-number-mode'
;;   and `column-number-mode' are set."
;;   (if (version<= "26.0.50" emacs-version)
;;       (cadr (cadr (cadr (car (cadr (nth 2 mode-line-position))))))
;;     (cadr (cadr (car (cadr (nth 2 mode-line-position)))))))

;; (defun set-line-mode-column-mode-format (mode-line-position value)
;;   "Sets `mode-line-position's construct to VALUE when both
;;   `line-number-mode'and `column-number-mode' are set."
;;   (if (version<= "26.0.50" emacs-version)
;;       (setf (cadr (cadr (cadr (car (cadr (nth 2 mode-line-position)))))) value)
;;     (setf (cadr (cadr (car (cadr (nth 2 mode-line-position))))) value)))

;; (gv-define-simple-setter get-line-mode-column-mode-format
;;                          set-line-mode-column-mode-format)

;; (defconst line-mode-column-mode-original-format
;;   (get-line-mode-column-mode-format mode-line-position)
;;   "`mode-line-position's original construct when `line-number-mode'
;;   and `column-number-mode' are set.")

;; modifying the mode-line

;; https://emacs.stackexchange.com/a/26724
(defun total-lines-as-string ()
  "Returns the total number of lines of buffer as a string."
  (save-excursion
    (goto-char (point-max))
    (backward-char)
    (format-mode-line "%l")))

;; (setf (get-line-mode-column-mode-format mode-line-position)
;;       `(:eval (concat ,line-mode-column-mode-original-format " "
;;                       (total-lines-as-string))))

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

;; https://www.masteringemacs.org/article/hiding-replacing-modeline-strings

;;; Hiding and replacing modeline strings with clean-mode-line
;;; By Mickey Petersen

;; (defvar mode-line-cleaner-alist
;;   '((auto-complete-mode . " α")
;;     (yas/minor-mode . " υ")
;;     (smartparens-mode . " π")
;;     (evil-smartparens-mode . "")
;;     (eldoc-mode . "")
;;     (slime-autodoc-mode . "")
;;     (abbrev-mode . "")
;;     (undo-tree-mode . "")
;;     (auto-dim-other-buffers-mode . "")
;;     (smart-tab-mode . " ➤")
;;     (visual-line-mode . " ←")
;;     (flyspell-mode . "")
;;     ;; Major modes
;;     (fundamental-mode . "Φ")
;;     (lisp-interaction-mode . "λ")
;;     (hi-lock-mode . "")
;;     (python-mode . "Py")
;;     (emacs-lisp-mode . "Ɛ")
;;     (lisp-mode . "£")
;;     (org-mode . "Ω")
;;     (nxhtml-mode . "nx"))
;;   "Alist for `clean-mode-line'.

;; When you add a new element to the alist, keep in mind that you
;; must pass the correct minor/major mode symbol and a string you
;; want to use in the modeline *in lieu of* the original.")

;; (defun clean-mode-line ()
;;   (interactive)
;;   (cl-loop for cleaner in mode-line-cleaner-alist
;;         do (let* ((mode (car cleaner))
;;                   (mode-str (cdr cleaner))
;;                   (old-mode-str (cdr (assq mode minor-mode-alist))))
;;              ;; minor mode
;;              (when old-mode-str
;;                (setcar old-mode-str mode-str))
;;              ;; major mode
;;              (when (eq mode major-mode)
;;                (setq mode-name mode-str)))))

;; (add-hook 'after-change-major-mode-hook 'clean-mode-line)

;; https://amitp.blogspot.com/2019/07/emacs-mode-line-simplified.html

;; ;; Mode line construct to put at the front of the mode line.
;; (setq-default mode-line-front-space "")
;; ;; Mode line construct to report the multilingual environment.
;; (setq-default mode-line-mule-info "")
;; ;; Mode line construct for identifying emacsclient frames.
;; (setq-default mode-line-client "")
;; ;; Mode line construct for displaying whether current buffer is modified.
;; ;; (setq-default mode-line-modified '(" %1* "))
;; ;; Mode line construct to indicate a remote buffer.
;; (setq-default mode-line-remote "")
;; ;; Mode line construct to describe the current frame.
;; (setq-default mode-line-frame-identification "")
;; ;; Mode line construct to put at the end of the mode line.
;; (setq-default mode-line-end-spaces "")

(make-face 'mode-line-read-only-face)
(set-face-attribute 'mode-line-read-only-face nil :inherit 'mode-line
                    :foreground nil
                    :background "Purple")

(make-face 'mode-line-modified-face)
(set-face-attribute 'mode-line-modified-face nil :inherit 'mode-line
                    :foreground nil
                    :background "Red")

(defvar selected-window nil)

(defun record-selected-window ()
  (setq selected-window (selected-window)))

(add-hook 'buffer-list-update-hook #'record-selected-window)

(defun window-active-p ()
  (eq selected-window (selected-window)))

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
            (substring vc 5))))
(put 'mode-line-vc 'risky-local-variable t)

(defun mode-line-project-root ()
  (or (cdr (project-current)) default-directory))

(defun mode-line-buffer-name ()
  (cond (buffer-file-name
         (s-chop-prefix (abbreviate-file-name (mode-line-project-root))
                        (abbreviate-file-name buffer-file-name)))
        (t "%b")))

(defun mode-line--path-as-list (path)
  (let* ((path-as-file (directory-file-name path))
         (parent (file-name-directory path-as-file)))
    (if (or (not parent) (equal path-as-file parent))
        (list path-as-file)
      (append (mode-line--path-as-list parent)
              (list (file-name-nondirectory path-as-file))))))

(defun mode-line--truncate-path-component (component)
  (replace-regexp-in-string "\\([^[:alpha:]]*[[:alpha:]]\\).*" "\\1" component))

(defun mode-line--shorten-path-worker (ts ps m)
  (let* ((path (append ts ps))
         (length (apply #'+ (mapcar #'length path))))
    (if (or (not ps) (< length m))
        path
      (let ((remaining-ps (cdr ps))
            (resulting-ts (append ts (list (mode-line--truncate-path-component (car ps))))))
        (mode-line--shorten-path-worker resulting-ts remaining-ps m)))))

;; https://stackoverflow.com/a/13473856
(defun mode-line--joinnodes (root &rest dirs)
  "Joins a series of directories together, like Python's
os.path.join,(dotemacs-joindirs \"/tmp\" \"a\" \"b\" \"c\") =>
/tmp/a/b/c"
  (if (not dirs)
      root
    (apply #'mode-line--joinnodes
           (expand-file-name (car dirs) root)
           (cdr dirs))))

(defun mode-line-shorten-path (path max-length)
  (let* ((as-list (mode-line--path-as-list path))
         (shortended (mode-line--shorten-path-worker nil as-list max-length)))
    (abbreviate-file-name (apply #'mode-line--joinnodes shortended))))

;; Mode line construct for identifying the buffer being displayed.
(setq-default mode-line-buffer-identification
              '(" "
                (:eval (when buffer-file-name
                         (file-name-as-directory
                          (mode-line-shorten-path (mode-line-project-root)
                                                  (- (window-width)
                                                     (length (mode-line-buffer-name))
                                                     (/ (window-total-width) 2))))))
                (:eval (mode-line-buffer-name))))

;; Mode line construct for displaying the position in the buffer.
(setq-default mode-line-position
              '((:eval (concat "%"
                               (number-to-string
                                (ceiling (log (string-to-number (total-lines-as-string)) 10)))
                               "l"))
                "," (3 "%C") " " (-3 "%p") " " (:eval (total-lines-as-string))))

;; https://www.gonsie.com/blorg/modeline.html
;; Mode line construct for displaying major and minor modes.
(setq-default mode-line-modes
              '(:eval (let ((mode (format-mode-line
                                   (concat "%[" mode-name mode-line-process "%n%]"))))
                        (concat
                         (propertize
                          " " 'display
                          `((space :align-to
                                   (- (+ right right-fringe right-margin)
                                      ,(+ 3 (string-width mode))))))
                         mode))))

(setq-default mode-line-format '("%e" mode-line-buffer-identification
                                 mode-line-modified "   " mode-line-position
                                 evil-mode-line-tag mode-line-vc mode-line-modes))
