(require 'icicles)

(defun my-icicle-select-window (win-name &optional window-alist)
  "Calls `icicle-read-choose-window-args' with `current-prefix-arg'
set to \\='- and then selects window via
`icicle-choose-window-by-name'."
  (interactive (let ((current-prefix-arg  '-))
                 (icicle-read-choose-window-args)))
  (icicle-choose-window-by-name win-name window-alist))

(global-set-key (kbd "<f5>") 'my-icicle-select-window)
