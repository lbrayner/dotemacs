(global-set-key (kbd "C-.") #'other-frame)

(with-eval-after-load 'custom-interactive
  (global-set-key (kbd "C-,") #'other-frame-reverse))

(global-set-key (kbd "C-x C-b") #'ibuffer)

(windmove-default-keybindings)

(global-set-key (kbd "<f12>") #'whitespace-mode)
