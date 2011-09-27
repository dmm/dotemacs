 ;;; Configuration for gnus

(require 'gnus)
(require 'pgg) ;; gpg support



(setq gnus-select-method
      '(nnimap "mattli.us"
		(nnimap-address "mattlimech.com")
		(nnimap-server-port 993)
;		(remove-prefix "INBOX.")
;		(nnimap-authinfo-file "/home/dmm/.imap-authinfo")
		(nnimap-stream tls)
		))

(setq nnimap-expunge-on-close "never")
(setq gnus-permanently-visible-groups "I") ;Always display subscribed groups with e in name ;)


;; verify/decrypt only if mml knows about the protocl used
(setq mm-verify-option 'known)
(setq mm-decrypt-option 'known)

;; Here we make button for the multipart 
(setq gnus-buttonized-mime-types '("multipart/encrypted" "multipart/signed"))

;; Automatically sign when sending mails
(add-hook 'message-send-hook 'mml-secure-message-sign-pgpmime)

;; Enough explicit settings
(setq pgg-passphrase-cache-expiry 300)
;(setq pgg-default-user-id jmh::primary-key)
    

