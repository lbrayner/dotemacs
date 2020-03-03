;; themes
    ;; emacs-color-theme-solarized
(customize-set-variable 'frame-background-mode 'dark)
(load-theme 'solarized t)
(set-face-attribute 'default nil :height 105)

;; (defun solarized-init-frame (frame)
;;   (let ((mode (if (display-graphic-p frame) 'light 'dark)))
;;     (set-frame-parameter frame 'background-mode mode)
;;     (set-terminal-parameter frame 'background-mode mode))
;;   (enable-theme 'solarized))

;; (add-hook 'after-make-frame-functions #'solarized-init-frame)

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
(let ((yellow "#b58900"))
  (when my-display-line-numbers-should-be-enabled
    (set-face-attribute 'line-number-current-line nil
                        :weight 'bold
                        :foreground yellow)))
