(setq evil-want-keybinding nil)
(evil-mode t)
(global-evil-leader-mode)
(setq evil-want-Y-yank-to-eol nil)
(setq evil-search-module 'evil-search)

(defun evil-normal-eval-print-last-sexp ()
  "Evaluate sexp before point; print value into current buffer.

Adjusted for Evil's normal mode. See `eval-print-last-sexp'."
  (interactive)
  (evil-append 1)
  (eval-print-last-sexp)
  (evil-normal-state))

(let ((lisp-modes '(lisp-mode
                    lisp-interaction-mode
                    emacs-lisp-mode)))
  (cl-labels
      ((evil-eval-print-define-keys
        (map)
        (evil-define-key 'normal map (kbd "C-c j") #'evil-normal-eval-print-last-sexp)
        (evil-define-key 'insert map (kbd "C-c j") #'eval-print-last-sexp))
       (evil-custom-bindings
        (modes)
        (unless (null modes)
          (let* ((mode (car modes))
                 (map (concat (symbol-name mode) "-map")))
            (evil-eval-print-define-keys (symbol-value (intern map)))
            (evil-custom-bindings (cdr modes))))))
    (evil-custom-bindings lisp-modes)))

(define-key evil-motion-state-map "ç" #'evil-ex)
(define-key evil-visual-state-map "ç" #'evil-ex)
(define-key evil-motion-state-map "¬" #'evil-first-non-blank)
(define-key evil-motion-state-map (kbd "<f6>") #'evil-write)
(define-key evil-motion-state-map (kbd "<f9>") #'delete-window)

(defun evil-kill-line-reverse ()
  "Kill text before point."
  (interactive)
  (kill-line 0))

(define-key evil-insert-state-map "\C-u" #'evil-kill-line-reverse)

(defun evil-save-buffer ()
  "Enter `evil-normal-state' and save the buffer."
  (interactive)
  (evil-normal-state)
  (save-buffer))

(define-key evil-insert-state-map (kbd "<f6>") #'evil-save-buffer)

(define-key evil-motion-state-map "\C-h" #'evil-window-left)
(define-key evil-motion-state-map "\C-j" #'evil-window-down)
(define-key evil-motion-state-map "\C-k" #'evil-window-up)
(define-key evil-motion-state-map "\C-l" #'evil-window-right)

(define-key evil-motion-state-map "gt" #'other-frame)

(with-eval-after-load 'custom-interactive
  (define-key evil-motion-state-map "gT" #'other-frame-reverse))

(defun evil-record-macro-wrapper (register)
  "Wrap `evil-record-macro' for recursive binding of keys following q."
 (interactive
   (list (unless (and evil-this-macro defining-kbd-macro)
           (or evil-this-register (evil-read-key)))))
 (cond ((eq register ?ç)
        (evil-command-window-ex))
       (t (evil-record-macro register))))

(define-key evil-normal-state-map "q" #'evil-record-macro-wrapper)

;; Tim Pope's vim-commentary-like functionality

(evil-define-command evil-comment (beg end)
  "Comment text from BEG to END."
  (interactive "<r>")
  (comment-or-uncomment-region beg end))

;; Makes g a prefix key in evil-normal-state-map
(define-key evil-normal-state-map "g" nil)

(define-key evil-normal-state-map "gc" #'evil-comment)
(define-key evil-visual-state-map "gc" #'evil-comment)

(evil-define-operator evil-custom-fill (beg end)
  "Fill text as one paragraph."
  :move-point nil
  :type line
  (save-excursion
    (condition-case nil
        (fill-region-as-paragraph beg end)
      (error nil))))

(define-key evil-normal-state-map "gq" #'evil-custom-fill)
(define-key evil-visual-state-map "gq" #'evil-custom-fill)

(defun evil-unimpaired-open-line (n)
  "Perform Tim Pope's unimpaired ]<Space>."
  (interactive "p")
  (save-excursion
    (move-end-of-line 1)
    (open-line n)))

(defun evil-unimpaired-open-line-above (n)
  "Perform Tim Pope's unimpaired [<Space>."
  (interactive "p")
  (cond ((bolp)
         (open-line n)
         (forward-line n))
        (t (save-excursion
             (move-beginning-of-line 1)
             (open-line n)))))

(define-key evil-normal-state-map "] " #'evil-unimpaired-open-line)
(define-key evil-normal-state-map "[ " #'evil-unimpaired-open-line-above)

;; Bailey Ling's snippets

(setq evil-emacs-state-cursor '("red" box))
(setq evil-motion-state-cursor '("orange" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("green" bar))
(setq evil-replace-state-cursor '("green" bar))
(setq evil-operator-state-cursor '("red" hollow))

(let ((emacs-state-major-modes
        '(eshell-mode
          shell-mode
          term-mode
          calculator-mode
          dired-mode
          Info-mode
          slime-repl-mode
          makey-key-mode
          haskell-interactive-mode)))
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

;; End of Bailey Ling's snippets

;; motion-state-major-modes currently contains only 1 item
(let ((motion-state-major-modes '(frames-mode)))
  (cl-labels
      ((set-initial-state-motion
        (modes)
        (unless (null modes)
          (let ((mode (car modes)))
            (evil-set-initial-state mode 'motion)
            (set-initial-state-motion (cdr modes))))))
    (set-initial-state-motion motion-state-major-modes)))

;; https://emacs.stackexchange.com/a/31649
;; Advise end-of-buffer to just go up a line if it leaves you on an empty line
(defun evil-advice-avoid-ghost-line (&rest _)
  "Call `evil-previous-line' if current line is empty."
  (when (looking-at-p "^$")
    (evil-previous-line)))

(advice-add #'evil-window-bottom :after #'evil-advice-avoid-ghost-line)

(defun evil-advice-insert-visual-marks (&rest _)
  "Insert last selected visual area marks."
  (let ((previous-window-evil-visual-state-p
         (save-selected-window (select-window (previous-window))
                               (evil-visual-state-p))))
    (if previous-window-evil-visual-state-p
        (insert "'<,'>"))))

(advice-add #'evil-command-window-ex :after #'evil-advice-insert-visual-marks)

    ;; evil-surround
(global-evil-surround-mode 1)

    ;; evil-collection
(require 'evil-collection)
(with-eval-after-load 'elfeed
  (evil-collection-elfeed-setup))
(with-eval-after-load 'slime
  (evil-collection-slime-setup))
