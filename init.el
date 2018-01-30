(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

; https://www.reddit.com/r/emacs/comments/4fqu0a/automatically_install_packages_on_startup/
;; === CUSTOM CHECK FUNCTION ===
; (defun ensure-package-installed (&rest packages)
;   "Assure every package is installed, ask for installation if it’s not.
;    Return a list of installed packages or nil for every skipped package."
;   (mapcar
;    (lambda (package)
;      (unless (package-installed-p package)
;        (package-install package)))
;      packages)
; )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (slime org htmlize paredit ox-reveal org-plus-contrib org-edna evil-surround solarized-theme linum-relative evil-leader evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun home-directory ()
  "Returns the path to the user's home directory with a slash at the end."
  (file-name-as-directory (getenv "HOME")))

; https://stackoverflow.com/a/37132338/2856535
    ; modified
(defun my-org-inline-css-hook (exporter)
  "Insert custom inline css"
  (when (eq exporter 'html)
    (let* ((dir (ignore-errors (file-name-directory (buffer-file-name))))
           (filename (concat (file-name-base (buffer-file-name)) ".css"))
           (path (concat dir filename))
           (default (or (null dir) (null (file-exists-p path))))
           (default-file (expand-file-name ".emacs.d/org-style.css" (home-directory)))
           (final (if default "~/.emacs.d/org-style.css" path)))
      (setq org-html-head-include-default-style nil)
      (setq org-html-head "")
      (if (file-exists-p final)
        (setq org-html-head (concat
                              "<style type=\"text/css\">\n"
                              "<!--/*--><![CDATA[/*><!--*/\n"
                              (with-temp-buffer
                                (insert-file-contents final)
                                (buffer-string))
                              "/*]]>*/-->\n"
                              "</style>\n"))))))

(defun lbrayner-org-mode-hook ()
      (visual-line-mode)
      (org-indent-mode)
      (setq truncate-lines nil))

; major modes
    ; org
(setq org-export-time-stamp-file nil)
(setq org-html-validation-link nil)
(setq-default org-export-with-author nil)
(setq-default org-export-with-toc nil)
(setq-default org-use-sub-superscripts '{})
(setq-default org-export-with-sub-superscripts '{})
(add-hook 'org-mode-hook 'lbrayner-org-mode-hook)
(add-hook 'org-export-before-processing-hook 'my-org-inline-css-hook)
        ; babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)))


; minor-modes
    ; built-in
        ; linum
	; show-paren-mode
(show-paren-mode 1)
(global-linum-mode 1)
    ; melpa
	; slime
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy))
        ; paredit
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

; themes
    ; melpa
        ; solarized
(setq solarized-use-variable-pitch nil
      solarized-scale-org-headlines nil)
(load-theme 'solarized-dark t)
(setq solarized-high-contrast-mode-line t)

; extensions
    ; melpa
        ; linum-relative
(linum-relative-global-mode)
(setq linum-relative-current-symbol "")
        ; ox-reveal
(require 'ox-reveal)
(setq org-reveal-root "file:///home/desenvolvedor/other/reveal.js-3.3.0")
(setq org-reveal-title-slide "<h1> %t </h1>  <br> %a <br> %e")

(setq default-directory "~/")
(setq blink-cursor-blinks 1)

; menus and scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(add-to-list 'default-frame-alist
     '(vertical-scroll-bars . nil))

; mouse
(mouse-avoidance-mode 'banish)

; mode line
(setq column-number-mode t)

; narrow mode
(put 'narrow-to-region 'disabled nil)

; ispell
(setq ispell-program-name "aspell") 
(setq ispell-complete-word-dict "/usr/local/share/dict/brazilian")

; auto-backup
(setq make-backup-files nil)

; encoding
(set-buffer-file-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)

;; Save all tempfiles in /var/tmp/emacs$UID
(defconst emacs-tmp-dir (expand-file-name (format
                                            "emacs%d"
                                            (user-uid))
                                          "/var/tmp"))
(setq backup-directory-alist `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms `((".*" ,(file-name-as-directory emacs-tmp-dir) t)))
(setq auto-save-list-file-prefix (file-name-as-directory emacs-tmp-dir))

; after
    ; configuration
        ; major-mode
            ; melpa
                ; org-mode
(add-to-list
 'org-publish-project-alist
 '("CV" :html-head-include-scripts nil
   :base-directory "~/Documents/orgmode/CV"
   :publishing-function org-html-publish-to-html
   :publishing-directory "~/Documents/orgmode/CV"))
        ; minor-modes
            ; built-in
                ; linum
(set-face-attribute 'linum nil :height 100)
                ; visual-line-mode
(setq global-visual-line-mode t)

; loading files from config folder

(let* ((config-directory (concat user-emacs-directory "config/"))
       (directory-exists? (file-directory-p config-directory)))
  (if directory-exists?
      (cl-loop for file in (directory-files-recursively config-directory "\\.el$")
			do (condition-case ex
			    (load (file-name-sans-extension file))
			    ('error (with-current-buffer "*scratch*"
				    (insert (format "[INIT ERROR]\n%s\n%s\n\n" file ex))))))))

; custom functions and respective mappings

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
