(use-package rustic
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-menu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))

  :config
  (setq
   rustic-format-on-save t
   lsp-ui-doc-enable nil
   lsp-ui-sideline-show-code-actions t))

(global-company-mode 1)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rustic-mode))

(use-package company
  :custom
  (company-idle-delay 0.2) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :bind
  (:map company-active-map
	      ("C-n". company-select-next)
	      ("C-p". company-select-previous)
	      ("M-<". company-select-first)
	      ("M->". company-select-last)))

(use-package yasnippet
  :config
  (yas-reload-all)
  :hook ((lsp-mode . yas-minor-mode)
         (prog-mode-hook . yas-minor-mode)
         (text-mode-hook . yas-minor-mode)))

(use-package flycheck :ensure)

;;; rust-config.el ends here
