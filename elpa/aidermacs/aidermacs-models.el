;;; aidermacs-models.el --- Model selection for aidermacs.el -*- lexical-binding: t; -*-

;;; Commentary:
;; Model selection functionality for aidermacs.el

;;; Code:

(defgroup aidermacs-models nil
  "Model selection customization for aidermacs."
  :group 'aidermacs)

(defcustom aidermacs-popular-models
  '("anthropic/claude-3-5-sonnet-20241022"  ;; really good in practical
    "o3-mini" ;; very powerful
    "gemini/gemini-2.0-flash"  ;; free
    "r1"  ;; performance match o1, price << claude sonnet. weakness: small context
    "deepseek/deepseek-chat"  ;; chatgpt-4o level performance, price is 1/100. weakness: small context
    )
  "List of available AI models for selection.
Each model should be in the format expected by the aidermacs command line interface.
Also based on aidermacs LLM benchmark: https://aidermacs.chat/docs/leaderboards/"
  :type '(repeat string)
  :group 'aidermacs-models)

(defun aidermacs--select-model ()
  "Private function for model selection with completion."
  (completing-read "Select AI model: " aidermacs-popular-models nil t nil nil (car aidermacs-popular-models)))

;;;###autoload
(defun aidermacs-change-model ()
  "Interactively select and change AI model in current aidermacs session."
  (interactive)
  (let ((model (aidermacs--select-model)))
    (when model
      (aidermacs--send-command (format "/model %s" model) t))))

(provide 'aidermacs-models)

;;; aidermacs-models.el ends here
