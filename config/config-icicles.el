(require 'icicles)

(defun my-icicle-select-window ()
  "Calls `icicle-select-window' with `current-prefix-arg' set to \\='-."
  (interactive)
  (let ((current-prefix-arg  '-))
    (icicle-select-window)))

(global-set-key (kbd "<f5>") 'my-icicle-select-window)
