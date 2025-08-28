;;; gptel.el --- Interact with ChatGPT or other LLMs     -*- lexical-binding: t; -*-
;; -*- lexical-binding: t -*-

(defun decrypt-gpg-api-key (keyname)
  "Return a lambda that decrypts and returns the API key from a file
identified with KEYNAME. First checks for a plain text file in ~/.authinfo,
then falls back to the encrypted .gpg version. The key is only read once
and then cached for subsequent calls."
  (require 'epg)
  (lexical-let ((cached-key nil)
                (plain-keyfile (f-join "~/authinfo" keyname))
                (gpg-keyfile (f-join "~/authinfo" (concat keyname ".gpg"))))
    (lambda ()
      (unless cached-key
        (setq cached-key
              (cond
               ;; Check for plain text file first
               ((file-exists-p plain-keyfile)
                (with-temp-buffer
                  (insert-file-contents plain-keyfile)
                  (string-trim (buffer-string))))
               ;; Fall back to encrypted file
               ((file-exists-p gpg-keyfile)
                (with-temp-buffer
                  (let ((context (epg-make-context 'OpenPGP)))
                    (insert-file-contents-literally gpg-keyfile)
                    (epg-decrypt-string context (buffer-string)))))
               ;; Neither file exists
               (t (error "No API key file found for %s" keyname)))))
      cached-key)))

(use-package gptel
  ;; :straight (:local-repo "~/.local/share/git/gptel/")
  :commands (gptel gptel-send)
  :hook ((eshell-mode . my/gptel-eshell-keys))
  :bind (("C-c C-<return>" . gptel-menu)
         ("C-c C-x t" . gptel-set-topic))
  :config
  (setq gptel-default-mode 'org-mode)
  (setq gptel-model 'claude-sonnet-4-20250514)
  (setq gptel-backend (gptel-make-anthropic "Claude"
                        :stream t :key (decrypt-gpg-api-key "claude")))
;; :key can be a function that returns the API key.
  (gptel-make-gemini "Gemini" :key (decrypt-gpg-api-key "gemini") :stream t)
  (gptel-make-openai "Cerebras"
    :host "api.cerebras.ai"
    :endpoint "/v1/chat/completions"
    :stream t                             ;optionally nil as Cerebras is instant AI
    :key (decrypt-gpg-api-key "cerebras")                   ;can be a function that returns the key
    :models '(llama3.1-70b
              qwen-3-235b-a22b))
  (gptel-make-openai "NovitaAI"
    :host "api.novita.ai"
    :endpoint "/v3/openai/chat/completions"
    :key (decrypt-gpg-api-key "novita")
    :stream t
    :models '(;; has many more, check https://novita.ai/llm-api
              moonshotai/kimi-k2-instruct
              mistralai/Mixtral-8x7B-Instruct-v0.1
              meta-llama/llama-3-70b-instruct
              qwen/qwen3-coder-480b-a35b-instruct
              deepseek/deepseek-r1)))

