(use-package rustic
  :config
  (setq
   rustic-format-on-save t
   lsp-ui-sideline-show-code-actions t
   )

)

(add-hook 'rustic-mode-hook
          (lambda ()
             (add-hook 'after-save-hook 'rustic-cargo-test nil 'make-it-local)))

(global-company-mode 1)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rustic-mode))

(use-package company
  :ensure
  :custom
  (company-idle-delay 0.5) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :bind
  (:map company-active-map
	      ("C-n". company-select-next)
	      ("C-p". company-select-previous)
	      ("M-<". company-select-first)
	      ("M->". company-select-last)))

(use-package yasnippet
  :ensure t
  :config
  (yas-reload-all)
  :hook ((lsp-mode . yas-minor-mode)
         (prog-mode-hook . yas-minor-mode)
         (text-mode-hook . yas-minor-mode)))

(use-package flycheck :ensure)

;;; rust-config.el ends here

