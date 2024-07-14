;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-smtp-server "imap.mattli.us"
      send-mail-function 'smtpmail-send-it
			message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-servers-requiring-authorization ".*"
)

(setq user-mail-address "dmm@mattli.us")

(setq smtpmail-debug-info t)

(setq starttls-use-gnutls t)
(setq starttls-gnutls-program "gnutls-cli")
(setq starttls-extra-arguments nil)
