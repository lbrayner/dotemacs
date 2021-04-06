    ;; isearch
;; https://www.emacswiki.org/emacs/SearchAtPoint
(defun isearch-yank-regexp (regexp)
  "Pull REGEXP into search regexp."
  (let ((isearch-regexp nil)) ;; Dynamic binding of global.
    (isearch-yank-string regexp))
  (unless isearch-regexp
      (isearch-toggle-regexp))
  (isearch-search-and-update))

(defun isearch-yank-symbol ()
  "Put symbol at current point into search string."
  (interactive)
  (let ((sym (find-tag-default)))
    (if (null sym)
        (message "No symbol at point")
      (isearch-yank-regexp
       (concat "\\_<" (regexp-quote sym) "\\_>")))))

(define-key isearch-mode-map (kbd "M-s C-s") #'isearch-yank-symbol)

    ;; ibuffer
;; https://www.emacswiki.org/emacs/IbufferMode#toc11
;; https://github.com/purcell/emacs.d/blob/master/lisp/init-ibuffer.el
(with-eval-after-load 'ibuffer
  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (file-size-human-readable (buffer-size))))

;; Modify the default ibuffer-formats
(setq ibuffer-formats
      '((mark modified read-only " "
              (name 18 18 :left :elide)
              " "
              (size-h 9 -1 :right)
              " "
              (mode 16 16 :left :elide)
              " "
              filename-and-process)))

    ;; package
(defun package-install-no-read-only-mode (command &rest args)
  "Remove hook `elpa-enable-read-only-mode' during the execution of
`package-install'."
  (when (memq #'elpa-enable-read-only-mode find-file-hook)
    (remove-hook 'find-file-hook #'elpa-enable-read-only-mode)
    (apply command args)
    (add-hook 'find-file-hook #'elpa-enable-read-only-mode)))
(advice-add #'package-install :around #'package-install-no-read-only-mode)
