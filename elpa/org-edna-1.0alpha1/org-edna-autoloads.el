;;; org-edna-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "org-edna" "org-edna.el" (22888 46153 923361
;;;;;;  588000))
;;; Generated autoloads from org-edna.el

(autoload 'org-edna-load "org-edna" "\
Setup the hooks necessary for Org Edna to run.

This means adding to `org-trigger-hook' and `org-blocker-hook'.

\(fn)" t nil)

(autoload 'org-edna-unload "org-edna" "\
Unload Org Edna.

Remove Edna's workers from `org-trigger-hook' and
`org-blocker-hook'.

\(fn)" t nil)

;;;***

;;;### (autoloads nil nil ("org-edna-pkg.el" "org-edna-tests.el")
;;;;;;  (22888 46154 51361 588000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; org-edna-autoloads.el ends here
