;;; smtpmail config

(require 'smtpmail)

(setq smtpmail-starttls-credentials '(("smtp.mst.edu" 587 nil nil))
      smtpmail-smtp-server "smtp.mst.edu"
      smtpmail-default-smtp-server "smtp.mst.edu"
      send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-service 587
      smtpmail-auth-credentials '(("smtp.mst.edu"
				   587
				   "dmmyq5"
				   nil)))

(setq user-mail-address "david.mattli@mst.edu")

