;;
;; MELPA
;;

    ;; slime
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy))
    ;; haskell-mode
(defun no-eldoc-documentation-function ()
  "Set `eldoc-documentation-function' to nil."
  (setq show-trailing-whitespace nil))
(add-hook 'haskell-mode-hook #'no-eldoc-documentation-function)
    ;; auto-dim-other-buffers
(auto-dim-other-buffers-mode)
    ;; ace-window
(global-set-key (kbd "<f10>") 'ace-window)
    ;; elfeed
(setq elfeed-search-remain-on-entry t)
(setq elfeed-search-date-format '("%Y-%m-%d %H:%M" 16 :left))

    ;; smartparens
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

(define-key smartparens-mode-map (kbd "<C-left>") nil)
(define-key smartparens-mode-map (kbd "<C-right>") nil)

(let ((modifier 'shift))
  (define-key smartparens-mode-map (vector (list modifier 'up))    #'sp-backward-slurp-sexp)
  (define-key smartparens-mode-map (vector (list modifier 'down))  #'sp-backward-barf-sexp)
  (define-key smartparens-mode-map (vector (list modifier 'left))  #'sp-forward-barf-sexp)
  (define-key smartparens-mode-map (vector (list modifier 'right)) #'sp-forward-slurp-sexp))

;;
;; Git
;;

    ;; frames
(require 'frames)
(global-set-key (kbd "<f8>") #'frames)

    ;; icicles
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

    ;; smart-tab
(require 'smart-tab)
(global-smart-tab-mode 1)
;; see function `smart-tab-call-completion-function'
(setq smart-tab-using-hippie-expand t)
(setq smart-tab-user-provided-completion-function 'completion-at-point)
(add-to-list 'smart-tab-disabled-major-modes 'slime-repl-mode)
