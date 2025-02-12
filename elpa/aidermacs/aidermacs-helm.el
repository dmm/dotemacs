;;; aidermacs-helm.el --- Helm completion for aidermacs.el -*- lexical-binding: t; -*-

;; Author: Mingde (Matthew) Zeng <matthewzmd@posteo.net>
;; Original Author: Kang Tu <tninja@gmail.com>
;; Version: 0.2.0
;; Package-Requires: ((emacs "25.1") (helm "3.0"))
;; Keywords: convenience, tools
;; URL: https://github.com/MatthewZMD/aidermacs.el

;;; Commentary:
;; Optional Helm completion interface for aidermacs.el
;; To use this, ensure both aidermacs.el and helm are installed.

;;; Code:

(require 'helm)
(require 'cl-lib)  ; For `cl-subseq`

(defun aidermacs-helm-read-string-with-history (prompt history-file-name &optional initial-input)
  "Read a string with Helm completion using specified history file.
PROMPT is the prompt string.
HISTORY-FILE-NAME is the base name for history file.
INITIAL-INPUT is optional initial input string."
  ;; Load history from file
  (let* ((history-file (expand-file-name history-file-name user-emacs-directory))
         (history (when (file-exists-p history-file)
                    (with-temp-buffer
                      (insert-file-contents history-file)
                      (delete-dups (read (buffer-string))))))
         ;; Read input with helm
         (input (helm-comp-read
                 prompt
                 history
                 :must-match nil
                 :name "Helm Read String"
                 :fuzzy t
                 :initial-input initial-input)))
    ;; Add to history if non-empty and save
    (unless (string-empty-p input)
      (push input history)
      (with-temp-file history-file
        (let ((history-entries (cl-subseq history
                                          0 (min (length history)
                                                 10000))))  ; Keep last 10000 entries
          (insert (prin1-to-string history-entries)))))
    input))

(defun aidermacs-helm-read-string (prompt &optional initial-input)
  "Read a string with Helm completion for aidermacs, showing historical inputs.
PROMPT is the prompt string.
INITIAL-INPUT is optional initial input string."
  (aidermacs-helm-read-string-with-history prompt "aidermacs-helm-read-string-history.el" initial-input))

(declare-function aidermacs-read-string "aidermacs")

;;;###autoload
(with-eval-after-load 'aidermacs
  (if (featurep 'helm)
      (defalias 'aidermacs-read-string 'aidermacs-helm-read-string)
    (message "Helm is not available. Please install helm package to use aidermacs-helm features")))

(provide 'aidermacs-helm)
;;; aidermacs-helm.el ends here
