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
    (htmlize paredit ox-reveal org-plus-contrib org-edna evil-surround solarized-theme linum-relative evil-leader evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; major modes
    ; org
(setq org-export-time-stamp-file nil)
(setq org-html-validation-link nil)
(setq-default org-export-with-author nil)
(setq-default org-export-with-toc nil)
(setq-default org-use-sub-superscripts '{})
(setq-default org-export-with-sub-superscripts '{})

; minor-modes
    ; built-in
        ; linum
(global-linum-mode 1)
    ; melpa
        ; evil
(evil-mode t)
(global-evil-leader-mode)
(setq evil-want-Y-yank-to-eol nil)
            ; custom bindings
(define-key evil-motion-state-map "ç" 'evil-ex)
(define-key evil-visual-state-map "ç" 'evil-ex)
(define-key evil-motion-state-map "¬" 'evil-first-non-blank)
(define-key evil-motion-state-map (kbd "<f6>") 'evil-write)
(define-key evil-motion-state-map (kbd "<f5>") 'list-buffers)
(define-key evil-insert-state-map "\C-u" '(lambda () (interactive) (kill-line 0)))
(define-key evil-insert-state-map (kbd "<f6>") '(lambda () (interactive)
                                                  (evil-normal-state) (save-buffer)))
        ; evil-surround
(global-evil-surround-mode 1)
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

; mode line
(setq column-number-mode t)

; narrow mode
(put 'narrow-to-region 'disabled nil)

; ispell
(setq ispell-program-name "aspell") 
(setq ispell-complete-word-dict "/usr/local/share/dict/brazilian")

; auto-backup
(setq make-backup-files nil)

;; Save all tempfiles in /var/tmp/emacs$UID
(defconst emacs-tmp-dir (expand-file-name (format "emacs%d/" (user-uid)) "/var/tmp"))
(setq backup-directory-alist `((".*" . ,emacs-tmp-dir)))
(setq auto-save-file-name-transforms `((".*" ,emacs-tmp-dir t)))
(setq auto-save-list-file-prefix emacs-tmp-dir)

; after
    ; configuration
        ; minor-modes
            ; built-in
                ; linum
(set-face-attribute 'linum nil :height 100)
