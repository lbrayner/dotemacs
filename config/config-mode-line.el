(defun get-line-mode-column-mode-format (mode-line-position)
  "Gets `mode-line-position's construct when both `line-number-mode'
  and `column-number-mode' are set."
  (if (version<= "26.0.50" emacs-version)
      (cadr (cadr (cadr (car (cadr (nth 2 mode-line-position))))))
    (cadr (cadr (car (cadr (nth 2 mode-line-position)))))))

(defun set-line-mode-column-mode-format (mode-line-position value)
  "Sets `mode-line-position's construct to VALUE when both
  `line-number-mode'and `column-number-mode' are set."
  (if (version<= "26.0.50" emacs-version)
      (setf (cadr (cadr (cadr (car (cadr (nth 2 mode-line-position)))))) value)
    (setf (cadr (cadr (car (cadr (nth 2 mode-line-position))))) value)))

(gv-define-simple-setter get-line-mode-column-mode-format
                         set-line-mode-column-mode-format)

(defconst line-mode-column-mode-original-format
  (get-line-mode-column-mode-format mode-line-position)
  "`mode-line-position's original construct when `line-number-mode'
  and `column-number-mode' are set.")

;; modifying the mode-line

;; https://emacs.stackexchange.com/a/26724
(defun total-lines-as-string ()
  "Returns the total number of lines of buffer as a string."
  (save-excursion
    (goto-char (point-max))
    (backward-char)
    (format-mode-line "%l")))

(setf (get-line-mode-column-mode-format mode-line-position)
      `(:eval (concat ,line-mode-column-mode-original-format " "
                      (total-lines-as-string))))

;; https://www.masteringemacs.org/article/hiding-replacing-modeline-strings

;;; Hiding and replacing modeline strings with clean-mode-line
;;; By Mickey Petersen

(defvar mode-line-cleaner-alist
  `((auto-complete-mode . " α")
    (yas/minor-mode . " υ")
    (paredit-mode . " π")
    (eldoc-mode . "")
    (abbrev-mode . "")
    ;; Major modes
    (lisp-interaction-mode . "λ")
    (hi-lock-mode . "")
    (python-mode . "Py")
    (emacs-lisp-mode . "EL")
    (nxhtml-mode . "nx"))
  "Alist for `clean-mode-line'.

When you add a new element to the alist, keep in mind that you
must pass the correct minor/major mode symbol and a string you
want to use in the modeline *in lieu of* the original.")


(defun clean-mode-line ()
  (interactive)
  (loop for cleaner in mode-line-cleaner-alist
        do (let* ((mode (car cleaner))
                 (mode-str (cdr cleaner))
                 (old-mode-str (cdr (assq mode minor-mode-alist))))
             (when old-mode-str
                 (setcar old-mode-str mode-str))
               ;; major mode
             (when (eq mode major-mode)
               (setq mode-name mode-str)))))


(add-hook 'after-change-major-mode-hook 'clean-mode-line)

;; Fly-mode code commented

;;; alias the new `flymake-report-status-slim' to
;;; `flymake-report-status'
;; (defalias 'flymake-report-status 'flymake-report-status-slim)
;; (defun flymake-report-status-slim (e-w &optional status)
;;   "Show \"slim\" flymake status in mode line."
;;   (when e-w
;;     (setq flymake-mode-line-e-w e-w))
;;   (when status
;;     (setq flymake-mode-line-status status))
;;   (let* ((mode-line " Φ"))
;;     (when (> (length flymake-mode-line-e-w) 0)
;;       (setq mode-line (concat mode-line ":" flymake-mode-line-e-w)))
;;     (setq mode-line (concat mode-line flymake-mode-line-status))
;;     (setq flymake-mode-line mode-line)
;;     (force-mode-line-update)))
