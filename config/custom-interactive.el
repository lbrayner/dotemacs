;; https://stackoverflow.com/a/9414763/2856535
(defun kill-file-name ()
  "Make the current buffer's file name (when visiting a file) the
latest kill in the kill ring."
  (interactive)
  (let* ((unabbreviated-file-name (if (eq major-mode 'dired-mode)
                                      default-directory
                                    (buffer-file-name)))
         (filename (if unabbreviated-file-name
                       (abbreviate-file-name unabbreviated-file-name))))
    (cond (filename
           (kill-new filename)
           (message "Saved file name '%s' to the kill ring." filename))
          (t (message "Not visiting a file.")))))

;; recompile all github directories

(defun byte-recompile-github-subdirectories ()
  "Recompiles all packages and color themes under
  `emacs-github-packages-dir'."
  (interactive)
  (let* ((github-packages (concat emacs-github-packages-dir "packages/"))
         (github-color-themes (concat emacs-github-packages-dir "color-themes/")))
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

(defvar help-window-names
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
  "Names of buffers that `quit-help-windows' should quit.")

(defun quit-help-windows (&optional kill frame)
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
    (dolist (name help-window-names)
      (ignore-errors
        (quit-windows-on name kill frame)))))

(provide 'custom-interactive)
