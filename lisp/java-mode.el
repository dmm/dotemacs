;(use-package projectile)
(use-package flycheck)
(use-package yasnippet :config (yas-global-mode))
(use-package lsp-mode :hook ((lsp-mode . lsp-enable-which-key-integration)))
(use-package hydra)
(use-package company)
(use-package lsp-ui)
;(use-package which-key :config (which-key-mode))

(use-package lsp-java
  :config
  (add-hook 'java-ts-mode-hook 'lsp)
  ;; current VSCode defaults
  (setq lsp-java-vmargs '("-XX:+UseParallelGC" "-XX:GCTimeRatio=4" "-XX:AdaptiveSizePolicyWeight=90" "-Dsun.zip.disableMemoryMapping=true" "-Xmx2G" "-Xms100m")))

(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)
;(use-package helm-lsp)
;(use-package helm
;  :config (helm-mode))
(use-package lsp-treemacs)

(add-to-list 'auto-mode-alist '("\\.java\\'" . java-ts-mode))
