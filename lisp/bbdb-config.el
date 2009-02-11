(require 'bbdb)
(bbdb-initialize 'gnus 'message 'w3 'sendmail)

(add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
;(bbdb-insinuate-message)
