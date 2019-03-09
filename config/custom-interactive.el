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

;; https://stackoverflow.com/a/22460428/2856535
(defun buffer-mode (&optional buffer-or-name)
  "Returns the major mode associated with a buffer.
If buffer-or-name is nil return current buffer's mode."
  (interactive)
  (message "%s"
           (buffer-local-value
            'major-mode
            (if buffer-or-name (get-buffer buffer-or-name) (current-buffer)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; insert file name at point                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://www.emacswiki.org/emacs/InsertFileName
(defun bjm/insert-file-name (filename &optional args)
  "Insert name of file FILENAME into buffer after point.

  Prefixed with \\[universal-argument], expand the file name to
  its fully canocalized path.  See `expand-file-name'.

  Prefixed with \\[negative-argument], use relative path to file
  name from current directory, `default-directory'.  See
  `file-relative-name'.

  The default with no prefix is to insert the file name exactly as
  it appears in the minibuffer prompt."
  ;; Based on insert-file in Emacs -- ashawley 20080926
  (interactive "*fInsert file name: \nP")
  (cond ((eq '- args)
        (insert (expand-file-name filename)))
        ((not (null args))
         (insert (file-relative-name filename)))
        (t
         (insert filename))))

;; bind it
(global-set-key (kbd "C-c b i") 'bjm/insert-file-name)

;; recompile all github directories

(defun my-byte-recompile-github-subdirectories ()
  "Recompiles all subdirectories under
  `my-emacs-github-packages-dir'."
  (interactive)
  (let* ((github-directory my-emacs-github-packages-dir)
         (directory-exists? (file-directory-p github-directory)))
    (if directory-exists?
        (let ((subdirs (f-directories github-directory)))
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
