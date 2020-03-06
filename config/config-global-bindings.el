(global-set-key (kbd "C-.") #'other-frame)

(with-eval-after-load 'custom-interactive
  (global-set-key (kbd "C-,") #'other-frame-reverse))

(global-set-key (kbd "C-x C-b") #'ibuffer)

(windmove-default-keybindings)

(global-set-key (kbd "<f12>") #'whitespace-mode)

;; scroll up and down one line
(global-set-key (kbd "ESC <down>") #'scroll-up-line)
(global-set-key (kbd "ESC <up>") #'scroll-down-line) 
(global-set-key (kbd "<M-down>") #'scroll-up-line)
(global-set-key (kbd "<M-up>") #'scroll-down-line) 

(defun my-move-to-window-line-top ()
  "Position point at the top of the window."
  (interactive)
  (move-to-window-line 0))

(defun my-move-to-window-line-bottom ()
  "Position point at the bottom of the window."
  (interactive)
  (move-to-window-line -1))

;; point at top or bottom of screen
(global-set-key (kbd "<C-home>") #'my-move-to-window-line-top)
(global-set-key (kbd "<C-end>") #'my-move-to-window-line-bottom)

;; hippie-expand
(global-set-key (kbd "M-/") 'hippie-expand)

;; https://emacs.stackexchange.com/a/31649
;; Advise end-of-buffer to just go up a line if it leaves you on an empty line
(defun my-end-of-buffer-dwim (&rest _)
  "If current line is empty, call `previous-line'."
  (when (looking-at-p "^$")
    (cond ((eq major-mode 'dired-mode)
           (dired-previous-line 1))
          (t (previous-line)))))

(advice-add #'end-of-buffer :after #'my-end-of-buffer-dwim)

(defun my-beginning-of-buffer-dwim (&rest _)
  "Commands run after `beginning-of-buffer' depending on the value of `major-mode'."
  (cond ((eq major-mode 'dired-mode)
           (dired-next-dirline 1))))

(advice-add #'beginning-of-buffer :after #'my-beginning-of-buffer-dwim)
