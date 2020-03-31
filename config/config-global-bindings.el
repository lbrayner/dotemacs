(global-set-key (kbd "C-x C-b") #'ibuffer)

(defun other-frame-reverse (arg)
  "Negates arg and sends it to `other-frame'."
  (interactive "p")
  (other-frame (- arg)))

(global-set-key (kbd "C-.") #'other-frame)
(global-set-key (kbd "C-,") #'other-frame-reverse)

;; windmove on hold (in favor of paredit) till I find a suitable modifier
;; (windmove-default-keybindings)

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
(global-set-key (kbd "C-c <") #'my-move-to-window-line-top)
(global-set-key (kbd "C-c >") #'my-move-to-window-line-bottom)

;; hippie-expand
(global-set-key (kbd "M-/") 'hippie-expand)

;; modifying the order of hippie-expand-try-functions-list
(cl-labels
    ((add-to-last (item list)
                  "Adds ITEM to the end of LIST uniquely. No side effects."
                  (append (remq item list) (list item)))
     (add-all-to-last (items list)
                      "Applies `add-to-last' to the first item in
ITEMS and LIST; and then to the second and the resulting list and so on."
                      (if (null items)
                          list
                        (add-all-to-last (cdr items) (add-to-last (car items) list)))))
  (setq hippie-expand-try-functions-list
        (add-all-to-last '(try-expand-list
                           try-expand-line
                           try-complete-file-name-partially
                           try-complete-file-name)
                         hippie-expand-try-functions-list)))

(defconst my-hippie-expand-try-functions-list
  (remq 'try-expand-list (remq 'try-expand-line hippie-expand-try-functions-list))
  "A limited set of try functions for `hippie-expand'.")

(add-hook 'paredit-mode-hook (lambda ()
                               (setq-local hippie-expand-try-functions-list
                                           my-hippie-expand-try-functions-list)))

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
         (dired-next-line 2))))

(advice-add #'beginning-of-buffer :after #'my-beginning-of-buffer-dwim)
