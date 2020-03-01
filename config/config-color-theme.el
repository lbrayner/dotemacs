;; themes
    ;; emacs-color-theme-solarized
(load-theme 'solarized t)
    ;; melpa
        ;; solarized
;; (setq solarized-use-variable-pitch nil
;;       solarized-scale-org-headlines nil)
;; (setq solarized-high-contrast-mode-line t)
;; (load-theme 'solarized-dark t)
        ;; dracula
; (if (window-system)
;     (load-theme 'dracula t))

  ;; from solarized-theme's solarized-dark
(let ((yellow    "#b58900"))
  (when my-display-line-numbers-should-be-enabled
    (set-face-attribute 'line-number-current-line nil
                        :weight 'bold
                        :foreground yellow)))

