;;;	package --- David's init.el file

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Get SSH_AUTH_SOCK from environment for gpg,magit,tramp,etc
(exec-path-from-shell-initialize)
(let ((rc-ssh-sock-path (concat (getenv "HOME") "/.ssh/ssh_auth_sock")))
  (if (file-readable-p rc-ssh-sock-path)
      (setenv "SSH_AUTH_SOCK" rc-ssh-sock-path)
    (exec-path-from-shell-copy-env "SSH_AUTH_SOCK")))
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


(defun load-tree (path)
  (dolist (fl (files-in-below-directory path))
    (if fl
	(load-file fl))))

;; Load configuration
(load-tree "~/.emacs.d/lisp/")

;; load customizations
(load-file "~/.emacs.d/.custom")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(column-number-mode t)
 '(custom-safe-themes
   '("2e7dc2838b7941ab9cabaa3b6793286e5134f583c04bde2fba2f4e20f2617cf7" "fbf73690320aa26f8daffdd1210ef234ed1b0c59f3d001f342b9c0bbf49f531c" "f019002925408f081e767c515e4fb4b1d7f1462228d6cd32ff66f06a43671527" "aa04c854054e8d43245bd67ca619a7bede9171e2a2efb1b2c26caf1d031497eb" "587ce9a1a961792114991fd488ef9c3fc37f165f6fea8b89d155640e81d165a3" "8a3d04fd24afde8333c1437a3ecaa616f121554041a4e7e48f21b28f13b50246" "0a953c81f5798aa99cafbc4aa8a56d16827442400028f6c1eab0c43061ea331c" "d0dc7861b33d68caa92287d39cf8e8d9bc3764ec9c76bdb8072e87d90546c8a3" "7776ba149258df15039b1f0aba4b180d95069b2589bc7d6570a833f05fdf7b6d" "438f0e2b9fd637c53b20c27c140d2fc14fa154acf9ef92630666cab497c69742" "0dfc663c336d18541ac6925f44e48cb7851f7463d7a3b201b8ae829a4b622501" "64c4ff0a617e6bf33443821525f7feb3ef925a939c4575e77f3811c5b32e72c0" "4d4475c85408bbc9d71e692dd05d55c6b753d64847f5e364d1ebec78d43e2aef" "ddb9bc949afc4ead71a8861e68ad364cd3c512890be51e23a34e4ba5a18b0ade" "3ca84532551daa1b492545bbfa47fd1b726ca951d8be29c60a3214ced30b86f5" "13bf32d92677469e577baa02d654d462f074c115597652c1a3fce6872502bbea" "917d7e7f0483dc90a5e2791db980ce9bc39e109a29198c6e9bdcd3d88a200c33" "8081bc8961e8428dc7897544d6deaa9099b0807e57fc4281187c1bda4ff0c386" "a8a5fd1c8afea56c5943ead67442a652f1f64c8191c257d76988edb0b1ad5dfa" "76c646974f43b321a8fd460a0f5759f916654575da5927d3fd4195029c158018" "9a456f2aac10f18204e8ece27c84950c359f91bb06bda8c711bf4f5095ca8250" "8721f7ee8cd0c2e56d23f757b44c39c249a58c60d33194fe546659dabc69eebd" "72e041c9a2cec227a33e0ac4b3ea751fd4f4039235035894bf18b1c0901e1bd6" "a37d20710ab581792b7c9f8a075fcbb775d4ffa6c8bce9137c84951b1b453016" "33ea268218b70aa106ba51a85fe976bfae9cf6931b18ceaf57159c558bbcd1e6" "a3e99dbdaa138996bb0c9c806bc3c3c6b4fd61d6973b946d750b555af8b7555b" "d8dc153c58354d612b2576fea87fe676a3a5d43bcc71170c62ddde4a1ad9e1fb" default))
 '(display-time-mode t)
 '(global-display-line-numbers-mode t)
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
          (org-agenda-skip-entry-if 'scheduled 'deadline 'regexp "<[^>\12]+>")))
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
   '((116 "* TODO %?\12  %u" "~/todo.org" "Tasks")
     (110 "* %u %?" "~/notes.org" "Notes")))
 '(org-reverse-note-order t)
 '(package-selected-packages
   '(modus-themes cargo-mode ox-rss magit smart-shift jtsx switch-window ef-themes gptel dracula-theme vterm indent-tools quelpa quelpa-use-package ox-hugo flycheck-inline phoenix-dark-pink-theme lsp-ui anti-zenburn-theme hc-zenburn-theme zenburn-theme eglot vagrant-tramp yasnippet ## dash add-node-modules-path prettier poly-ansible jinja2-mode polymode yaml-mode ansible company-lsp rust-mode exec-path-from-shell tide buttercup flycheck-rust))
 '(remember-annotation-functions '(org-remember-annotation))
 '(remember-handler-functions '(org-remember-handler))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
