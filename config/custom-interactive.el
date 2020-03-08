(defun other-frame-reverse (arg)
  "Negates arg and sends it to `other-frame'."
  (interactive "p")
  (other-frame (- arg)))

;; https://stackoverflow.com/a/9414763/2856535
(defun copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

;; recompile all github directories

(defun my-byte-recompile-github-subdirectories ()
  "Recompiles all packages and color themes under
  `my-emacs-github-packages-dir'."
  (interactive)
  (let* ((github-packages (concat my-emacs-github-packages-dir "packages/"))
         (github-color-themes (concat my-emacs-github-packages-dir "color-themes/")))
    (if (file-directory-p github-packages)
        (let ((subdirs (append (f-directories github-packages)
                               (f-directories github-color-themes))))
          (cl-labels ((recompile-dirs
                       (as)
                       (unless (null as)
                         (let ((a (car as)))
                           (byte-recompile-directory a 0)
                           (recompile-dirs (cdr as))))))
            (recompile-dirs subdirs))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; quit special buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://stackoverflow.com/a/36551971

(defvar other/help-window-names
  '(
    ;; Ubiquitous help buffers
    "*Help*"
    "*Apropos*"
    "*Messages*"
    "*Completions*"
    ;; Other general buffers
    "*Command History*"
    "*Compile-Log*"
    "*disabled command*"
    ;; Custom buffers
    "*Frames*")
  "Names of buffers that `other/quit-help-windows' should quit.")

(defun other/quit-help-windows (&optional kill frame)
  "Quit all windows with help-like buffers.

Call `quit-windows-on' for every buffer named in
`other/help-windows-name'.  The optional parameters KILL and FRAME
are just as in `quit-windows-on', except FRAME defaults to t (so
that only windows on the selected frame are considered).

Note that a nil value for FRAME cannot be distinguished from an
omitted parameter and will be ignored; use some other value if
you want to quit windows on all frames."
  (interactive)
  (let ((frame (or frame t)))
    (dolist (name other/help-window-names)
      (ignore-errors
        (quit-windows-on name kill frame)))))

(global-set-key (kbd "C-c q") 'other/quit-help-windows)

(provide 'custom-interactive)
