
(setq typescript-indent-level 2)

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
;(add-hook 'before-save-hook 'tide-format-before-save)
;(add-hook 'before-save-hook 'prettier-prettify)
;; if you use treesitter based typescript-ts-mode (emacs 29+)
(add-hook 'typescript-ts-mode-hook #'lsp-mode)
(add-hook 'typescript-ts-mode-hook #'prettier-mode)

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

(with-eval-after-load 'ng2-html-mode (add-hook 'ng2-html-mode-hook #'lsp))
