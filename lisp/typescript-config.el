(require 'prettier-js)

(add-hook 'js2-mode-hook 'prettier-js-mode)
(add-hook 'typescript-mode-hook 'prettier-js-mode)

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

(defun custom-typescript-format()
  "This function organizes imports and formats code on save."
  (interactive)
  (when (bound-and-true-p tide-mode)
    (tide-organize-imports)
    (prettier-prettify)
    )
  )
;; formats the buffer before saving
;(add-hook 'before-save-hook 'custom-typescript-format)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(eval-after-load 'tide-mode
    '(progn
       (add-hook 'web-mode-hook #'add-node-modules-path)
       (add-hook 'web-mode-hook #'prettier-js-mode)))
