(require 'cl-lib)
(require 'subr-x)
(require 'ghostel)

(defun my-ghostel-buffer-setup ()
  (display-line-numbers-mode -1)
  (setq-local show-trailing-whitespace nil))

(add-hook 'ghostel-mode-hook #'my-ghostel-buffer-setup)

(defvar-local my-ghostel-session-name nil
  "Stable user-assigned name for this Ghostel session.")

(defun my-ghostel-sessions ()
  "Return an alist of named Ghostel sessions.

Each element has the form (SESSION-NAME . BUFFER)."
  (cl-loop for buffer in (buffer-list)
           when (buffer-live-p buffer)
           for name = (buffer-local-value
                       'my-ghostel-session-name buffer)
           when (and name
                     (with-current-buffer buffer
                       (derived-mode-p 'ghostel-mode)))
           collect (cons name buffer)))

(defun my-ghostel-session-buffer (name)
  "Return the Ghostel session buffer named NAME, or nil."
  (cdr (assoc-string name (my-ghostel-sessions))))

(defun my-create-ghostel-session (name)
  "Create and return a Ghostel session named NAME."
  (let ((ghostel-buffer-name (format "*ghostel:%s*" name))
        (ghostel-buffer-name-function nil))
    (let ((buffer (ghostel)))
      (with-current-buffer buffer
        (setq-local my-ghostel-session-name name))
      buffer)))

(defun my-create-or-switch-ghostel (name)
  "Switch to the Ghostel session NAME, creating it if necessary."
  (if-let ((buffer (my-ghostel-session-buffer name)))
      (pop-to-buffer buffer)
    (my-create-ghostel-session name)))

(defun create-or-cycle-ghostel ()
  "Create a named Ghostel session or switch to an existing one."
  (interactive)
  (let* ((sessions (my-ghostel-sessions))
         (names (mapcar #'car sessions))
         (name
          (completing-read
           "Ghostel name: "
           (lambda (string pred action)
             (if (eq action 'metadata)
                 '(metadata (category . ghostel-session))
               (complete-with-action action names string pred)))
           (lambda (candidate)
             (or (member candidate names)
                 (string-match-p "\\S-" candidate)))
           nil nil 'ghostel-session-history)))
    (setq name (string-trim name))
    (if (string-empty-p name)
        (user-error "Session name cannot be empty")
      (my-create-or-switch-ghostel name))))


(global-set-key (kbd "C-c v") 'create-or-cycle-ghostel)
