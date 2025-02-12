(defun update-aidermacs () (package-vc-install
                            '(aidermacs :url "https://github.com/MatthewZMD/aidermacs.git")))

(use-package aidermacs
  :config
  (setq aidermacs-backend 'vterm)
  (global-set-key (kbd "C-c a") 'aidermacs-transient-menu))
