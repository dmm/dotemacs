;;============================================================
;; iswitchb
;;============================================================
(require 'iswitchb)  
(iswitchb-mode 1)
;;============================================================
;; iswitchb ignores
;;============================================================
(add-to-list 'iswitchb-buffer-ignore "^ ")
(add-to-list 'iswitchb-buffer-ignore "*Messages*")
(add-to-list 'iswitchb-buffer-ignore "*ECB")
(add-to-list 'iswitchb-buffer-ignore "*Buffer")
(add-to-list 'iswitchb-buffer-ignore "*Completions")
(add-to-list 'iswitchb-buffer-ignore "*ftp ")
(add-to-list 'iswitchb-buffer-ignore "*bsh")
(add-to-list 'iswitchb-buffer-ignore "*jde-log")
(add-to-list 'iswitchb-buffer-ignore "^[tT][aA][gG][sS]$")
;;============================================================
;; iswitchb-fc
;;============================================================
(require 'filecache)
(load "iswitchb-fc")