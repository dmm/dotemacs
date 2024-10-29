(use-package vterm
  :init
  (setq vterm-always-compile-module t)
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

(defun get-vterm-buffer-clean-names ()
  "Get a list of all vterm buffer names, stripped of *...-vterm* format."
  (seq-uniq
   (mapcar (lambda (name)
             (replace-regexp-in-string "^\\*\\(.+\\)-vterm\\*$" "\\1" name))
           (seq-filter (lambda (name) (string-match-p "^\\*.+-vterm\\*$" name))
                       (mapcar #'buffer-name (buffer-list))))))

(defun create-or-switch-vterm (name)
  "Create a new vterm buffer named *name-vterm* or switch to it if it exists."
  (let ((buffer-name (format "*%s-vterm*" name)))
    (if (get-buffer buffer-name)
        (switch-to-buffer buffer-name)
      (vterm buffer-name))))

(defun create-or-cycle-vterm ()
  "Create a new named vterm buffer or cycle through existing ones.
Requires a non-empty, non-whitespace name for new buffers."
  (interactive)
  (let* ((vterm-clean-names (get-vterm-buffer-clean-names))
         (name (completing-read "Vterm name: "
                                (lambda (string pred action)
                                  (if (eq action 'metadata)
                                      '(metadata (category . vterm-buffer))
                                    (complete-with-action action vterm-clean-names string pred)))
                                (lambda (name)
                                  (or (member name vterm-clean-names)
                                      (and (not (string-empty-p name))
                                           (string-match-p "\\S-" name))))
                                nil nil 'vterm-buffer-history)))
    (if (string-empty-p (string-trim name))
        (message "Please provide name for the vterm buffer.")
      (create-or-switch-vterm name))))

(global-set-key (kbd "C-c v") 'create-or-cycle-vterm)
