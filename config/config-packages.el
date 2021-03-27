;; |       |
;; | MELPA |
;; |       |

    ;; SMARTPARENS
(require 'smartparens-config)

(let ((smartparens-evil-major-modes '(emacs-lisp-mode
                                      lisp-mode
                                      lisp-interaction-mode
                                      scheme-mode))
      (smartparens-major-modes '(eval-expression-minibuffer-setup
                                 ielm-mode
                                 slime-repl-mode)))
  (cl-loop for mode in smartparens-evil-major-modes
           do (add-hook 'smartparens-enabled-hook #'evil-smartparens-mode))
  (cl-loop for mode in (append smartparens-evil-major-modes
                               smartparens-major-modes)
           do (let ((hook (concat (symbol-name mode) "-hook")))
                (add-hook (intern hook) #'smartparens-strict-mode))))

(sp-use-smartparens-bindings)

(let ((modifier 'shift))
  (global-set-key (vector (list modifier 'up))    #'sp-backward-slurp-sexp)
  (global-set-key (vector (list modifier 'down))  #'sp-backward-barf-sexp)
  (global-set-key (vector (list modifier 'left))  #'sp-forward-barf-sexp)
  (global-set-key (vector (list modifier 'right)) #'sp-forward-slurp-sexp))

;; |        |
;; | GitHub |
;; |        |

    ;; FRAMES
(require 'frames)
(global-set-key (kbd "<f8>") #'frames)

    ;; ICICLES
(require 'icicles)

(defun icicle-select-window (win-name &optional window-alist)
  "Calls `icicle-read-choose-window-args' with `current-prefix-arg'
set to \\='- and then selects window via
`icicle-choose-window-by-name'."
  (interactive (let ((current-prefix-arg (cond ((display-graphic-p) '-)
                                               (t nil))))
                 (icicle-read-choose-window-args)))
  (icicle-choose-window-by-name win-name window-alist))

(global-set-key (kbd "<f5>") 'icicle-select-window)

    ;; SMART-TAB
(require 'smart-tab)
(global-smart-tab-mode 1)
;; see function `smart-tab-call-completion-function'
(setq smart-tab-using-hippie-expand t)
(setq smart-tab-user-provided-completion-function 'completion-at-point)
(add-to-list 'smart-tab-disabled-major-modes 'slime-repl-mode)

    ;; ACE-WINDOW
(global-set-key (kbd "<f10>") 'ace-window)
