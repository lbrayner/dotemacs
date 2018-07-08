(defun get-line-mode-column-mode-format (mode-line-position)
  "Gets `mode-line-position's construct when both `line-number-mode'
  and `column-number-mode' are set."
  (cadr (cadr (car (cadr (nth 2 mode-line-position))))))

(defun set-line-mode-column-mode-format (mode-line-position value)
  "Sets `mode-line-position's construct to VALUE when both
  `line-number-mode'and `column-number-mode' are set."
  (setf (cadr (cadr (car (cadr (nth 2 mode-line-position))))) value))

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
    (format-mode-line "%l")))

(setf (get-line-mode-column-mode-format mode-line-position)
      `(:eval (concat ,line-mode-column-mode-original-format " "
                      (total-lines-as-string))))
