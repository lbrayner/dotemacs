(global-set-key (kbd "C-x C-b") #'ibuffer)

;; https://www.emacswiki.org/emacs/IbufferMode#toc11
;; https://github.com/purcell/emacs.d/blob/master/lisp/init-ibuffer.el
(after-load 'ibuffer
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
