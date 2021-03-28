(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" default)))
 '(frame-background-mode (quote dark))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (markdown-mode evil-smartparens smartparens auto-dim-other-buffers ace-window haskell-mode f ox-pandoc slime org htmlize ox-reveal org-plus-contrib org-edna evil-surround evil-leader evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; |               |
;; | CONFIGURATION |
;; |               |

    ;; server-socket-dir override
(setq server-socket-dir
      (concat temporary-file-directory
              (format "emacs%d" (user-uid))))
    ;; default-directory
(setq default-directory "~/")
    ;; cursor
(setq blink-cursor-blinks 1)
    ;; menus and scroll bar
(menu-bar-mode -1)
    ;; (toggle-scroll-bar -1)
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(tool-bar-mode -1)
    ;; mouse
(mouse-avoidance-mode 'banish)
    ;; mode line
(setq column-number-mode t)
    ;; narrow mode
(put 'narrow-to-region 'disabled nil)
    ;; ispell
(setq ispell-program-name "aspell")
    ;; auto-backup
(setq make-backup-files nil)
    ;; tabs
(setq-default indent-tabs-mode nil)
(setq tab-stop-list (number-sequence 4 120 4))
    ;; files
(setq delete-old-versions t)
    ;; encoding
(set-buffer-file-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8-unix)
    ;; paren
(show-paren-mode 1)
    ;; autorevert
(global-auto-revert-mode)
(setq auto-revert-check-vc-info t)
    ;; dired
(setq dired-listing-switches "-alh")
(setq dired-isearch-filenames t)
(with-eval-after-load 'dired (require 'dired-x))
(defun dired-mode-setup ()
  "Setup Dired mode."
  (dired-omit-mode 1))
(add-hook 'dired-mode-hook #'dired-mode-setup)
    ;; Display-Line-Numbers mode
(when (version<= "26.0.50" emacs-version)
  (setq display-line-numbers-type 'relative)
  (setq display-line-numbers-width-start t)
  (global-display-line-numbers-mode))
    ;; visual-line-mode
(setq global-visual-line-mode t)
    ;; disabling annoying commands
(put 'view-hello-file 'disabled t)
    ;; highlighting trailing whitespace
(setq-default show-trailing-whitespace t)
(defun no-show-trailing-whitespace ()
  "Set `show-trailing-whitespace' to nil."
  (setq show-trailing-whitespace nil))
(let ((no-show-trailing-whitespace-modes '(slime-repl-mode
                                help-mode
                                eshell-mode
                                shell-mode
                                term-mode)))
  (cl-loop for mode in no-show-trailing-whitespace-modes
           do (let ((hook (concat (symbol-name mode) "-hook")))
                (add-hook (intern hook) #'no-show-trailing-whitespace))))

;; |                             |
;; | MELPA PACKAGE CONFIGURATION |
;; |                             |

    ;; slime
(setq inferior-lisp-program "sbcl")
(setq slime-contribs '(slime-fancy))
    ;; haskell-mode
(defun no-eldoc-documentation-function ()
  "Set `eldoc-documentation-function' to nil."
  (setq show-trailing-whitespace nil))
(add-hook 'haskell-mode-hook #'no-eldoc-documentation-function)
    ;; auto-dim-other-buffers
(auto-dim-other-buffers-mode)
    ;; f
(require 'f)

;; |                 |
;; | GitHub PACKAGES |
;; |                 |

(defun expand-directory-name (name &optional default-directory)
  "Convert directory NAME to absolute, and canonicalize it. See
`expand-file-name'."
  (file-name-as-directory (expand-file-name name default-directory)))

(defvar emacs-github-packages-dir
  (expand-directory-name "github" user-emacs-directory)
  "Where Github packages are stored.")

(let ((github-packages (expand-directory-name "packages" emacs-github-packages-dir))
      (github-color-themes (expand-directory-name "color-themes" emacs-github-packages-dir)))
  (if (file-directory-p github-packages)
      (let ((subdirs (append (f-directories github-packages)
                             (f-directories github-color-themes))))
        (cl-loop for dir in subdirs
                 do (add-to-list 'load-path dir))))
  (if (file-directory-p github-color-themes)
      (cl-loop for dir in (f-directories github-color-themes)
               do (add-to-list 'custom-theme-load-path dir))))

;; |               |
;; | CONFIG FOLDER |
;; |               |

;; loading files from config folder
;; from Bailey Ling's dotemacs

(let ((config-directory (expand-directory-name "config" user-emacs-directory)))
  (if (file-directory-p config-directory)
      (cl-loop for file in (directory-files-recursively config-directory "\\.el$")
               do (condition-case ex
                      (load (file-name-sans-extension file))
                    ('error (with-current-buffer "*scratch*"
                              (insert (format "[INIT ERROR]\n%s\n%s\n\n" file ex))))))))
