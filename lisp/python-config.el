
(require 'python-mode)

;(setq py-shell-name "ipython")
; Add pymacs to PYTHONPATH
(setenv "PYTHONPATH" (concat (getenv "HOME") "/emacs/site-lisp/python-mode/Pymacs/:"
			     (getenv "PYTHONPATH")))
(add-hook 'python-mode-hook
	  (lambda () (setq indent-tabs-mode nil)))
(setq py-indent-offset 4)
(setq py-smart-indentation nil)
;(require 'pymacs)
;(pymacs-load "ropemacs" "rope-")

;; (defadvice py-execute-buffer (around python-keep-focus activate)
;;   "Thie advice to make focus python source code after execute command `py-execute-buffer'."
;;   (let ((remember-window (selected-window))
;;         (remember-point (point)))
;;     ad-do-it
;;     (select-window remember-window)
;;     (goto-char remember-point)))

;; (defun rgr/python-execute()
;;   (interactive)
;;   (if mark-active
;;       (py-execute-string (buffer-substring-no-properties (region-beginning) (region-end)))
;;     (py-execute-buffer)))

;(global-set-key (kbd "C-c C-e") 'rgr/python-execute)

;(add-hook 'python-mode-hook
;          '(lambda () (eldoc-mode 1)) t)

(provide 'python-programming)
