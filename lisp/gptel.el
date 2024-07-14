;;; gptel.el --- Interact with ChatGPT or other LLMs     -*- lexical-binding: t; -*-
;; -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

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
(setq
 gptel-model "claude-3-5-sonnet-20240620"
 gptel-backend (gptel-make-anthropic "Claude"
                 :stream t :key (decrypt-gpg-api-key "claude")))
