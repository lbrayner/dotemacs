(evil-mode t)
(global-evil-leader-mode)
(setq evil-want-Y-yank-to-eol nil)
(setq evil-search-module 'evil-search)

        ; evil-surround
(global-evil-surround-mode 1)

            ; custom bindings
(define-key evil-motion-state-map "ç" #'evil-ex)
(define-key evil-visual-state-map "ç" #'evil-ex)
(define-key evil-motion-state-map "¬" #'evil-first-non-blank)
(define-key evil-motion-state-map (kbd "<f6>") #'evil-write)
(define-key evil-motion-state-map (kbd "<f9>") #'delete-window)

(defun my-kill-line ()
  "Kills text before point."
  (interactive) (kill-line 0))

(defun my-evil-save-buffer ()
  "Enters `evil-normal-state' and saves the buffer."
  (interactive)
  (evil-normal-state) (save-buffer))

(define-key evil-insert-state-map "\C-u" #'my-kill-line)
(define-key evil-insert-state-map (kbd "<f6>") #'my-evil-save-buffer)

(define-key evil-motion-state-map "\C-h" #'evil-window-left)
(define-key evil-motion-state-map "\C-j" #'evil-window-down)
(define-key evil-motion-state-map "\C-k" #'evil-window-up)
(define-key evil-motion-state-map "\C-l" #'evil-window-right)

(define-key evil-motion-state-map "gt" #'other-frame)

(with-eval-after-load 'custom-interactive
  (define-key evil-motion-state-map "gT" #'other-frame-reverse))

(defun my-evil-record-macro (register)
  "For recursive binding of keys following q."
 (interactive
   (list (unless (and evil-this-macro defining-kbd-macro)
           (or evil-this-register (evil-read-key)))))
 (cond ((eq register ?ç)
        (evil-command-window-ex))
       (t (evil-record-macro register))))

(define-key evil-normal-state-map "q" #'my-evil-record-macro)

;; Bailey Ling

(setq evil-emacs-state-cursor '("red" box))
(setq evil-motion-state-cursor '("orange" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("red" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

(let ((emacs-state-major-modes
        '(eshell-mode
          term-mode
          calculator-mode
          dired-mode
          Info-mode
          makey-key-mode)))
  (cl-loop for mode in emacs-state-major-modes
         do (evil-set-initial-state mode 'emacs)))

(let ((emacs-state-minor-modes
        '(edebug-mode
          git-commit-mode
          magit-blame-mode)))
  (cl-loop for mode in emacs-state-minor-modes
         do (let ((hook (concat (symbol-name mode) "-hook")))
              (add-hook (intern hook) `(lambda ()
                                         (if ,mode
                                             (evil-emacs-state)
                                           (evil-normal-state)))))))

(let ((emacs-state-hooks '(org-log-buffer-setup-hook
                           org-capture-mode-hook)))
 (cl-loop for hook in emacs-state-hooks
         do (add-hook hook #'evil-emacs-state)))
