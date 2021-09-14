;;;	package --- David's .emacs file. This loads up lots of libraries ;).

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Get SSH_AUTH_SOCK from environment
(exec-path-from-shell-copy-env "SSH_AUTH_SOCK")
(exec-path-from-shell-copy-env "PATH")

;; Some helpful functions

(defun files-in-below-directory (directory)
  "List the .el files in DIRECTORY and in its sub-directories."
  ;; Although the function will be used non-interactively,
  ;; it will be easier to test if we make it interactive.
  ;; The directory will have a name such as
  ;;  "/usr/local/share/emacs/21.0.100/lisp/"
  (interactive "DDirectory name: ")
  (let (el-files-list
	      (current-directory-list
	       (directory-files-and-attributes directory t)))
    ;; while we are in the current directory
    (while current-directory-list
      (cond
       ;; check to see whether filename ends in `.el'
       ;; and if so, append its name to a list.
       ((equal ".el" (substring (car (car current-directory-list)) -3))
	      (setq el-files-list
	            (cons (car (car current-directory-list)) el-files-list)))
       ;; check whether filename is that of a directoryx
       ((eq t (car (cdr (car current-directory-list))))
	      ;; decide whether to skip or recurse
	      (if
	          (equal "."
		               (substring (car (car current-directory-list)) -1))
	          ;; then do nothing since filename is that of
	          ;;   current directory or parent, "." or ".."
	          ()
	        ;; else descend into the directory and repeat the process
	        (setq el-files-list
		            (append
		             (files-in-below-directory
		              (car (car current-directory-list)))
		             el-files-list)))))
      ;; move to the next filename in the list; this also
      ;; shortens the list so the while loop eventually comes to an end
      (setq current-directory-list (cdr current-directory-list)))
    ;; return the filenames
    el-files-list))


(defun fill-load-path (path)
  (dolist (file (files-in-below-directory path))
    (if file
	(add-to-list 'load-path
		     (file-name-directory file)))))

(defun load-tree (path)
  (dolist (fl (files-in-below-directory path))
    (if fl
	(load-file fl))))

;; Fill load-path
(fill-load-path "~/.emacs.d/lisp/")

;; Load configuration
(load-tree "~/.emacs.d/lisp/")


;; load customizations
(load-file "~/.emacs.d/.custom")


;; load info manuals
(setq Info-default-directory-list
      (cons "~/books" Info-default-directory-list))

;; Start emacs server
(server-start)
;;misc
(global-font-lock-mode t)

;; yesssssss
(shell)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(custom-safe-themes
   '("d8dc153c58354d612b2576fea87fe676a3a5d43bcc71170c62ddde4a1ad9e1fb" default))
 '(org-agenda-custom-commands
   '(("d" todo "DELEGATED" nil)
     ("c" todo "DONE|DEFERRED|CANCELLED" nil)
     ("w" todo "WAITING" nil)
     ("W" agenda ""
      ((org-agenda-ndays 21)))
     ("A" agenda ""
      ((org-agenda-skip-function
        (lambda nil
          (org-agenda-skip-entry-if 'notregexp "\\=.*\\[#A\\]")))
       (org-agenda-ndays 1)
       (org-agenda-overriding-header "Today's Priority #A tasks: ")))
     ("u" alltodo ""
      ((org-agenda-skip-function
        (lambda nil
          (org-agenda-skip-entry-if 'scheduled 'deadline 'regexp "<[^>
]+>")))
       (org-agenda-overriding-header "Unscheduled TODO entries: ")))))
 '(org-agenda-files '("~/todo.org"))
 '(org-agenda-include-diary t)
 '(org-agenda-ndays 7)
 '(org-agenda-show-all-dates t)
 '(org-agenda-skip-deadline-if-done t)
 '(org-agenda-skip-scheduled-if-done t)
 '(org-agenda-start-on-weekday nil)
 '(org-deadline-warning-days 14)
 '(org-default-notes-file "~/notes.org")
 '(org-fast-tag-selection-single-key 'expert)
 '(org-remember-store-without-prompt t)
 '(org-remember-templates
   '((116 "* TODO %?
  %u" "~/todo.org" "Tasks")
     (110 "* %u %?" "~/notes.org" "Notes")))
 '(org-reverse-note-order t)
 '(package-selected-packages
   '(## dash use-package rustic org2blog add-node-modules-path prettier typescript-mode dockerfile-mode magit poly-ansible jinja2-mode polymode yaml-mode ansible company-lsp lsp-mode cargo rust-mode exec-path-from-shell tide buttercup flycheck-rust))
 '(remember-annotation-functions '(org-remember-annotation))
 '(remember-handler-functions '(org-remember-handler)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
