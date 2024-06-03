(use-package vterm
  :config
  (define-key vterm-mode-map (kbd "<f1>") nil)
  (define-key vterm-mode-map (kbd "<f2>") nil)
  (define-key vterm-mode-map (kbd "<f3>") nil)
  (define-key vterm-mode-map (kbd "<f4>") nil)
  (define-key vterm-mode-map (kbd "<f5>") nil)
  (define-key vterm-mode-map (kbd "<f6>") nil)
  (define-key vterm-mode-map (kbd "<f7>") nil)
  (define-key vterm-mode-map (kbd "<f8>") nil)
  (define-key vterm-mode-map (kbd "<f9>") nil)
  (define-key vterm-mode-map (kbd "<f10>") nil)
  (define-key vterm-mode-map (kbd "<f11>") nil)
  (define-key vterm-mode-map (kbd "<f12>") nil)

  :hook
  (vterm-mode . goto-address-mode))

(defun create-named-vterm (name)
  "Create a new vterm buffer named *name-vterm*. If the buffer already exists, switch to it."
  (interactive "sEnter name for vterm buffer: ")
  (let ((buffer-name (format "*%s-vterm*" name)))
    (if (get-buffer buffer-name)
        (switch-to-buffer buffer-name)
      (vterm buffer-name))))

(global-set-key (kbd "C-c v") 'create-named-vterm)
