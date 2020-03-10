    ;; FRAMES
(require 'frames)
(global-set-key (kbd "<f8>") #'frames)

    ;; ICICLES
(require 'icicles)

(defun my-icicle-select-window (win-name &optional window-alist)
  "Calls `icicle-read-choose-window-args' with `current-prefix-arg'
set to \\='- and then selects window via
`icicle-choose-window-by-name'."
  (interactive (let ((current-prefix-arg (cond ((display-graphic-p) '-)
                                               (t nil))))
                 (icicle-read-choose-window-args)))
  (icicle-choose-window-by-name win-name window-alist))

(global-set-key (kbd "<f5>") 'my-icicle-select-window)

    ;; SMART-TAB
(require 'smart-tab)
(global-smart-tab-mode 1)
;; see function `smart-tab-call-completion-function'
(setq smart-tab-using-hippie-expand t)
(setq smart-tab-user-provided-completion-function 'completion-at-point)
(add-to-list 'smart-tab-disabled-major-modes 'slime-repl-mode)

    ;; ACE-WINDOW
(global-set-key (kbd "<f10>") 'ace-window)