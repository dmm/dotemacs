;;; minibuffer-complete-cycle-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "minibuffer-complete-cycle" "minibuffer-complete-cycle.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from minibuffer-complete-cycle.el

(autoload 'mcc-define-keys "minibuffer-complete-cycle" "\
Define extra key bindings in the local keymap.
This has no effect unless the `minibuffer-complete-cycle' option is set.

\(fn)" nil nil)

(add-hook 'minibuffer-setup-hook 'mcc-define-keys)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "minibuffer-complete-cycle" '("minibuffer-complete-" "mcc-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; minibuffer-complete-cycle-autoloads.el ends here
