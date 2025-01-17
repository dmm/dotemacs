;;; jinja2-mode-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "jinja2-mode" "jinja2-mode.el" (0 0 0 0))
;;; Generated autoloads from jinja2-mode.el

(autoload 'jinja2-mode "jinja2-mode" "\
Major mode for editing jinja2 files

\(fn)" t nil)

(add-to-list 'auto-mode-alist '("\\.jinja2\\'" . jinja2-mode))

(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))

(register-definition-prefixes "jinja2-mode" '("jinja2-" "sgml-indent-line-num"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8-emacs-unix
;; End:
;;; jinja2-mode-autoloads.el ends here
