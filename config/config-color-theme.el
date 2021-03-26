;; themes
    ;; emacs-color-theme-solarized
(customize-set-variable 'frame-background-mode 'dark)
(load-theme 'solarized t)
(set-face-attribute 'default nil :height 105)

  ;; from solarized-theme's solarized-dark
(let ((yellow "#b58900"))
  (if global-display-line-numbers-mode
    (set-face-attribute 'line-number-current-line nil
                        :weight 'bold
                        :foreground yellow)))
