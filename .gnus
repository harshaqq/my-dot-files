(require 'nnir)
(setq gnus-select-method
      '(nnimap "gmail"
	       (nnimap-address "imap.gmail.com")  ; it could also be imap.googlemail.com if that's your server.
	       (nnimap-server-port "imaps")
	       (nnir-search-engine imap)
	       (nnimap-stream ssl)))

(setq smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)
(setq gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

(add-hook 'message-mode-hook (lambda ()
			       (flyspell-mode)))

(require 'nnir)

(setq epa-file-cache-passphrase-for-symmetric-encryption t)

(setq gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date
				   (not gnus-thread-sort-by-number)))

(setq gnus-use-cache t)

(setq gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)
(setq gnus-thread-hide-subtree t)
(setq gnus-thread-ignore-subject t)
(setq gnus-use-correct-string-widths nil)
