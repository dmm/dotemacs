;;; gptel.el --- Interact with ChatGPT or other LLMs     -*- lexical-binding: t; -*-
;; -*- lexical-binding: t -*-

(defun decrypt-gpg-api-key (keyname)
  "Return a lambda that decrypts and returns the API key from a file
identified with KEYNAME. The key is only decrypted once and then
cached for subsequent calls."
  (require 'epg)
  (lexical-let ((cached-key nil)
                (keyfile (f-join "~/authinfo" (concat keyname ".gpg"))))
    (lambda ()
      (unless cached-key
        (setq cached-key
              (with-temp-buffer
                (let ((context (epg-make-context 'OpenPGP)))
                  (insert-file-contents-literally keyfile)
                  (epg-decrypt-string context (buffer-string))))))
      cached-key)))
;(setq
; gptel-model 'claude-3-5-sonnet-20241022
; gptel-backend (gptel-make-anthropic "Claude"
;                 :stream t :key (decrypt-gpg-api-key "claude")))

(use-package gptel
  ;; :straight (:local-repo "~/.local/share/git/gptel/")
  :commands (gptel gptel-send)
  :hook ((eshell-mode . my/gptel-eshell-keys))
  :bind (("C-c C-<return>" . gptel-menu)
         ("C-c <return>" . gptel-send)
         :map gptel-mode-map
         ("C-c C-x t" . gptel-set-topic))
  :config
  (setq gptel-default-mode 'org-mode)
  (setq gptel-model 'claude-3-7-sonnet-20250219)
  (setq gptel-backend (gptel-make-anthropic "Claude"
                        :stream t :key (decrypt-gpg-api-key "claude")))
  (gptel-make-openai "NovitaAI"
    :host "api.novita.ai"
    :endpoint "/v3/openai/chat/completions"
    :key (decrypt-gpg-api-key "novita")
    :stream t
    :models '(;; has many more, check https://novita.ai/llm-api
              mistralai/Mixtral-8x7B-Instruct-v0.1
              meta-llama/llama-3-70b-instruct
              deepseek/deepseek-r1)))

