(require 'frames)
(global-set-key (kbd "<f8>") #'frames)

(require 'smart-tab)
(global-smart-tab-mode 1)
;; see function `smart-tab-call-completion-function'
(setq smart-tab-using-hippie-expand t)
(setq smart-tab-user-provided-completion-function 'completion-at-point)
(add-to-list 'smart-tab-disabled-major-modes 'slime-repl-mode)
