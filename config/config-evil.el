(evil-mode t)
(global-evil-leader-mode)
(setq evil-want-Y-yank-to-eol nil)
(setq evil-search-module 'evil-search)

        ;; evil-surround
(global-evil-surround-mode 1)

;; custom bindings

(defun my-evil-normal-eval-print-last-sexp ()
  "`eval-print-last-sexp' adjusted for Evil's normal mode."
  (interactive)
  (evil-append 1) (eval-print-last-sexp) (evil-normal-state) (message nil))

(defun my-evil-eval-print-define-keys (map)
  (evil-define-key 'normal map (kbd "C-c j") #'my-evil-normal-eval-print-last-sexp)
  (evil-define-key 'insert map (kbd "C-c j") #'eval-print-last-sexp))

(defun my-evil-paredit-define-keys (map)
  (evil-define-key 'insert map (kbd "ESC <left>") #'paredit-backward-barf-sexp)
  (evil-define-key 'insert map (kbd "ESC <right>") #'paredit-backward-barf-sexp)
  (evil-define-key 'insert map (kbd "<M-left>") #'paredit-backward-barf-sexp)
  (evil-define-key 'insert map (kbd "<M-right>") #'paredit-backward-barf-sexp)
  (evil-define-key 'insert map (kbd "<S-left>") #'paredit-backward-slurp-sexp)
  (evil-define-key 'insert map (kbd "<S-right>") #'paredit-forward-slurp-sexp))

(with-eval-after-load 'paredit
  (let ((lisp-modes '(lisp-mode
                      lisp-interaction-mode
                      emacs-lisp-mode)))
    (cl-labels
        ((evil-define-paredit
          (modes)
          (unless (null modes)
            (let* ((mode (car modes))
                   (map (concat (symbol-name mode) "-map")))
              (my-evil-eval-print-define-keys (symbol-value (intern map)))
              (my-evil-paredit-define-keys (symbol-value (intern map)))
              (evil-define-paredit (cdr modes))))))
      (evil-define-paredit lisp-modes))))

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

;; Tim Pope's vim-commentary-like functionality

(evil-define-command my-evil-comment (beg end)
  "Comment text from BEG to END."
  (interactive "<r>")
  (cond
   ((= (count-lines beg end) 1)
    (save-excursion
      (comment-line 1)))
   (t
    (activate-mark)
    (comment-or-uncomment-region beg end))))

;; Makes `g' a prefix key in evil-normal-state-map
(define-key evil-normal-state-map "g" nil)
(define-key evil-normal-state-map "gc" #'my-evil-comment)

(define-key evil-visual-state-map "gc" #'my-evil-comment)

(defun evil-unimpaired-open-line (n)
  "Performs Tim Pope's unimpaired ]<Space>."
  (interactive "p")
  (save-excursion
    (move-end-of-line 1)
    (open-line n)))

(defun evil-unimpaired-open-line-above (n)
  "Performs Tim Pope's unimpaired [<Space>."
  (interactive "p")
  (cond ((bolp)
         (open-line n)
         (forward-line n))
        (t (save-excursion
             (move-beginning-of-line 1)
             (open-line n)))))

(define-key evil-normal-state-map "] " #'evil-unimpaired-open-line)
(define-key evil-normal-state-map "[ " #'evil-unimpaired-open-line-above)

;; https://github.com/emacs-evil/evil-collection

;;; evil-collection has too many features for my current needs
;;; (i.e. it's bloated).

(defun evil-collection-slime-last-sexp (command &rest args)
  "In normal-state or motion-state, last sexp ends at point."
  (if (and (not evil-move-beyond-eol)
           (or (evil-normal-state-p) (evil-motion-state-p)))
      (save-excursion
        (unless (or (eobp) (eolp)) (forward-char))
        (apply command args))
(apply command args)))

(defun evil-collection-slime-setup ()
  "Set up `evil' bindings for `slime'."
  (unless evil-move-beyond-eol
    (advice-add 'slime-eval-last-expression :around 'evil-collection-slime-last-sexp)
    (advice-add 'slime-pprint-eval-last-expression :around 'evil-collection-slime-last-sexp)
    (advice-add 'slime-eval-print-last-expression :around 'evil-collection-slime-last-sexp)
    (advice-add 'slime-eval-last-expression-in-repl
                :around 'evil-collection-slime-last-sexp)))

(defun evil-collection-setup ()
  "Sets up evil-collection bindings."
  (evil-collection-slime-setup))

(with-eval-after-load 'slime
  (evil-collection-setup))

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
