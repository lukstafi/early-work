;;; pmwiki-mode.el --- edit PmWiki pages within Emacs
;;
;; Copyright (C) 2003  Christian Ridderström, 2007 Lukasz Stafiniak
;;
;; Authors:  Christian Ridderström <christian.ridderstrom@home.se>, Lukasz Stafiniak <lukstafi@gmail.com>
;; Maintainer: Lukasz Stafiniak <lukstafi@gmail.com>
;; Release: $Name:  $
;; Revision: $Revision: 1.50 $
;; Keywords: hypermedia
;; URI: http://www.pmwiki.org/wiki/EmacsModes/Pmwiki-mode
;; 
;;
;; This file is not part of GNU Emacs.
;;
;;; License:
;;
;; This is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; Background:
;;
;; I've rewritten `pmwiki-mode' to work on articles on my homepage.
;; [lukstafi]
;;
;; `pmwiki-mode' was created because in order to easily edit wiki
;; pages at http://wiki.lyx.org (also see http://www.lyx.org). This
;; site the wiki engine PmWiki (see http://www.pmwiki.org/wiki).
;;
;; `pmwiki-mode' is based on the source of `simple-wiki-mode', i.e.
;; 	simple-emacswiki.el, simple-wiki-edit.el and simple-wiki.el.
;; `simple-wiki-mode' was written by Alex Schroeder <alex@gnu.org>
;; (see http://www.emacswiki.org/cgi-bin/wiki.pl/SimpleWikiEditMode).
;;
;;
;; Requirements:
;;
;; This file has been tested with Emacs 22.
;;
;; In addition, this package is useful:
;;	`longlines'	http://www.emacswiki.org/cgi-bin/wiki.pl/LongLines
;;
;; If you downloaded this file as a tar.gz-file, you should already
;; have these packages. Note that the version of `longlines' in the
;; archive has been patched --- this line has been added to the end:
;;	(provide 'longlines)
;; When you have `mmm-mode' installed, some submode support is added.
;;
;; Installation and basic customization:
;;
;; 1. Assuming that this file is located in the directory
;;
;;	~/emacs/pmwiki-mode/
;;
;;    add these lines to your .emacs-file:
;;
;;	(add-to-list 'load-path "~/emacs/pmwiki-mode")
;;	(require 'pmwiki-mode)
;;
;; 2. If you want `preview-latex' to work, copy the "preamble.tex" file,
;;    or your own LaTeX file, to your _home directory_, and add this line
;;    to your .emacs-file:
;;
;;    (setq pmwiki-TeX-master-file "~/preamble.tex")
;;
;;    where "~/preamble.tex" is the path to your preamble file
;;    (tested under Linux only).
;;
;; 3. To use `mywiki-open' and `mywiki-save-as' commands, add:
;;
;;    (setq pmwiki-main-wiki-base-uri
;;       "http://your.path.to/WikiEngine")
;;    (setq pmwiki-main-homepage-uri
;;        (concat pmwiki-main-wiki-base-uri "?n=Main.HomePage"))
;;
;;    replace "http://your.path.to/WikiEngine" with your wiki base URI.
;;
;; 4. If you have `mmm-mode' and use SourceBlock recipe, add the lines
;;
;;    (pmwiki-multi-source "lisp" 'emacs-lisp-mode 'pmwiki-elisp-submode ?l)
;;
;;    customized for languages you use (optional ?l is a key to use with
;;    [C-c %], 'pmwiki-elisp-mode is arbitrary symbol to name the submode).
;;
;; 5. Optionally, use the command `byte-compile' to compile this file.
;; 6. Restart Emacs.
;;
;;
;; Usage:
;;
;; Two examples to get you started:
;; * Use the command `pmwiki-open' with the argument
;;	Main.WikiSandbox
;;   to download the page Main.WikiSandbox from the PmWiki wiki.
;;
;; * Use the command `pmwiki-open' to open a page by specifying
;;   its URI. For example, to open the page where this mode is
;;   described, give the following URI as argument to the command:
;;
;;	http://www.pmwiki.org/wiki/Cookbook/EmacsPmWikiMode
;;
;; Note:
;; * Do not try to use `pmwiki-mode' to edit a page. 
;;   You must use `pmwiki-open' instead.
;;
;; Enjoy. /Christian, /Lukasz
;;
;;
;; Configuration options:
;;
;; Note that the code below is meant to be inserted in .emacs (or an
;; equivalent file).
;; 
;; If you want to use any of the configuration examples below, first
;; insert this line of code:
;;
;;	(defvar pmwiki-mode-hooks)
;;
;; If your auto-fill-mode is usually on, you might want to turn it off:
;;
;;	(add-hook 'pmwiki-mode-hooks 'turn-off-auto-fill)
;;	
;;
;; Also consider using the package longlines.el, for details see
;;   http://www.emacswiki.org/cgi-bin/wiki.pl/LongLines 
;;
;; 	(add-hook 'pmwiki-mode-hooks
;;	  'pmwiki-delayed-hook-longlines-mode-on)
;;	(add-hook 'pmwiki-save-before-hooks 'longlines-mode-off)
;;
;; in which case, also customize `pmwiki-fill-column' back to 70.
;; Note that you may have to patch the file longlines.el by adding
;; 	(provide 'longlines)
;; to the end of it. As an alternative configuration, this code also
;; makes the `longlines-mode' show the hard newlines.
;;
;; 	(add-hook 'pmwiki-mode-hooks
;;	  'pmwiki-delayed-hook-longlines-mode-showing-hard-newlines)
;;	(add-hook 'pmwiki-save-before-hooks 'longlines-mode-off)
;;
;; Note: PmWiki supports using '\' as line continuation character,
;; i.e. if it is the the last character on the line the linebreak is
;; ignored. This is not supported.
;;
;; !!!Author name
;;
;; The name of the author who modified the page is set through the
;; variable `pmwiki-author'. To configure this, either customize the
;; variable or set it from the your initialization script like this:
;;
;;	(set 'pmwiki-author "chr")
;;
;; !!!File extension for PmWiki-files
;;
;; (add-to-list 'auto-mode-alist '("\\.pmwiki\\'" . pmwiki-mode))
;;

;;; Code:
;; Are we running XEmacs or Emacs?
(defvar pmwiki-running-xemacs (string-match "XEmacs\\|Lucid" emacs-version)
  "Indicates if XEmacs (t) or Emacs (nil) is used")
(defvar pmwiki-running-emacs (not pmwiki-running-xemacs)
  "Indicates if Emacs (t) or XEmacs (nil) is used")
(defvar pmwiki-running-emacs-22 (and pmwiki-running-emacs
				     (<= 22 emacs-major-version))
  "Indicates if Emacs (t) or XEmacs (nil) is used")

;; Define helper macro for defining functions that might already exist
(defmacro pmwiki-defun-when-void (&rest args)
  "Define a function, just like `defun', unless it's already defined.
Used for compatibility among different emacs variants."
  `(if (fboundp ',(car args))
       nil
     (defun ,@args)))

(require 'thingatpt)
(require 'cl)				; Defines caddr etc
(require 'easymenu)
(if pmwiki-running-xemacs
    (require 'mule))	     ; Defines encode-coding-string for xemacs

;;
;; Fix required for XEmacs prior to 21.5

(pmwiki-defun-when-void
 replace-regexp-in-string (regexp rep string &optional
				  fixedcase literal subexp start)
"Replace all matches for REGEXP with REP in STRING.
Return a new string containing the replacements.
Optional arguments FIXEDCASE, LITERAL and SUBEXP are like the
arguments with the same names of function `replace-match'.  If START
is non-nil, start replacements at that index in STRING.
REP is either a string used as the NEWTEXT arg of `replace-match' or a
function.  If it is a function it is applied to each match to generate
the replacement passed to `replace-match'; the match-data at this
point are such that match 0 is the function's argument.
To replace only the first match (if any), make REGEXP match up to \\'
and replace a sub-expression, e.g.
  (replace-regexp-in-string \"\\(foo\\).*\\'\" \"bar\" \" foo foo\" nil nil 1)
    => \" bar foo\"
"
  ;; To avoid excessive consing from multiple matches in long strings,
  ;; don't just call `replace-match' continually.  Walk down the
  ;; string looking for matches of REGEXP and building up a (reversed)
  ;; list MATCHES.  This comprises segments of STRING which weren't
  ;; matched interspersed with replacements for segments that were.
  ;; [For a `large' number of replacments it's more efficient to
  ;; operate in a temporary buffer; we can't tell from the function's
  ;; args whether to choose the buffer-based implementation, though it
  ;; might be reasonable to do so for long enough STRING.]
  (let ((l (length string))
        (start (or start 0))
        matches str mb me)
    (save-match-data
      (while (and (< start l) (string-match regexp string start))
        (setq mb (match-beginning 0)
              me (match-end 0))
        ;; If we matched the empty string, make sure we advance by one char
        (when (= me mb) (setq me (min l (1+ mb))))
        ;; Generate a replacement for the matched substring.
        ;; Operate only on the substring to minimize string consing.
        ;; Set up match data for the substring for replacement;
        ;; presumably this is likely to be faster than munging the
        ;; match data directly in Lisp.
        (string-match regexp (setq str (substring string mb me)))
        (setq matches
              (cons (replace-match (if (stringp rep)
                                       rep
                                     (funcall rep (match-string 0 str)))
                                   fixedcase literal str subexp)
                    (cons (substring string start mb) ; unmatched prefix
                          matches)))
        (setq start me))
      ;; Reconstruct a string from the pieces.
      (setq matches (cons (substring string start l) matches)) ; leftover
      (apply #'concat (nreverse matches)))))

;; Fix required for XEmacs since `string-bytes' doesn't exist
(pmwiki-defun-when-void string-bytes (string)
   "Fake replacement for Emacs `string-bytes'. This function fails for
multibyte characters."
    (length string))

;; ----------------------------------------------------------------------
;;
;;	Preliminaries
;;
;; Define variables with various patterns
;;
(defvar pmwiki-HTTP-pattern
  "^[hH][tT][tT][pP][sS]?:"
  "Pattern matching 'http:' (case insensitive) at the beginning of a string.")

(defvar pmwiki-base-pattern
  (concat "\\(" pmwiki-HTTP-pattern "//[^/?]+\\)\\(/?\\)$\\|"
	  "\\(" pmwiki-HTTP-pattern ".+?\\)\\(\\?n=\\|\\?pagename=\\)\\|"
	  "\\(" pmwiki-HTTP-pattern
	  ".+\\)\\(/\\)[^/?.]+[/.][^/?.#]*\\($\\|#.*\\)\\|"
	  "\\(" pmwiki-HTTP-pattern ".+?\\.php\\)\\(/\\|$\\)")
  "This pattern gets WikiEngine address and where pagename starts.")


;; The pmwiki-site-pattern is used to extract the name of the 
;; site from a URI. The match with the site is match n:o 1
(defvar pmwiki-site-pattern
  (concat pmwiki-HTTP-pattern "//\\(?:[^@]*@\\|\\)\\(.+?\\)[/?]")
  "Pattern that is used to extract the name of the site")

(defvar pmwiki-link-pattern
  (concat "\\[\\[\\([^]|>]*?\\)"
	  "\\(?:\\]\\]\\||.+?\\]\\]\\)\\|" ; [[ <link> ]] or [[ <link> | ... ]]
	  "\\[\\[.+?->\\([^]|>]*?\\)\\]\\]") ; [[ ... -> <link> ]]
  "The pattern used for `pmwiki-next', `pmwiki-prev', `pmwiki-follow' etc.")

;;
;; Other patterns
;;
(defvar pmwiki-style-pattern
  "%%\\|%[A-Za-z][-,=#\\w\\s]*%"
  "Pattern for PmWiki style tags.")

;; ----------------------------------------------------------------------
;;
;; Define variables with some default URI's
;;

(defvar pmwiki-org-sandbox-uri "http://www.pmwiki.org/wiki/Main/WikiSandbox"
  "URI to sandbox at http://www.pmwiki.org")

(defvar pmwiki-default-uri pmwiki-org-sandbox-uri
  "Default URI used by some interactive functions")

(defvar pmwiki-default-site "pmwiki.org"
  "Name given for default site in `pmwiki-open' etc")

(defvar pmwiki-open-uri-default pmwiki-org-sandbox-uri
  "Default URI used by `pmwiki-open-uri'.")

(defcustom pmwiki-main-wiki-base-uri nil
  "Base URI of your favorite Wiki site")
(defcustom pmwiki-main-homepage-uri nil
  "URI for the home page of your favorite wiki")
(defcustom pmwiki-TeX-master-file nil
  "LaTeX file with preamble (empty document) for `preview-latex'.")

;; ----------------------------------------------------------------------
;;
;; Define general variables 
;;
;; `pmwiki-page-uri' becomes local to a buffer in `pmwiki-mode'
(defvar pmwiki-page-uri nil
  "The URI of the page corresponding to the current buffer, thus defining
the base URI of the wiki engine as well as group and page name.")

;;
;; There are too many "URI's" now... basically we have
;; 'base URI' -> the PmWiki-script, e.g. http://wiki.lyx.org/pmwiki.php
;; 'post URI' -> to where the form with a page is posted, same as 'base URI'
;; 'page URI' -> the page, e.g. http://wiki.lyx.org/pmwiki.php/Main/WikiWord
;; 'source URI' -> source of PmWiki-page, e.g.
;;		http://wiki.lyx.org/pmwiki.php/Main/WikiWord?action=source
;;
;; I'm thinking of storing the location data as a list, location-list
;; This requires conversion methods:
;;	data    -> pageURI	=> (pmwiki-loc 'URI  listData)
;;	        -> baseURI	=> (pmwiki-loc 'base listData)
;;	pageURI -> data		=> (pmwiki-uri-to-loc-list URI)
;;	srcURI  -> data		=> (pmwiki-uri-to-loc-list URI)

(defvar pmwiki-location-list nil
  "List with four strings, (<baseURI> <group> <page> . <anchor>),
 specifying the base URI of the wiki engine, group name, page name
and anchor on page. Anchor can be:
* a string: \"here\" means go to [[#here]] or [[##here]]
* a marker means go to the marker
* a cons ('search . regexp) means go to first match of the regexp.")

(defcustom pmwiki-passwords nil
  "A list of password rules, like:
 '(((\"http://www.somewiki.org/wiki\" \"Site\" \"*\")
     . (\"secret\" . \"my-name\"))
   ((\"http://www.mywiki.org/wiki\" \"*\" \"*\")
     . (\"secret\" . nil))
   ((\"http://www.facultywiki.org/wiki\" \"*\" \"Grades\")
     . (\"secret\" . nil)))
Each rule is a cons with location list pattern as car,
and a cons of password and author as a cdr. Star * in a pattern is a wildcar,
it matches any substring (these are not regexps!).
nil as author means that authorisation is not user-based.")

(defcustom pmwiki-slash-format nil
  "If nil, format URI as http://...?Group.Page, else as http://.../Group/Page.
Usually set by last user choice, see `pmwiki-freeze-slash-format'.")

(defcustom pmwiki-main-group-separator "[./]"
  "Regexp for separator standing between \"real\" group name and page name.
Should not contain numbered regexp subgroups, e.g. \\( ... \\).
Default value: \"[./]\". Some wikis recognize : as a group separator.")
(defcustom pmwiki-word-separating-punct "[!@$=_+{}`~\\:;,]\\|\\s-"
  "Regexp for substrings removed from the link after word capitalization.
Default value: \"[!@$=_+{}`~\\:;,]\\|\\s-\".")
(defcustom pmwiki-non-word-separating-punct "[()']"
  "Regexp for substrings removed from the link before word capitalization.
Default value: \"[()']\".")

(defcustom pmwiki-freeze-slash-format nil
  "If non-nil, don't follow user choice of slash vs. question-mark.
See `pmwiki-slash-format'.")

(defvar pmwiki-save-function 'pmwiki-default-save-function
  "Specifies the function used to save a PmWiki-buffer.")
(defvar pmwiki-load-function 'pmwiki-default-load-function
  "Specifies the function used to load a PmWiki-buffer.
It should load non-blockingly contents into a new or existing buffer,
then call `pmwiki-edit-cont' in that buffer, then switch user to that buffer.
See `pmwiki-default-load-function'.")
(defvar pmwiki-pagelist-function 'pmwiki-default-pagelist-function
  "Specifies the function used to load a PmWiki page list.
It should load non-blockingly pagelist contents into a temporary buffer,
then call `pmwiki-pagelist-cont' in that buffer.
See `pmwiki-default-pagelist-function'.")
(defvar pmwiki-search-function 'pmwiki-default-search-function
  "Specifies the function used to search a PmWiki site.
It should load non-blockingly search response pagelist contents into
a temporary buffer, then call `pmwiki-pagelist-cont' with
`pmwiki-search-cont' as first argument, in that buffer.
See `pmwiki-default-search-function'.")
(defcustom pmwiki-default-pagelist-page "Site.SideBar"
  "The default pagelist page. See `pmwiki-rescan-pages'.")
(defcustom pmwiki-pagelist-hyphen-subgroups t
  "When non-nil, join hyphenated subgroups in group names,
e.g. Mammal-canine.")
(defcustom pmwiki-pagelist-hyphen-regexp "-"
  "Subgroup separator in group name.")
(defcustom pmwiki-pagelist-join-pages t
  "When non-nil, join pages in a group by their words.")
(defvar pmwiki-encode-url-arg 'url-hexify-string
  "Function used to replace non[a-z] chars with their codes in URLs.")
(defvar pmwiki-decode-url-arg 'url-unhex-string
  "Function used to replace non[a-z] chars with their codes in URLs.")

(defvar pmwiki-debug-level 3
  "When a positive number, turn on debugging.
Three levels of debugging:
* >=1: URL debugging (in the *URL-DEBUG* buffer)
* >=2: keep responses to save requests (*DEBUG-SAVE: ...* buffers)
* >=3: keep responses to load requests (*DEBUG-LOAD: ...* buffers)
")

(if (require 'url nil t)
    (progn
      (when (and pmwiki-debug-level (<= 1 pmwiki-debug-level))
	(setq url-debug t)
	(require 'url-auth)))
  (message
   "Using `emacs-http' instead of URL from Emacs 22.")
  ;;(sleep-for 1)
  (unless (and (require 'http-get nil t) (require 'http-post nil t))
    (error "Upgrade to Emacs 22 or install `emacs-http'."))
  (setq pmwiki-save-function 'pmwiki-alternative-save-function)
  (setq pmwiki-search-function 'pmwiki-alternative-search-function)
  (setq pmwiki-load-function 'pmwiki-alternative-load-function)
  (setq pmwiki-encode-url-arg
	(lambda (arg) (http-url-encode arg 'iso-8859-1)))

;;;stolen from `url-util.el'.
(defun url-hexify-string (string)
  "Return a new string that is STRING URI-encoded.
First, STRING is converted to utf-8, if necessary.  Then, for each
character in the utf-8 string, those found in `url-unreserved-chars'
are left as-is, all others are represented as a three-character
string: \"%\" followed by two lowercase hex digits."
  ;; To go faster and avoid a lot of consing, we could do:
  ;; 
  ;; (defconst url-hexify-table
  ;;   (let ((map (make-vector 256 nil)))
  ;;     (dotimes (byte 256) (aset map byte
  ;;                               (if (memq byte url-unreserved-chars)
  ;;                                   (char-to-string byte)
  ;;                                 (format "%%%02x" byte))))
  ;;     map))
  ;;
  ;; (mapconcat (curry 'aref url-hexify-table) ...)
  (mapconcat (lambda (byte)
               (if (memq byte url-unreserved-chars)
                   (char-to-string byte)
                 (format "%%%02x" byte)))
             (if (multibyte-string-p string)
                 (encode-coding-string string 'utf-8)
               string)
             ""))

  (setq pmwiki-pagelist-function 'pmwiki-alternative-pagelist-function))

(defcustom pmwiki-max-redirections 5
  "If non-nil, process that much redirections.
Keep all information across redirections (page to visit, contents to save).")
(defvar pmwiki-redirect-count pmwiki-max-redirections
  "How many redirections left allowed.")

(defcustom pmwiki-fill-column 76 "Fill column width for `pmwiki-mode'.")
(defcustom pmwiki-mode-hooks nil "")
(defcustom pmwiki-save-before-hooks nil "")
(defcustom pmwiki-menu-entry-max-length 70
  "Maximal number of menu entry characters.")

(defcustom pmwiki-decode nil
  "Function called after loading wiki source. No arguments are passed.
It is supposed to process current buffer contents.
See also `pmwiki-encode'.")
(defcustom pmwiki-encode nil
  "Function called on `buffer-string' before saving it as wiki source.
It is called by `pmwiki-default-save-function', can be bypassed when
customizing `pmwiki-save-function'.
It is supposed to be the inverse of `pmwiki-decode'.")

(defcustom pmwiki-author "" "\"Name\" that shows up as author of the
changes when a page is saved from `pmwiki-mode'.")

(defcustom pmwiki-default-page-name "\\0"
  "Default page name when page is not given, like in [[Group.]] links.
\\0 is substituted by group name.")

(defvar pmwiki-mode-line-string nil
  "A buffer-local string with site address, to place in the mode line.")

;; XEmacs compatibility issues resolved here
(defvar pmwiki-mode-line-buffer-identification
  `(,(propertize
     "%09b"
     'help-echo "mouse-1: previous buffer, mouse-3: next buffer"
     'face 'bold
     'local-map
       '(keymap
	(header-line keymap
		     (mouse-3 . mode-line-bury-buffer)
		     (down-mouse-3 . ignore)
		     (mouse-1 . mode-line-unbury-buffer)
		     (down-mouse-1 . ignore))
	(mode-line keymap
		   (mouse-3 . mode-line-bury-buffer)
		   (mouse-1 . mode-line-unbury-buffer)
		   (down-mouse-1 . ignore))))
    " "
    pmwiki-mode-line-string
    )
  "The mode line control used in pmwiki-mode for buffer identification, i.e.
it adds the name of the site after the name of the buffer (wiki page).")


;; ----------------------------------------------------------------------
;;
;;	Auxiliary helper function
;;
(defun pmwiki-default-string (s s0)
  "Return S if not empty, otherwise return S0"
  (if (string= s "") s0 s))

(defun pmwiki-URIp (name)
  "Returns t if NAME matches a URI pattern 
If NAME starts with 'http:', it must match `pmwiki-base-pattern',
otherwise an error is thrown."
  (let ((case-fold-search nil))
    (if (string-match pmwiki-HTTP-pattern name)
	(if (string-match pmwiki-base-pattern name) t
	  (error
	   "pmwiki-uri-type: %s does not match a proper URI pattern" name))
      nil)))



;; ----------------------------------------------------------------------
;;
;;	Main code
;;
;; Define the `pmwiki-mode'. 
;;
;; Have to modify patterns for faces. List of faces:
;; builtin, comment, constant, doc, function, keyword, string, type, variable,
;; warning
;;	[=...=]			- string
;;	[[#<target>]]		- constant
;;	[[<uri> <text>]]	- type
;;  ;;	 <monospace>		- comment  (not used anymore)
;;	@@<monospace>@@		- comment
;;	''<emp>''		- type
;;	'''<strong>'''		- function
;;	'''''<extra>'''''	- warning
;;	*...			- builtin
;;	#...			- doc
;;	!...			- function
;;	:..: : <indented par.>	- doc
;;
;; Maybe remove sgml-tag-alist?

;; Special faces
(defface pmwiki-question-face
  '((t (:bold t)))
  "Used to indicate a question in a PmWiki page.")

(defface pmwiki-answer-face
  '((t (:bold t :italic t)))
  "Used to indicate an answer in a PmWiki page.")


(define-derived-mode pmwiki-mode text-mode "PmWiki"
  "`pmwiki-mode` v0.4 is a Mode to edit PmWiki pages (http://www.pmwiki.org).

Typically you start by using the function `pmwiki-open' to open a URI, e.g.
	http://www.pmwiki.org/wiki/Main/WikiSandbox
Once you have opened a wiki page, you can simply use `pmwiki-open'
again with a simple argument such as 'Main.OtherPage' to open another
page in the same site.

As a special case, you can also use `pmwiki-open' to open a wiki page
from the site pmwiki.org (since it is the default site) even if you
are currently not in a buffer that contains an opened wiki page.

Pages in the `pmwiki-main-wiki-base-uri' site can always be opened using
`mywiki-open', since this function always assumes that the page names refer
to that site (giving the URI of a page overrides this bevhaviour however).

Note that it is not recommended to use `pmwiki-mode' as a command to
start editing a wiki page - it likely won't work.

Once a page has been opened, you can edit it and then save it using
`pmwiki-save' or `pmwiki-save-as'. The latter function allows you to
save the page with a new name, and even on a different wiki engine by
giving an URI as argument.

To view the wiki page that you are editing in a browser, first save it
and then use the command `pmwiki-browse'.

While editing the page, you can use `pmwiki-next' and `pmwiki-prev' to
quickly go to the next and previous links. And when the point is on a
link, you can use `pmwiki-follow' to goto the page that the link
points to, i.e. that page is opened in a new buffer.

Interactive functions:
`pmwiki-open'    - Open wiki page specified by group/name or URI.
                   The default site is pmwiki.org.
`pmwiki-show-uri` - Show the URI of the current wiki page.
`pmwiki-next'    - Goto the next [[link]].
`pmwiki-prev'    - Goto the previous [[link]].
`pmwiki-follow'  - Open (goto) page pointed to by link at point.
`pmwiki-save'    - Save current buffer to the wiki engine.
`pmwiki-save-as' - Save buffer to new page specified by group/name or URI.
`pmwiki-reload'  - Reload the page.
`pmwiki-browse'  - Show current buffer in browser.
`pmwiki-toc'     - Show Table of Contents for current page.
`pmwiki-search'  - Search the wiki site for a text.
`pmwiki-map-site'  - Generate a map of the site (all groups and pages).
`pmwiki-delete'	 - Delete a page
`pmwiki-rename'	 - Save a page under a different name and delete the original

`mywiki-open'       - Open a page from the LyX wiki.
`mywiki-save-as'    - Save current buffer to page at the LyX wiki.

\\{pmwiki-mode-map}"
  (when pmwiki-running-emacs
    (font-lock-add-keywords
     nil
     '(
;;       ("^[ \t].+?$" . font-lock-comment-face)		;  <monospace>
       ("\\[=[^=]*=\\]" . font-lock-function-name-face)	; [= ... =]
       ("@@[^ \t@][^@]*[^ \t@]@@" . font-lock-comment-face) ; @@a .. b@@
       ("\\(^[*#]+\\)[^*#]" 1 font-lock-constant-face)	; {*|#}+ ...
       ("^!+[^!].*" . font-lock-constant-face)		; !+ ...
       ("\\[\\[<<\\]\\]" . font-lock-comment-face)	; [[<<]]
       ;("\\[\\[#[^]]+\\]\\]" . font-lock-constant-face)	; [[#<target>]]
       ;("\\[\\[[^#].*?\\]\\]" . font-lock-type-face)	; [[ ... ]]
       ("\\[\\[.*?\\]\\]" . font-lock-type-face)	; [[ ... ]]
       ("\\\\$" . font-lock-keyword-face)		;     \
       ("^:+ +:" . font-lock-doc-face)			; :..: : 
       ("^:[ \t]*[^ \t:]+[ \t]*+:" . font-lock-string-face) ; : term : 
       ("%[^ \t%][^%]*[^ \t%]%" . font-lock-warning-face) ; %color = red%
       ("^Q:" . pmwiki-question-face)			; Q:
       ("^A:" . pmwiki-answer-face)			; A:
       )))

;;   (when pmwiki-running-emacs
;;     (font-lock-add-keywords
;;      nil
;;      (list (cons (symbol-value 'pmwiki-link-pattern) 'font-lock-keyword-face))
;;      ))

  (when pmwiki-running-emacs (font-lock-mode 1))
  (goto-address)
  (set (make-local-variable 'sgml-tag-alist)
       `(("b") ("code") ("em") ("i") ("strong") ("nowiki")
	 ("pre" \n) ("tt") ("u")))
  (set (make-local-variable 'skeleton-transformation) 'identity)
  (set (make-local-variable 'pmwiki-search-mode-status) nil)
  (setq indent-tabs-mode t)
  (set (make-local-variable 'mode-line-buffer-identification)
       pmwiki-mode-line-buffer-identification)
  (set (make-local-variable 'pmwiki-location-list)
       ;;this variable should be bound dynamically around call to pmwiki-mode
       pmwiki-mode-location-list)
  (set (make-local-variable 'pmwiki-mode-line-string)
       (pmwiki-create-mode-line-string))
  (set-fill-column pmwiki-fill-column)
  (pmwiki-build-menu)
  ;; Add local hook to set buffer-local menus
  (add-hook 'menu-bar-update-hook 'pmwiki-build-menu nil t)
  ;;(make-local-variable 'speedbar-initial-expansion-list-name)
  ;;(setq speedbar-initial-expansion-list-name "PmWiki")
  (set 'TeX-header-end "^[^%\n]*\\\\begin *{document}") ;FIXME
  (set 'TeX-trailer-start "^[^%\n]*\\\\end *{document}")
  (set 'TeX-master pmwiki-TeX-master-file)
  (when pmwiki-running-mmm (mmm-mode 1))
  (run-hooks 'pmwiki-mode-hooks))



;; Link matching algorithm (v0.4):
;;
;; 1: extract link from "[[" to "|" orelse from "->" to "]]"
;;    orelse from "[[" to "]]"
;;
;; 2: remove non-word-separationg punctuation: e.g. ()'
;;
;; 3: extract the WikiEngine address part if there is one
;;
;; 4: extract anchor if there is one
;;
;; 5: capitalize all words not directly preceded by "-"
;;
;; 6: remove all word-separating punctuation: e.g. SPACE!@$=_+\{}`~\
;;
;; 7: extract parts [<Group>{./}]<Page>[#<anchor>], if Page is preceded
;;    by "!", set group to Category, if by "~", to Profiles,
;;    if Page is not given, set according to `pmwiki-default-page-name'


(defun pmwiki-capitalize (str)
  "Capitalize words in STR without changing the case of inner letters."
  (replace-regexp-in-string "[^-%0-9]\\<[a-z]\\|^[a-z]" 'capitalize str))

(pmwiki-capitalize "located_kindly")

;; Implenents the matching algorithm, without the first point,
;; used for `pmwiki-follow' and for `pmwiki-open'
(defun pmwiki-link-to-loc (maybe-link)
  "Convert a string with a page, e.g. \"Group.Page\" to a location list, i.e.
	(\"baseURI\" \"Group\"  \"Page\" . \"anchor\")

All parts (base, group, page, anchor) are optional. If base and only one of
group and page is given, then both group and page are set the same.
If only site is given, group and page are set to Main.HomePage."
  (let (baseURI anchor-beg anchor group page aux)
    (if (or (not maybe-link) (string= maybe-link "")) nil
      (setq maybe-link (replace-regexp-in-string
			pmwiki-non-word-separating-punct "" maybe-link))
      (if  (string= maybe-link "") nil
	(if (string-match pmwiki-base-pattern maybe-link)
	(progn
	  (setq baseURI
		(or (match-string 1 maybe-link)
		    (match-string 3 maybe-link)
		    (match-string 5 maybe-link)
		    (match-string 8 maybe-link)))
	  (setq aux (substring
		     maybe-link
		     ;; `and's: strange workaround for XEmacs
		     (or (and (match-end 1) (match-end 2))
			 (and (match-end 3) (match-end 4))
			 (and (match-end 5) (match-end 6))
			 (and (match-end 8) (match-end 9)))))
	  (unless pmwiki-freeze-slash-format
	    (let ((slashmark
		   (or (and (match-end 1) (match-string 2 maybe-link))
		       (and (match-end 3) (match-string 4 maybe-link))
		       (and (match-end 5) (match-string 6 maybe-link))
		       (and (match-end 8) (match-string 9 maybe-link)))))
	      (if (string-match "/" slashmark)
		  (setq pmwiki-slash-format t)
		(if (string-match "?" slashmark)
		    (setq pmwiki-slash-format nil)))))
	  (setq maybe-link aux)))
    (setq anchor-beg (string-match "##?\\(\\S-+\\)\\s-*$" maybe-link))
    (if anchor-beg
	(progn
	  (setq anchor (match-string 1 maybe-link))
	  (if (string= anchor "")
	      (setq anchor nil))
	  (setq maybe-link (substring maybe-link 0 anchor-beg))))
    (setq maybe-link (pmwiki-capitalize maybe-link))
    (setq maybe-link (replace-regexp-in-string
		      pmwiki-word-separating-punct "" maybe-link))
    ;; take the last bit as page name (compatible with Hg)
    (if (string-match (concat "^\\(.+\\)"
			      pmwiki-main-group-separator
			      "\\(.*?\\)$") maybe-link)
	(progn
	  (setq group (match-string 1 maybe-link))
	  (setq page (match-string 2 maybe-link))
	  (if (string= page "")
	      (setq page
		    (replace-regexp-in-string
		     "\\\\0"
		     group pmwiki-default-page-name))))
      (setq page maybe-link)
      (if baseURI
	  (setq group page)))
    `(,baseURI ,group ,page . ,anchor)))))

(defun pmwiki-loc (P &optional loc-list)
  "Compute relevant information from location list.
If URI is not given, `pmwiki-location-list' is used instead.
P determines what is returned according to this list:
	'base		-> <BaseURI>
	'group		-> <group>
	'page		-> <page>
	'anchor		-> <anchor>
	'groupENC	-> <group> URL-encoded
	'pageENC	-> <page> URL-encoded
	'anchorENC	-> <anchor> URL-encoded
	'name		-> \"<group>.<page>\" (if <anchor> = nil)
	'nameNA		-> \"<group>.<page>\" (NA = No Anchor)
	'name		-> \"<group>.<page>#<anchor>\"
	'nameENC	-> \"<groupENC>.<pageENC>#<anchorENC>\"
	'nameENCNA	-> \"<groupENC>.<pageENC>\"
	'URI		-> \"<BaseURI>?n=<group>.<page>\" (if <anchor> = nil)
	'URINA		-> \"<BaseURI>?n=<group>.<page>\" (NA = No Anchor)
	'URI		-> \"<BaseURI>?n=<group>.<page>#<anchor>\"
	'site		-> <site> (part of BaseURI)
If `pmwiki-slash-format' is t, replace dots and \"?n=\" with slashes above."
  (unless loc-list (set 'loc-list pmwiki-location-list))
  (unless loc-list
    (error "No location given, set `pmwiki-location-list' first!"))
  (unless (symbolp P) (error "Invalid type of argument"))
  (let ((s (symbol-name P))
	(anchor-enc (if (stringp (cdddr loc-list))
			(funcall pmwiki-encode-url-arg (cdddr loc-list))
		      nil))
	(page-enc (funcall pmwiki-encode-url-arg (caddr loc-list)))
	(group-enc (funcall pmwiki-encode-url-arg (cadr loc-list))))
    (cond
     ((string-equal s "base") (car loc-list))
     ((string-equal s "group") (cadr loc-list))
     ((string-equal s "page") (caddr loc-list))
     ((string-equal s "anchor") (cdddr loc-list))
     ((string-equal s "groupENC") group-enc)
     ((string-equal s "pageENC") page-enc)
     ((string-equal s "anchorENC") anchor-enc)
     ((string-equal s "name")
      (concat (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)
	      (if anchor-enc
		  (concat "#" (cdddr loc-list)) "")))
     ((string-equal s "nameNA")
      (concat (cadr loc-list)
	      (if pmwiki-slash-format "/" ".") (caddr loc-list)))
     ((string-equal s "nameENC")
      (concat group-enc
	      (if pmwiki-slash-format "/" ".") page-enc
	      (if anchor-enc
		  (concat "#" anchor-enc) "")))
     ((string-equal s "nameENCNA")
      (concat group-enc
	      (if pmwiki-slash-format "/" ".") page-enc))
     ((string-equal s "URI")
      (concat (car loc-list)
	      (cond
	       ((string-match "^https?://[^/]+$" (car loc-list))
		(setq pmwiki-slash-format nil)
		"/?n=")
	       (pmwiki-slash-format "/")
	       (t "?n=")) group-enc
	      (if pmwiki-slash-format "/" ".") page-enc
	      (if anchor-enc
		  (concat "#" anchor-enc) "")))
     ((string-equal s "URINA")
      (concat (car loc-list)
	      (cond
	       ((string-match "^https?://[^/]+$" (car loc-list))
		(setq pmwiki-slash-format nil)
		"/?n=")
	       (pmwiki-slash-format "/")
	       (t "?n=")) group-enc
	      (if pmwiki-slash-format "/" ".") page-enc))
     ((string-equal s "site")
      (string-match pmwiki-site-pattern (car loc-list))
      (match-string 1 (car loc-list)))
     (t (error "Invalid argument 'P' of `pmwiki-loc'!")))))

(defun pmwiki-merge-loc (loc1 &optional loc2)
  "Merge two location lists: if LOC1 doesn't specify something, use LOC2.
When LOC2 is not given, use `pmwiki-location-list'."
  (unless loc2 (setq loc2 pmwiki-location-list))
  (if loc2
      (if (and (car loc1) (not (string= "" (car loc1))))
	  loc1
	(if (and (cadr loc1) (not (string= "" (cadr loc1))))
	    (cons (car loc2) (cdr loc1))
	  (if (and (caddr loc1) (not (string= "" (caddr loc1))))
	      `(,(car loc2) ,(cadr loc2) ,@(cddr loc1))
	    (if (and (cdddr loc1)
		     (or (number-or-marker-p (cdddr loc))
			 (not (string= "" (cdddr loc1)))))
		`(,(car loc2) ,(cadr loc2) ,(caddr loc2) ,(cdddr loc1))
	      loc2))))
    loc1))
 

(defun pmwiki-create-mode-line-string ()
  "Used to create the text that goes into the mode line."
  (propertize
   (if pmwiki-location-list
       (format "[%s]" (pmwiki-loc 'site))
     "[?]")
   'face 'italic 'mouse-face 'bold-italic
   'help-echo pmwiki-page-uri))

(defun pmwiki-show-uri ()
  "Show the URI for the wiki page being edited in the current buffer."
  (interactive)
  (message (pmwiki-loc 'URI)))



;; ----------------------------------------------------------------------
;;
;; `pmwiki-edit' - main function used to load a PmWiki-page into a buffer
;;
;;;###autoload
(defun pmwiki-edit (loc &optional buf)
  "Download the wiki page specified by location list LOC
into buffer BUF or a new buffer."
  (funcall pmwiki-load-function loc buf))

(defun pmwiki-default-load-function (loc &optional buf)
  "Download the wiki page specified by location list LOC.
Then call `pmwiki-edit-cont' to process contents and set the `pmwiki-mode'.
Change the buffer's mode to `pmwiki-mode', process contents with
`pmwiki-decode', and move point to the anchor if it is specified."
  (let ((url (concat (pmwiki-loc 'URINA loc)
	      (if pmwiki-slash-format "?action=source"
		"&action=source")))
	(buf (or buf (generate-new-buffer (pmwiki-loc 'nameNA loc)))))
    (if pmwiki-running-xemacs
	(let ((url-working-buffer buf))
	  (switch-to-buffer (cdr (url-retrieve url)))
	  (pmwiki-edit-cont loc))
      (let ((url-request-method "GET"))
	(url-retrieve url 'pmwiki-emacs-edit-cont
		      (list url loc buf))))))

(defun pmwiki-default-pagelist-function (listpage)
  "Download the wiki page specified by LISTPAGE,
then call `pmwiki-pagelist-cont'."
  (let* ((loc (pmwiki-merge-loc (pmwiki-link-to-loc listpage)))
	 (url (pmwiki-loc 'URINA loc))
	 (base (pmwiki-loc 'base loc))
	 (site (pmwiki-loc 'site loc)))
    (if pmwiki-running-xemacs
	(with-temp-buffer
	  (let ((url-working-buffer (current-buffer)))
	    (url-retrieve url)
	    (pmwiki-pagelist-cont
	     nil (list 'pmwiki-rescan-pages-cont
		       (pmwiki-pagelist-defentry site)
		       nil nil nil base site))))
      (let ((url-request-method "GET"))
	(url-retrieve url 'pmwiki-pagelist-cont
		      (list 'pmwiki-rescan-pages-cont
			    (pmwiki-pagelist-defentry site)
			    nil nil nil base site))))))

(defun pmwiki-alternative-pagelist-function (listpage)
  "Download the wiki page specified by LISTPAGE,
then call `pmwiki-pagelist-cont'."
  (let* ((loc (pmwiki-merge-loc (pmwiki-link-to-loc listpage)))
	 (url (pmwiki-loc 'URINA loc))
	 (base (pmwiki-loc 'base loc))
	 (site (pmwiki-loc 'site loc))
	 (buf (generate-new-buffer "*PageList*"))
	 (headers '(("Connection" "close"))))
    (if pmwiki-running-xemacs
	(with-current-buffer buf
	  (let ((url-working-buffer (current-buffer)))
	    (url-retrieve url)
	    (pmwiki-pagelist-cont
	     nil 'pmwiki-rescan-pages-cont
	     (pmwiki-pagelist-defentry site)
	     nil nil nil base site)))
      (with-current-buffer buf
	(setq pmwiki-alternative-pagelist-base base)
	(setq pmwiki-alternative-pagelist-site site)
	(http-get url headers 'pmwiki-alternative-pagelist-cont nil
		  (current-buffer) 'iso-8859-1)))))

(defun pmwiki-alternative-pagelist-cont (proc messg)
  (with-current-buffer (process-buffer proc)
    (pmwiki-pagelist-cont
     nil 'pmwiki-rescan-pages-cont
     (pmwiki-pagelist-defentry pmwiki-alternative-pagelist-site)
     nil nil nil pmwiki-alternative-pagelist-base
     pmwiki-alternative-pagelist-site)))


(defun pmwiki-search-defentry (search-term)
  (list ["search for..." pmwiki-search t]
	(concat "results for " search-term)))

(defun pmwiki-default-search-function (search-term)
  "Download the search results for SEARCH-TERM,
then call `pmwiki-pagelist-cont'."
  (let* ((base (pmwiki-loc 'base))
	 (site (pmwiki-loc 'site))
	 (url-base (pmwiki-loc 'URINA))
	 (url (concat url-base (if pmwiki-slash-format "?" "&")
		      "action=search&q="
		      (url-hexify-string search-term))))
    (if pmwiki-running-xemacs
	(with-temp-buffer
	  (let ((url-working-buffer (current-buffer)))
	    (url-retrieve url)
	    (pmwiki-pagelist-cont
	     nil (list 'pmwiki-search-cont
		       (pmwiki-search-defentry search-term)
		       search-term nil nil
		       base site))))
      (let ((url-request-method "GET"))
	(url-retrieve url 'pmwiki-pagelist-cont
		      (list 'pmwiki-search-cont
			    (pmwiki-search-defentry search-term)
			    search-term nil nil
			    base site))))))

(defun pmwiki-alternative-search-function (search-term)
  "Download the search results for SEARCH-TERM,
then call `pmwiki-pagelist-cont'."
  (let* ((base (pmwiki-loc 'base))
	 (site (pmwiki-loc 'site))
	 (url-base (pmwiki-loc 'URINA))
	 (url (concat url-base (if pmwiki-slash-format "?" "&")
		      "action=search&q="
		      (http-url-encode search-term
				       'iso-8859-1)))
	 (buf (generate-new-buffer "*PageList*"))
	 (headers '(("Connection" "close"))))
    (if pmwiki-running-xemacs
	(with-current-buffer buf
	  (let ((url-working-buffer (current-buffer)))
	    (url-retrieve url)
	    (pmwiki-pagelist-cont
	     nil 'pmwiki-search-cont
	     search-term nil nil base site)))
      (with-current-buffer buf
	(setq pmwiki-alternative-pagelist-base base)
	(setq pmwiki-alternative-pagelist-site site)
	(setq pmwiki-alternative-search-sterm search-term)
	(http-get url headers 'pmwiki-alternative-search-cont nil
		  (current-buffer) 'iso-8859-1)))))

(defun pmwiki-alternative-search-cont (proc messg)
  (with-current-buffer (process-buffer proc)
    (pmwiki-pagelist-cont
     nil 'pmwiki-search-cont
     (pmwiki-search-defentry pmwiki-alternative-search-sterm)
     pmwiki-alternative-search-term nil nil
     pmwiki-alternative-pagelist-base
     pmwiki-alternative-pagelist-site)))


;; FIXME: a workaround for older versions of url package
(defun pmwiki-emacs-edit-cont (&rest cbargs)
  "Continuation of loading URL into a buffer."
  (let* ((status (if (listp (car cbargs)) (car cbargs)
		  (subseq cbargs 0 -3)))
	 (url (nth (- (length cbargs) 3) cbargs))
	 (loc (nth (- (length cbargs) 2) cbargs))
	 (buf (nth (- (length cbargs) 1) cbargs)))
    (when (and pmwiki-debug-level (<= 3 pmwiki-debug-level))
      (let ((page-text (buffer-substring (point-min) (point-max))))
	(with-current-buffer (get-buffer-create
			      (concat "*DEBUG-LOAD: " url "*"))
	  (insert page-text))))
  (if (and pmwiki-redirect-count
       (>= 0 pmwiki-redirect-count))
      (error
       "`pmwiki-mode' exceeded redirection count -- recurrent redirection"))
  (if (and pmwiki-redirect-count
       (< 0 pmwiki-redirect-count) (member :redirect status))
      (let ((new-url
	     (pmwiki-merge-uri-args (cadr (member :redirect status)) url))
	    (url-request-method "GET"))
	(setq pmwiki-redirect-count (1- pmwiki-redirect-count))
	(kill-buffer (current-buffer))
	(url-retrieve new-url 'pmwiki-emacs-edit-cont
		      (list new-url loc buf)))
    (goto-char (point-min))
    (re-search-forward "^$")
    (setq start (1+ (match-end 0))) ; delete headers
    (if (string= (buffer-substring (- (point-max) 2) (point-max)) "\r\n")
	(setq end (- (point-max) 2))
      (setq end (point-max)))
    (let ((auxbuf (current-buffer)))
      (with-current-buffer buf
	(delete-region (point-min) (point-max))
	(insert-buffer-substring auxbuf start end)
	(pmwiki-edit-cont loc))
      (switch-to-buffer buf)
      (kill-buffer auxbuf)))))
  
(defun pmwiki-edit-cont (loc)
  ;;DAMN! this doesn't work, why?
;;   (let ((pmwiki-mode-location-list loc))
;;     (pmwiki-mode))
  (setq pmwiki-mode-location-list loc) (pmwiki-mode)
  ;;FIXME above
  (set (make-local-variable 'pmwiki-mode-location-list) loc)
  (goto-char (point-min))
  (if pmwiki-decode (funcall pmwiki-decode))
  (when pmwiki-running-emacs (font-lock-mode 1))
  (goto-char (point-min))
  (when (cdddr loc)
    (cond
     ((number-or-marker-p (cdddr loc))
      (goto-char (cdddr loc)))
     ((stringp (cdddr loc))
      (re-search-forward
       (concat "\\[\\[##?" (regexp-quote (pmwiki-loc 'anchor loc))
	       "\\]\\]")))
     ((and (consp (cdddr loc)) (equal 'search (cadddr loc)))
      (re-search-forward (cddddr loc)))
     (t (error (concat
		"`pmwiki-edit-cont': wrong anchor type in LOC -- "
		(print (cdddr loc)))))))
  (set-buffer-modified-p nil))

(defvar pmwiki-alternative-load-loc nil)
(defun pmwiki-alternative-load-function (loc &optional buf)
  "Download the wiki page specified by location list LOC.
Then call `pmwiki-edit-cont' to process contents and set the `pmwiki-mode'.
Change the buffer's mode to `pmwiki-mode', process contents with
`pmwiki-decode', and move point to the anchor if it is specified."
  (let ((url (concat (pmwiki-loc 'URINA loc)
	      (if pmwiki-slash-format "?action=source"
		"&action=source")))
	(buf
	 (or buf (generate-new-buffer (pmwiki-loc 'nameNA loc))))
	(headers '(("Connection" "close")))
	proc)
    (setq pmwiki-alternative-load-loc loc)
    (http-get url headers 'pmwiki-alternative-load-cont nil buf
	      'iso-8859-1)))

(defun pmwiki-alternative-load-cont (proc message)
  (with-current-buffer (process-buffer proc)
    (pmwiki-edit-cont pmwiki-alternative-load-loc))
  (switch-to-buffer (process-buffer proc)))

(defun pmwiki-merge-uri-args (uri old-uri)
  "Merge GET-type parameters, URI has priority over OLD-URI."
  (string-match "^\\([^?]+\\)\\(?:\\?\\(.+?\\)\\|\\)$" uri)
  (let* ((base (match-string 1 uri))
	 (args1 (or (match-string 2 uri) ""))
	 (args1 (split-string args1 "&"))
	 (args1 (mapcar (lambda (arg) (split-string arg "=")) args1)))
    (string-match "^[^?]*$\\|\\?\\(.+?\\)$" old-uri)
    (let* ((args2 (or (match-string 1 old-uri) ""))
	   (args2 (split-string args2 "&"))
	   (args2 (mapcar (lambda (arg) (split-string arg "=")) args2))
	   )
      (mapc (lambda (arg)
	      (when (not (assoc (car arg) args1))
		(setq args1 (cons arg args1)))) args2)
      (setq args1
	    (delete-if (lambda (arg)
			 (and arg (> 1 (length (car arg))))) args1))
      (if args1
	(concat base "?"
		(mapconcat (lambda (arg)
			     (concat (car arg) "=" (cadr arg))) args1 "&"))
	base))))

(defun pmwiki-uri-no-args (uri)
  "Discard GET-type parameters."
  (string-match "^\\([^?]+\\)\\(?:\\?\\(.+?\\)\\|\\)$" uri)
  (match-string 1 uri))

(defun pmwiki-make-pattern (pat)
  (concat "^"
	(replace-regexp-in-string
	 "\\\\\\*" ".*"
	 (regexp-quote pat))
	"$"))

(defun pmwiki-process-passwords (loc)
  "Return '(password . author) for a given GROUP.PAGE."
  (let* ((site (car loc))
	 (group (cadr loc))
	 (page (caddr loc))
	 (rules pmwiki-passwords) exit passwd-auth)
    (while (and rules (not exit))
      (let* ((rule (pop rules))
	     (pattern (car rule))
	     (site-re (pmwiki-make-pattern (car pattern)))
	     (group-re (pmwiki-make-pattern (cadr pattern)))
	     (page-re (pmwiki-make-pattern (caddr pattern))))
	(setq exit
	      (and (string-match site-re site)
		   (string-match group-re group)
		   (string-match page-re page))
	      passwd-auth (and exit (cdr rule)))))
    passwd-auth))


(defun pmwiki-default-save-function ()
  "Save the current page to a PmWiki wiki."
  (let* ((cur-buffer (buffer-name))
	(loc pmwiki-location-list)
	(passwd-auth (pmwiki-process-passwords loc))
	(pagename (pmwiki-loc 'nameENCNA))
	(cur-fill-column fill-column)
	(text (if pmwiki-encode
		  (funcall pmwiki-encode (buffer-string))
		(buffer-string)))
	(url-request-method "POST")
	(url-request-extra-headers '(("Content-Type" .
			      "application/x-www-form-urlencoded")))
	(url-request-data
	 (concat       
	  "n=" pagename "&action=edit&post=1&author="
	  pmwiki-author
	  (if passwd-auth (concat "&authpw=" (car passwd-auth)
				  (if (cdr passwd-auth)
				      (concat "&authid=" (cdr passwd-auth))
				    "")) "")
	  "&text="
	  (url-hexify-string text)))
	(url (pmwiki-loc 'base)))
    (when pmwiki-debug-level (setq pmwiki-debug-redirection-stack nil))
    (url-retrieve url 'pmwiki-default-save-cont
		  (list url cur-buffer loc nil
			(and passwd-auth
			     (or (car passwd-auth) (cdr passwd-auth)))
			url-request-data))))

;; Stolen from `http-get.el'
(defun pmwiki-http-url-encode (str content-type)
  "URL encode STR using CONTENT-TYPE as the coding system."
  (apply 'concat
	 (mapcar (lambda (c)
		   (if (or (and (>= c ?a) (<= c ?z))
			   (and (>= c ?A) (<= c ?Z))
			   (and (>= c ?0) (<= c ?9)))
		       (string c)
		     (format "%%%02x" c)))
		 (encode-coding-string str content-type))))

(defcustom pmwiki-verify-by-redirect t
  "When non-nil, uses redirection as indication that saving succeeded.
To use it, should NOT have $EnableRedirect = 0 in your config.php."
  :group 'pmwiki-group :type 'boolean)

(defvar pmwiki-debug-redirection-stack nil
  "Stack with redirection locations (debug level >= 2).")

(setq pmwiki-debug-redirection-stack nil)

(defcustom pmwiki-one-wiki-per-site t
  "If non-nil, assume that there is at most one wiki-engine on each site."
  :group 'pmwiki-group :type 'boolean)

(defun pmwiki-equal-loc (loc new-loc)
  "Compare locations, when NEW-LOC can be url-encoded."
  (and loc new-loc
       (if pmwiki-one-wiki-per-site
	   (string= (pmwiki-loc 'site loc) (pmwiki-loc 'site new-loc))
	 (string= (car loc) (car new-loc)))
       (or
	(string= (cadr loc) (cadr new-loc))
	(string=
	 (pmwiki-http-url-encode (cadr loc) 'iso-8859-1)
	 (cadr new-loc))
	(string=
	 (pmwiki-http-url-encode (cadr loc) 'utf-8)
	 (cadr new-loc)))
       (or
	(string= (caddr loc) (caddr new-loc))
	(string=
	 (pmwiki-http-url-encode (caddr loc) 'iso-8859-1)
	 (caddr new-loc))
	(string=
	 (pmwiki-http-url-encode (caddr loc) 'utf-8)
	 (caddr new-loc)))))

;; FIXME: a workaround for older versions of url package
(defun pmwiki-default-save-cont (&rest cbargs)
  (let* ((status (if (listp (car cbargs)) (car cbargs)
		  (subseq cbargs 0 -6)))
	 (url (nth (- (length cbargs) 6) cbargs))
	 (buf (nth (- (length cbargs) 5) cbargs))
	 (loc (nth (- (length cbargs) 4) cbargs))
	 (visited-locs (nth (- (length cbargs) 3) cbargs))
	 (asked-auth (nth (- (length cbargs) 2) cbargs))
	 (request-data (nth (- (length cbargs) 1) cbargs)))
    (when (and pmwiki-debug-level (<= 2 pmwiki-debug-level))
      (let ((page-text (buffer-substring (point-min) (point-max))))
	(with-current-buffer (get-buffer-create
			      (concat "*DEBUG-SAVE: " url "*"))
	  (insert page-text))))
    (goto-char (point-min))
    (if (not (member :redirect status))
	(let* ((authid
		(progn
		  (goto-char (point-min))
		  (re-search-forward
		   (regexp-quote"<input type='text' name='authid")
		   (point-max) t)))
	       (authpw
		(progn
		  (goto-char (point-min))
		  (re-search-forward
		   (regexp-quote"<input type='password' name='authpw'")
		   (point-max) t))))
	  (kill-buffer (current-buffer))
	  (if (or authpw authid)
	      (if asked-auth
		  (progn
		    (with-current-buffer buf (set-buffer-modified-p t))
		    (error "Wrong password (or user id)."))
		(when authid
		  (setq authid
			(read-string "User Authentication. Name: ")))
		(when authpw
		  (setq authpw
			(read-passwd "Edit Protected. Password: ")))
		(let* (
		       (url-request-method "POST")
		       (url-request-extra-headers
			'(("Content-Type" .
			   "application/x-www-form-urlencoded")))
		       (url-request-data
			(concat "authid=" (or authid "")
				"&authpw=" (or authpw "")
				"&" request-data)))
		  ;;(when authpw (clear-string authpw))
		  (url-retrieve url 'pmwiki-default-save-cont
				(list url buf loc visited-locs
				      (or authpw authid) url-request-data))))
	    (if pmwiki-verify-by-redirect
		(progn
		  (with-current-buffer buf (set-buffer-modified-p t))
		  (error (concat "Page could not be saved on " url ".")))
	      (message (concat "Page saved on " url ".")))))
      (let* ((new-url
	      ;;FIXME: which is better? (GET args to POST method?)
	      (pmwiki-merge-uri-args (cadr (member :redirect status)) url))
	     ;;(pmwiki-uri-no-args (cadr (member :redirect status))))
	     (new-loc (pmwiki-link-to-loc
		       (cadr (member :redirect status))))
	     (url-request-method "POST")
	     (url-request-extra-headers
	      '(("Content-Type" . "application/x-www-form-urlencoded")))
	     (url-request-data request-data)
	     (new-visited-locs (cons loc visited-locs)))
	;;FIXME: better to store server-side coding system
	;;       in a custom variable
	(when (and pmwiki-debug-level (<= 2 pmwiki-debug-level))
	  (push (cons (cons (pmwiki-equal-loc loc new-loc) loc) new-loc)
		pmwiki-debug-redirection-stack))
	(if (find-if
	     (lambda (arg) (pmwiki-equal-loc arg new-loc)) new-visited-locs)
	    (progn
	      (setq pmwiki-redirect-count pmwiki-max-redirections)
	      (message (concat "Page saved on " url ".")))
	  (if (not pmwiki-max-redirections)
	      (error "Page redirected, set `pmwiki-max-redirections'.")
	    (when (and pmwiki-redirect-count
		       (>= 0 pmwiki-redirect-count))
	      (error
	       "`pmwiki-mode' exceeded redirection count"))
	    (when (not pmwiki-redirect-count)
	      (setq pmwiki-redirect-count pmwiki-max-redirections))
	    (setq pmwiki-redirect-count (1- pmwiki-redirect-count))
	    (url-retrieve new-url 'pmwiki-default-save-cont
			  (list new-url buf new-loc new-visited-locs
			;;FIXME: cancel asked-auth after redirection?
				asked-auth
				request-data))))))))


(defun pmwiki-alternative-save-function ()
  "Save the current page to a PmWiki wiki."
  (let* ((cur-buffer (buffer-name))
	(loc pmwiki-location-list)
	(url (pmwiki-loc 'base))
	(passwd-auth (pmwiki-process-passwords loc))
	;; do not encode parameters because http-post does it
	(pagename (pmwiki-loc 'nameNA))
	(cur-fill-column fill-column)
	(text (if pmwiki-encode
		  (funcall pmwiki-encode (buffer-string))
		(buffer-string)))
	(request-data
	 (list 
		;;(cons "User-Agent" "Emacs pmwiki-mode")
		(cons "n" pagename)
		(cons "action" "edit")
		(cons "post" "1")
		(cons "author" pmwiki-author)
		(cons "authpw" (or (and passwd-auth (car passwd-auth)) ""))
		(cons "authid" (or (and passwd-auth (cdr passwd-auth)) ""))
		(cons "text" text))))
    (setq pmwiki-alternative-save-cbargs
	  (list url cur-buffer loc nil
		(and passwd-auth (or (car passwd-auth) (cdr passwd-auth)))
		request-data))
    (http-post url
	       request-data
	       'iso-8859-1
	       nil 'pmwiki-alternative-save-cont
	       nil (<= 1 pmwiki-debug-level))))

(defun pmwiki-alternative-save-cont (proc message)
  (let* ((cbargs pmwiki-alternative-save-cbargs)
	 (url (nth (- (length cbargs) 6) cbargs))
	 (buf (nth (- (length cbargs) 5) cbargs))
	 (loc (nth (- (length cbargs) 4) cbargs))
	 (visited-locs (nth (- (length cbargs) 3) cbargs))
	 (asked-auth (nth (- (length cbargs) 2) cbargs))
	 (request-data (nth (- (length cbargs) 1) cbargs)))
  (with-current-buffer (process-buffer proc)
    (when (and pmwiki-debug-level (<= 2 pmwiki-debug-level))
      (let ((page-text (buffer-substring (point-min) (point-max))))
	(with-current-buffer (get-buffer-create
			      (concat "*DEBUG-SAVE: " url "*"))
	  (insert page-text))))
    (goto-char (point-min))
    (let* ((authid
	    (progn
	      (goto-char (point-min))
	      (re-search-forward
	       (regexp-quote"<input type='text' name='authid")
	       (point-max) t)))
	   (authpw
	    (progn
	      (goto-char (point-min))
	      (re-search-forward
	       (regexp-quote"<input type='password' name='authpw'")
	       (point-max) t)))
	   (not-asked (not asked-auth))
	   (redirect-url
	     (progn
	       (goto-char (point-min))
	       (and
		(re-search-forward
		 "<title>\\(?:Redirect\\|301 Moved Permanently\\)</title>"
		 (point-max) t)
		(goto-char (point-min))
		(re-search-forward
		 "\\(?:URL=\\|href=\"\\)\\(.*?\\)\\(?:'\\|\"\\)"
		 (point-max) t)
		(match-string 1)))
	     )
	   (failed
	    (progn
	       (goto-char (point-min))
	       (and
		(re-search-forward
		 "<title>\\(403 Forbidden\\)</title>"
		 (point-max) t)
		(match-string 1)
		))
	    ))
      (kill-buffer (current-buffer))
      (cond
       (failed
	(error (concat "Saving failed because: " failed)))
       ((and (not redirect-url) (or authpw authid) asked-auth)
	(with-current-buffer buf (set-buffer-modified-p t))
	(error "Wrong password (or user id)."))
       ((and (not redirect-url) (or authpw authid))
	(when authid
	  (setq authid
		(read-string "User Authentication. Name: ")))
	(when authpw
	  (setq authpw
		(read-passwd "Edit Protected. Password: ")))
      (let* (
	(new-request-data
	 (append
	  (list (cons "authpw" (or authpw ""))
		(cons "authid" (or authid "")))
	  request-data)))
	;;(when authpw (clear-string authpw))
	(setq pmwiki-alternative-save-cbargs
	      (list url buf loc visited-locs (or authpw authid)
		    new-request-data))
	(http-post url
		   new-request-data
		   'iso-8859-1
		   nil 'pmwiki-alternative-save-cont
		   nil (<= 1 pmwiki-debug-level))))
       (redirect-url
      (let* ((new-url
	      ;;FIXME: which is better? (GET args to POST method?)
	      (pmwiki-merge-uri-args redirect-url url))
	     ;;(pmwiki-uri-no-args redirect-url))
	     (new-loc (pmwiki-link-to-loc
		       redirect-url))
	     (new-visited-locs (cons loc visited-locs)))
	;;FIXME: better to store server-side coding system
	;;       in a custom variable
	(if (find-if
	     (lambda (arg) (pmwiki-equal-loc arg new-loc)) new-visited-locs)
	    (progn
	      (setq pmwiki-redirect-count pmwiki-max-redirections)
	      (message (concat "Page saved on " url ".")))
	  (if (not pmwiki-max-redirections)
	      (error "Page redirected, set `pmwiki-max-redirections'.")
	    (when (and pmwiki-redirect-count
		       (>= 0 pmwiki-redirect-count))
	      (error
	       "`pmwiki-mode' exceeded redirection count"))
	    (when (not pmwiki-redirect-count)
	      (setq pmwiki-redirect-count pmwiki-max-redirections))
	    (setq pmwiki-redirect-count (1- pmwiki-redirect-count))
	    (setq pmwiki-alternative-save-cbargs
		  (list new-url buf new-loc new-visited-locs
			;;FIXME: cancel asked-auth after redirection?
			asked-auth request-data))
	    (http-post new-url
		       request-data
		       'iso-8859-1
		       nil 'pmwiki-alternative-save-cont
		       nil (<= 1 pmwiki-debug-level))))))
       (pmwiki-verify-by-redirect
	(with-current-buffer buf (set-buffer-modified-p t))
	(error (concat "Page could not be saved on " url ".")))
       (t (message (concat "Page saved on " url "."))))))))



(defun pmwiki-next ()
  "Goto the next [[PmWiki link]]."
  (interactive)
  (let ((case-fold-search nil))
    (re-search-forward pmwiki-link-pattern
     nil t)))

(defun pmwiki-prev ()
  "Goto the previous [[PmWiki link]]."
  (interactive)
  (let ((case-fold-search nil))
    (re-search-backward pmwiki-link-pattern
     nil t)))


(defun pmwiki-follow ()
  "Goto (open) the page/anchhor pointed to by the PmWiki-link at point."
  (interactive)
  (let ((loc (pmwiki-loc-at-point)))
    (if (or (cadr loc) (caddr loc))
	(pmwiki-edit (pmwiki-merge-loc loc))
      (if (cdddr loc)
	  (or (and (number-or-marker-p (cdddr loc)) (goto-char (cdddr loc)))
	   (re-search-forward (concat "\\[\\[##?" (cdddr loc) "\\]\\]") nil t)
	   (re-search-backward (concat "\\[\\[##?" (cdddr loc) "\\]\\]")))
	nil))))

(defun pmwiki-loc-at-point ()
  "Return location list for PmWiki link at point of the current buffer.

If no link is found at the current point, nil is returned.
See `pmwiki-location-list'."
  (interactive)
  (let ((case-fold-search nil)
	(found-full-link (thing-at-point-looking-at pmwiki-link-pattern)))
    (if found-full-link
	(let ((maybe-link (match-string 1)))
	  (message (concat "maybe-link: " maybe-link))
	  (pmwiki-link-to-loc maybe-link))
      nil))) ; not looking at [[ ... ]]


(defun pmwiki-buffer-loc-list (&optional buf)
  "Return location list for buffer BUF."
  (if buf
      (save-excursion
	(set-buffer buf)
	pmwiki-location-list)
    pmwiki-location-list))


(defun pmwiki-buffer-uri (&optional buf)
  "Return URI of page in buffer BUF, or if BUF is not given, in current buffer."
  (interactive "b")
  (pmwiki-loc 'URI (pmwiki-buffer-loc-list buf)))


(defun pmwiki-browse (&optional buf)
  "Open the buffer BUF in a browser. If BUF is not given,
the current buffer is used."
  (interactive)
  (browse-url (pmwiki-buffer-uri buf)))


(defun pmwiki-open (name)
  "Open a page specified by NAME from the current wiki engine, or
open page specified by a URI."
  (interactive "sName or URI (ex: Main.WikiSandbox): ")
  (setq pmwiki-redirect-count pmwiki-max-redirections)
  (let ((loc (pmwiki-merge-loc (pmwiki-link-to-loc name))))
    (if (car loc)
	;; additional merge to allow default wikipage on site
	(pmwiki-edit (pmwiki-merge-loc loc '(nil "Main" "HomePage")))
      (message
       (concat "No page URI given, assuming site is " pmwiki-default-site))
      (sleep-for 1) 			; Pause 1 second to show message
      (pmwiki-edit (pmwiki-merge-loc loc (pmwiki-link-to-loc
					  pmwiki-default-uri))))))

(defun pmwiki-reload ()
  "Reload the current page from the wiki engine."
  (interactive)
  (setq pmwiki-redirect-count pmwiki-max-redirections)
  (unless pmwiki-location-list
    (error "pmwiki-reload: `pmwiki-location-ilst' is empty!"))
  (pmwiki-edit `(,(car pmwiki-location-list)
		   ,(cadr pmwiki-location-list)
		   ,(caddr pmwiki-location-list) .
		   ,(point)) (current-buffer)))


(defun pmwiki-save ()
  "Uploads current buffer to the wiki."
  (interactive)
  (setq pmwiki-redirect-count pmwiki-max-redirections)
  (unless pmwiki-save-function (error "No save function specified"))
  (run-hooks 'pmwiki-save-before-hooks)
  (save-excursion (funcall pmwiki-save-function))
  (set-buffer-modified-p nil))


(defun pmwiki-save-to-loc (loc)
  "Uploads current buffer to a PAGE-URI (allows you to store the buffer
under a new name, or in a different wiki)."
  (set 'pmwiki-location-list loc)
  (rename-buffer (pmwiki-loc 'nameNA))
  (pmwiki-save))


(defun pmwiki-save-as (name)
  "Uploads current buffer to a specific page on a wiki. This also
changes `pmwiki-page-uri', so future saves also goes to this page.
The argument NAME can be either a name (= <group>.<page>) or an URI.
An URI must begin with 'http'."
  (interactive "sUpload page as NAME or URI (ex: Main.WikiSandbox): ")
  (pmwiki-save-to-loc (pmwiki-link-to-loc name)))
      

(defun mywiki-save-as (name)
  "Save buffer to a certain <group>.<page> (=NAME) at main wiki"
  (interactive "sName (ex: Main.WikiSandbox): ")
  (let ((loc (pmwiki-merge-loc
	      (pmwiki-link-to-loc name)
	      (pmwiki-link-to-loc pmwiki-main-wiki-base-uri))))
    (message (concat "Saving to " (pmwiki-loc 'URINA loc)))
    (pmwiki-save-to-loc loc)))
	

(defun pmwiki-delete (name)
  "Delete page from the current wiki engine, specified by NAME which
can be empty (current buffer), a page name or a URI."
  (interactive "sDelete page (or empty for current page): ")
  (unless (string-equal name "")
    (pmwiki-open (pmwiki-link-to-loc name)))
  (erase-buffer)
  (insert "delete")
  (pmwiki-save)
  (kill-buffer nil)
  )

(defun pmwiki-rename (new-name)
  "Save current buffer under a new name and delete the original page."
  (interactive "sNew page name: ")
  (let ((old-page (pmwiki-loc 'nameNA)))
    (pmwiki-save-as new-name)
    (pmwiki-delete old-page)))

;;
;; Functions useful for configuration.
;;
(defun pmwiki-delayed-hook-longlines-mode-on ()
  "Hook that activates `longlines-mode' when Emacs has been idle for 1 s."
  (require 'longlines)
  (run-with-idle-timer
   1 nil
   (lambda (buf)
     (save-excursion
       (set-buffer buf)
       (message (concat "Enabling longlines-mode for " (buffer-name)))
       (longlines-mode-on)))
   (current-buffer)))

(defun pmwiki-delayed-hook-longlines-mode-showing-hard-newlines ()
  "Hook that activates `longlines-mode' when Emacs has been idle for 1 s,
and in addition runs it `longlines-show-hard-newlines'."
  (require 'longlines)
  (run-with-idle-timer
   1 nil
   (lambda (buf)
     (save-excursion
       (set-buffer buf)
       (message (concat "Enabling longlines-mode for " (buffer-name)))
       (longlines-mode-on)
       (longlines-show-hard-newlines)))
   (current-buffer)))



(defun mywiki-open (name)
  "Open page NAME from main wiki (or a page specified by an URI).
Ex: 'Main.WikiSandbox' will open the page
   http://.../Main/WikiSandbox
Note when NAME is an URI, the page doesn't have to belong to the main wiki."
  (interactive "sName (default Main.HomePage): ")
  (setq pmwiki-redirect-count pmwiki-max-redirections)
  (pmwiki-edit (pmwiki-merge-loc
		(pmwiki-link-to-loc name)
		(pmwiki-link-to-loc pmwiki-main-homepage-uri))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                         mmm-mode support

(defvar pmwiki-running-mmm nil
  "Whether `mmm-mode' is installed.")
(when
 (require 'mmm-mode nil t)
 
 (setq pmwiki-running-mmm t)
 (setq mmm-global-mode 'maybe)

  (defun pmwiki-multi-source (lang mode name &optional insertchar)
  "Add submode for source code.
Add submode MODE (function toggling the mode) for language LANG
(string with the SourceBlock name of language) as NAME (any symbol).
INSERTCHAR is the character to insert the source markup with
[C-c % INSERTCHAR] sequence."
    (interactive)
    (mmm-add-classes
     (if insertchar
	 `((,name
	    :submode ,mode
	    :face mmm-code-submode-face
	    :front ,(concat "(:source lang=" lang ".*?:)")
	    :back "(:sourcend:)"
	    :insert ((,insertchar ocaml-source .
				  (nil @ "(:source lang=" ,lang ":)" \n @
					 _ @ \n "(:sourcend:)" @)))))
       `((,name
	  :submode ,mode
	  :face mmm-code-submode-face
	  :front ,(concat "(:source lang=" lang ".*?:)")
	  :back "(:sourcend:)"))))
    (mmm-add-mode-ext-class 'pmwiki-mode nil name))
;;"

;; set auctex-mode to work within pmwiki-mode for jsMath
  (mmm-add-classes
   '((pmwiki-jsmath-latex
      :submode latex-mode
      :face mmm-declaration-submode-face
      :front "\\({\\)$$?"
      :back "$?$\\(}\\)"
      :front-match 1
      :back-match 1
      :insert ((?$ inline-math . (nil @ "{" @ "$" _ "$" @ "}" @ ))
;;"
	       (?[ math . (nil @ "{" @ "$$" _ "$$" @ "}" @ ))))))


  (mmm-add-mode-ext-class 'pmwiki-mode nil 'pmwiki-jsmath-latex)

   ;; for some reason, testing for `mmm-font-lock-mode' doesn't work for me
   (defun mmm-fontify-region (start stop &optional loudly)
     "Fontify from START to STOP keeping track of submodes correctly."
     (when loudly
       (message "Fontifying %s with submode regions..." (buffer-name)))
     ;; Necessary to catch changes in font-lock cache state and position.
     (mmm-save-changed-local-variables
      mmm-current-overlay mmm-current-submode)
     ;; For some reason `font-lock-fontify-block' binds this to nil, thus
     ;; preventing `mmm-beginning-of-syntax' from doing The Right Thing.
     ;; I don't know why it does this, but let's undo it here.
     (let ((font-lock-beginning-of-syntax-function 'mmm-beginning-of-syntax))
       (mapc #'(lambda (elt)
		 (mmm-fontify-region-list (car elt) (cdr elt)))
	     (mmm-regions-alist start stop)))
     ;; With jit-lock, this causes blips in the mode line and menus.
     ;; Shouldn't be necessary here, since it's in post-command-hook too.
     ;;(mmm-update-submode-region)
     (when loudly (message nil)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                            Menu support
  
(defvar pmwiki-mode-map (make-sparse-keymap)
  "Keymap for Pmwiki Mode.")

(define-key pmwiki-mode-map (kbd "C-c C-p") 'pmwiki-prev)
(define-key pmwiki-mode-map (kbd "C-c C-n") 'pmwiki-next)
(define-key pmwiki-mode-map (kbd "C-c C-f") 'pmwiki-follow)
(define-key pmwiki-mode-map (kbd "C-c C-g") 'pmwiki-follow)
(define-key pmwiki-mode-map (kbd "C-c C-o") 'pmwiki-open)
(define-key pmwiki-mode-map (kbd "C-c C-c") 'pmwiki-save)
(define-key pmwiki-mode-map (kbd "C-c C-w") 'pmwiki-save-as)
(define-key pmwiki-mode-map (kbd "C-c C-b") 'pmwiki-browse)
(define-key pmwiki-mode-map (kbd "C-c C-m") 'pmwiki-map-site)
(define-key pmwiki-mode-map (kbd "C-c C-s") 'pmwiki-search)
(define-key pmwiki-mode-map (kbd "C-c C-t") 'pmwiki-toc)
(define-key pmwiki-mode-map (kbd "C-c C-r") 'pmwiki-reload)

(easy-menu-define pmwiki-menu (list pmwiki-mode-map)
  "PmWiki mode map."
  '("PmWiki"
    ["Open" pmwiki-open]
    ["Save" pmwiki-save]
    ["Save As" pmwiki-save-as]
    ["My Wiki" mywiki-open]
    "---"
    ["Backward" pmwiki-backward]
    ["Forward" pmwiki-forward]
    ["Reload" pmwiki-reload]
    ["Browse" pmwiki-browse]
    "---"
    ["Previous Link" pmwiki-prev]
    ["Next Link" pmwiki-next]
    ["Follow Link" pmwiki-follow]
    "---"
    ("Search" ["search for..." pmwiki-search t])
    ("ToC" ["rescan..." pmwiki-toc t])
    ("SiteMap" ["rescan..." pmwiki-rescan-pages t])
    "---" "Opened Pages"
    ))
(define-key pmwiki-mode-map [menu-bar pmwiki-menu] 'pmwiki-menu)

(defvar pmwiki-site-maps-alist nil
  "Mapping from wikiengine addresses to site maps.")
(defvar pmwiki-page-toc nil
  "Current buffer table of contents.")
(make-variable-buffer-local 'pmwiki-page-toc)

(defcustom pmwiki-always-rescan-toc t
  "If nil, don't rescan text for headings each time menu is clicked.")

(defun pmwiki-build-menu ()
  "Build a menu for buffer, after `pmwiki-location-list' has been set."
  (when (or pmwiki-always-rescan-toc (not pmwiki-page-toc))
    (setq pmwiki-page-toc (pmwiki-create-toc)))
  (easy-menu-change '("PmWiki") "ToC" pmwiki-page-toc)
  (let ((site-map (assoc (pmwiki-loc 'base) pmwiki-site-maps-alist)))
    (if site-map
	(easy-menu-change '("PmWiki") "SiteMap" (cdr site-map))
      (easy-menu-change '("PmWiki") "SiteMap"
			'(["rescan..." pmwiki-rescan-pages t])))))

(defun pmwiki-toc ()
  "Refresh Table of Contents menu."
  (interactive)
  (setq pmwiki-page-toc (pmwiki-create-toc))
  (easy-menu-change '("PmWiki") "ToC" pmwiki-page-toc)
  (when pmwiki-ee (pmwiki-ee-menubar-sitemap)))


(defvar pmwiki-arrived-from-ee nil
  "A variable to store the window in which the calling ee-menubar resided.")

(defun pmwiki-map-site (&optional arg)
  "Access the \"SiteMap\" menu, with prefix: rescan the site map."
  (interactive "P")
  (if (or arg (>= 1 (length pmwiki-pages-menu)))
      (call-interactively 'pmwiki-rescan-pages)
    (setq pmwiki-current-buffer (current-buffer))
    (when pmwiki-ee (pmwiki-ee-menubar-sitemap))))
      

(defcustom pmwiki-toc-entry-regexp
  "^\\(!+\\)\\s-*\\([^!].*\\)$"
  "Regexp matching table of contents entry (e.g. (sub)chapter title).
First submatch should match a string designating hierarchy depth,
second submatch should match the title.")

(defcustom pmwiki-pages-entry-regexp
  (concat "\\(?:<a class='\\(?:wiki\\|self\\)link'"
	  " href='.*?\\(?:\\?n=\\|/\\)\\|"
	  "href='[^?]*\\?n=\\)"
	  "\\(\\w+\\)[./]\\(\\w+\\)'") ;;FIXME: recognize URL-escaped names
  "Regexp matching pagelist page link.
First submatch should match a group, second should match a page title.")

(defvar pmwiki-current-buffer nil)


(defun pmwiki-cut-menu-entry (str)
  "Formats the menu entry string."
  (if (< (length str) pmwiki-menu-entry-max-length) str
    (concat (substring str 0 (- pmwiki-menu-entry-max-length 2)) "...")))

(defun pmwiki-flatten (elems)
  "Flatten a list of lists, keep non-list elements, "
  (if (consp elems)
      (if (listp (car elems))
	  (append (car elems) (pmwiki-flatten (cdr elems)))
	(cons (car elems) (pmwiki-flatten (cdr elems))))
    elems))

(defun pmwiki-create-toc ()
  "Parse the buffer and gather (sub)chapter info for table of contents menu."
  (save-excursion
    (let ((last-depth 0) (depth) (diff)
	  (menu-stack (list (list ["Rescan..." pmwiki-toc t]))))
      (goto-char (point-min))
      (setq debtrace "")
      (while (re-search-forward pmwiki-toc-entry-regexp (point-max) t)
	(let* ((p (make-marker))
	       (refname
		(pmwiki-cut-menu-entry
		 (pmwiki-render-string-no-properties
		  (match-string-no-properties 2))))
	       (ref (list (vector "-->" (list 'pmwiki-goto p) t)
			  refname))
	       (leafref (vector refname (list 'pmwiki-goto p) t)))
					; heading goes last
	  (set-marker p (point))
	  (setq depth (length (match-string 1)))
	  (setq diff (- last-depth depth))
	  (while (> -1 diff)
	    (setq diff (1+ diff))
	    (setcar menu-stack (cons (list "...") (car menu-stack)))
	    (setq menu-stack (cons (list "...") menu-stack)))
	  (when (= -1 diff)
	    (setq diff (1+ diff))
	    (setcar menu-stack (cons (list nil) (car menu-stack)))
	    (setq menu-stack (cons (list nil) menu-stack))
	    )
	  (while (<= 0 diff)
	    (setq diff (1- diff))
	    (if (< 2 (length (car menu-stack)))
		(setcar (cadr menu-stack) (nreverse (car menu-stack))))
	    (pop menu-stack))
	  (setcar menu-stack (cons leafref (car menu-stack)))
	  (setq menu-stack (cons ref menu-stack))
	  (setq last-depth depth)))
      (while (cdr menu-stack)
	(if (< 2 (length (car menu-stack)))
	    (setcar (cadr menu-stack) (nreverse (car menu-stack))))
	(pop menu-stack))
      (pmwiki-flatten (nreverse (car menu-stack))))))


(defun pmwiki-rescan-pages (listpage)
  "Ask the server for pagelist and scan the results into hierarchical menu.
LISTPAGE defaults to `pmwiki-default-pagelist-page'."
  (interactive "sPage with pagelist (default `Site.SideBar'): ")
  ;;FIXME: how to change interactive prompt? can't customize default
;;   (interactive (concat "sPage with pagelist on " (pmwiki-loc 'site)
;; 		       " (default `" pmwiki-default-pagelist-page "'): "))
  (message "Creating page list...")
  (setq pmwiki-current-buffer (current-buffer))
  (funcall pmwiki-pagelist-function
	   (or (and (not (string= listpage "")) listpage) "Site.SideBar")))

(defun pmwiki-rescan-pages-cont (base menu)
  (if (assoc base pmwiki-site-maps-alist)
      (setcdr (assoc base pmwiki-site-maps-alist) menu)
    (push (cons base menu) pmwiki-site-maps-alist))
  (with-current-buffer pmwiki-current-buffer
    (easy-menu-change '("PmWiki") "SiteMap" menu)
    (setq pmwiki-current-buffer (current-buffer))
    (when pmwiki-ee (pmwiki-ee-menubar-sitemap))
    (message "Creating page list...done")))

(defun pmwiki-search (search-term)
  "Ask the server for pagelist and scan the results into hierarchical menu.
LISTPAGE defaults to `pmwiki-default-pagelist-page'."
  (interactive "sSearch for (default: go to last search results): ")
;;   (interactive (concat "sSearch " (pmwiki-loc 'site)
;; 		       " for: "))
  (message "Creating search page list...")
  (if (or (not search-term) (string= search-term ""))
      (when pmwiki-ee
	(setq pmwiki-current-buffer (current-buffer))
	(pmwiki-ee-menubar-search))
    (setq pmwiki-current-buffer (current-buffer))
    (setq pmwiki-last-search-term search-term)
    (funcall pmwiki-search-function search-term)))

(defun pmwiki-search-cont (base pages-menu)
  (with-current-buffer pmwiki-current-buffer
    (easy-menu-change '("PmWiki") "Search"
		      (cons ["search for..." pmwiki-search t]
			    pages-menu))
    (when pmwiki-ee (pmwiki-ee-menubar-search))
    (message "Creating search results...done")))

(defun pmwiki-goto (pos)
  (when pmwiki-arrived-from-ee
    (if pmwiki-keep-ee-window
	(let ((buf (current-buffer)))
	  (switch-to-buffer pmwiki-arrived-from-ee t)
	  (switch-to-buffer-other-window buf t))
      (when (< 1 (length (window-list))) (delete-window))
      ;;FIXME: in general, should we switch to buf (parent buffer)
      ;;       after deleting window? (doesn't change behaviour here)
      ))
  (setq pmwiki-arrived-from-ee nil)
  (goto-char pos)
  (recenter))

(defun pmwiki-goto-page (loc)
  (when pmwiki-arrived-from-ee
    (if pmwiki-keep-ee-window
	(let ((buf (current-buffer)))
	  (switch-to-buffer pmwiki-arrived-from-ee t)
	  (switch-to-buffer-other-window buf t))
      (when (< 1 (length (window-list))) (delete-window))
      ;;FIXME: in general, should we switch to buf (parent buffer)
      ;;       after deleting window? (doesn't change behaviour here)
      ))
  (setq pmwiki-arrived-from-ee nil)
  (pmwiki-edit loc))

(defun pmwiki-split-on-regexp (string rexp &optional split-right)
  "Split STRING like with `split-string', but keep separators.
If SPLIT-RIGHT is nil, keep them in right part, else in left part.
If it is a number, move that far to the right."
    (let (
	  (start 0)
	  notfirst
	  (case-fold-search nil)
	  (list nil))
    (while (and (string-match rexp string
			      (if (< start (length string))
				  (1+ start) (1- (length string))))
		(< start (length string)))
      (setq notfirst t)
      (let ((split-point (cond
			  ((integerp split-right)
			   (+ (match-beginning 0) split-right))
			  (split-right (match-end 0))
			  (t (match-beginning 0)))))
	(setq list
	      (cons (substring string start split-point)
		    list))
	(setq start split-point)))
    (if (< start (length string))
	(setq list
	      (cons (substring string start)
		    list)))
    (nreverse list)))

(defun pmwiki-page-fullpath (group page)
  "Split group and page name into list of subgroups and page name words."
  (let ((subgroups (if pmwiki-pagelist-hyphen-subgroups
	      (pmwiki-split-on-regexp group pmwiki-pagelist-hyphen-regexp t)
	    (list group))))
    (append (subseq subgroups 0 -1)
	    (list (concat (car (last subgroups)) "/"))
	    ;; FIXME: "[:upper:][:lower:]" does not work?
	    (if pmwiki-pagelist-join-pages
		(apply
		 'append
		 (mapcar
		  (lambda (w) (pmwiki-split-on-regexp
			       w "[a-z][A-Z]" 1))
		  (pmwiki-split-on-regexp page "[A-Z][a-z]")))
		 ))))

(defun pmwiki-pagelist-defentry (site)
  "Easymenu entry to display at the beginning of SiteMap."
  (list ["Rescan..." pmwiki-rescan-pages t] site))

(defun pmwiki-pagelist-cont (&rest cbargs)
  "Parse the buffer and build a hierarchy of pages linked from there.
Buffer should contain html source of PmWiki page."
  (let* ((last-path nil)
	 (cont (nth (- (length cbargs) 7) cbargs))
	 (defentry (nth (- (length cbargs) 6) cbargs))
	 (search-term (nth (- (length cbargs) 5) cbargs))
	 (beg-regexp (nth (- (length cbargs) 4) cbargs))
	 (end-regexp (nth (- (length cbargs) 3) cbargs))
	 (base (nth (- (length cbargs) 2) cbargs))
	 (site (nth (- (length cbargs) 1) cbargs))
	 (menu-stack (list defentry))
	 (group-mem nil) (last-group "") endpoint)
    (goto-char (point-min))
    (setq endpoint
	  (or (re-search-forward (or  end-regexp "<!--PageFooterFmt-->")
				 (point-max) t)
	      (point-max)))
    (goto-char (point-min))
    (unless (re-search-forward (or  beg-regexp "<!--PageText-->")
		       (point-max) t)
      (goto-char (point-min)))
    (while (re-search-forward pmwiki-pages-entry-regexp (point-max) t)
      (let* ((group (match-string-no-properties 1))
	     (page (match-string-no-properties 2))
	     (loc `(,base ,group ,page .
			 ,(if search-term (cons 'search search-term))))
	     (fullpath (pmwiki-page-fullpath group page))
	     (path fullpath)
	     (refname (car (last fullpath)))
	     (leafref (vector refname `(pmwiki-goto-page
					(quote ,loc)) t)))
	  (unless (and (string= group last-group)
		       (member page group-mem))
	    (while (and path last-path (cdr path) (cdr last-path)
			(string= (car path) (car last-path)))
	      (pop path) (pop last-path))
	    (while (and last-path (cdr last-path))
	      (pop last-path)
	      (when (and (= 2 (length (car menu-stack)))
		       (not (consp (caar menu-stack))))
		(aset (caar menu-stack) 0
		      (concat (cadar menu-stack)
			      (aref (caar menu-stack) 0)))
		(setcar menu-stack (caar menu-stack)))
	      (setcar (cadr menu-stack)
		      (if (listp (car menu-stack))
			  (nreverse (car menu-stack)) (car menu-stack)))
	      (pop menu-stack))
	    (while (and path (cdr path))
	      (let ((current (pop path)))
		(setcar menu-stack (cons (list current) (car menu-stack)))
		(setq menu-stack (cons (list current) menu-stack))))
	    (setcar menu-stack (cons leafref (car menu-stack)))
	    (setq last-path fullpath)
	    (if (string= group last-group)
		(push page group-mem)
	      (setq group-mem (list page)))
	    (setq last-group group))))
      (while (cdr menu-stack)
	(when (and (= 2 (length (car menu-stack)))
		   (not (consp (caar menu-stack))))
	  (aset (caar menu-stack) 0
		(concat (cadar menu-stack)
			(aref (caar menu-stack) 0)))
	  (setcar menu-stack (caar menu-stack)))
	(setcar (cadr menu-stack)
		(if (listp (car menu-stack))
		    (nreverse (car menu-stack)) (car menu-stack)))
	(pop menu-stack))
      (kill-buffer (current-buffer))
      (funcall cont base (nreverse (car menu-stack)))))

(defvar pmwiki-render-string-no-properties-transforms
  '(
    ("\\(?:\\[\\[##?[A-Za-z0-9_---]*\\]\\]\\)" . "")
    ("\\(?:\\[\\[[^|]*| *\\(.+?\\)\\]\\]\\)" . "\\1")
    ("\\(?:\\[\\[\\(.+?\\) *->[^]]*\\]\\]\\)" . "\\1")
    ("\\(?:\\[\\[ *\\([^]|>]+?\\) *\\]\\]\\)" . "\\1")
    ("@@\\(.+?\\)@@" . "\\1")
    ("''\\(.+?\\)''" . "\\1")
    ("'''\\(.+?\\)'''" . "\\1")
    ("''''\\(.+?\\)''''" . "\\1")
    ("'^\\(.+?\\)^'" . "^\\1")
    ("'_\\(.+?\\)_'" . "_\\1")
    )
  "Regexps to remove markup from text.
See `pmwiki-render-string-no-properties'.")

(defun pmwiki-render-string-no-properties (str)
  "Remove markup from text so that it looks more like when browsing.
Currently only processes bracketed links."
  (interactive)
  (reduce (lambda (accum transf) 
	    (replace-regexp-in-string (car transf) (cdr transf) accum))
	  pmwiki-render-string-no-properties-transforms
	  :initial-value str))

(provide 'pmwiki-mode)
;;; pmwiki-mode.el ends here


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          menu in buffer: ee

(defvar pmwiki-display-result 'switch-to-buffer-other-window
  "A function to display `ee' buffers. Try the following:
`switch-to-buffer-other-window', `display-buffer', `switch-to-buffer'.")

(defvar pmwiki-ee nil
  "If non-nil, ee is installed.")

(defcustom pmwiki-keep-ee-window nil
  "If nil, delete menu window after selecting, otherwise keep it.")

(when (and (require 'ee-autoloads nil t) (require 'ee-menubar nil t))
(setq pmwiki-ee t)

(defadvice ee-menubar-select (before pmwiki-remember-ee-window)
  "Set `pmwiki-arrived-from-ee' to the ee-menubar (i.e., current) buffer."
  (setq pmwiki-arrived-from-ee (current-buffer)))

(ad-activate 'ee-menubar-select)

(defvar pmwiki-ee-data-toc
  '[(meta
     (format-version . "0.0.1")
     (database-version . "0.0.1")
     (view-data-file . "view/menubar.ee")
     (collector . pmwiki-ee-data-collect-toc)
     (fields category name title level command help event binding ())
     (key-fields name category))])

(defvar pmwiki-ee-data-sitemap
  '[(meta
     (format-version . "0.0.1")
     (database-version . "0.0.1")
     (view-data-file . "view/menubar.ee")
     (collector . pmwiki-ee-data-collect-sitemap)
     (fields category name title level command help event binding ())
     (key-fields name category))])

(defvar pmwiki-ee-data-search
  '[(meta
     (format-version . "0.0.1")
     (database-version . "0.0.1")
     (view-data-file . "view/menubar.ee")
     (collector . pmwiki-ee-data-collect-search)
     (fields category name title level command help event binding ())
     (key-fields name category))])

;;; Data Extraction

(defun pmwiki-ee-data-collect-menu (data menu)
  (let ((old-data (if ee-data
                      (mapcar (lambda (r)
                                (ee-field 'name r))
                              (ee-data-records-find ee-data '(read . t)))))
        (new-data
         (ee-data-convert-lists-to-vectors
          (ee-menubar-data-collect-items
           (ee-data-field-names data)
           (with-current-buffer pmwiki-current-buffer
	     (tmm-get-keybind menu))
           0))))
    (aset new-data 0 (aref data 0))
    (if old-data
        (ee-data-records-do
         new-data
         (lambda (r ri)
           (if (member (ee-field 'name r) old-data)
               (ee-field-set 'read t r (ee-data-meta-setters-get-set new-data))))))
    new-data))

(defun pmwiki-ee-data-collect-search (data)
  (pmwiki-ee-data-collect-menu data [menu-bar PmWiki Search]))
(defun pmwiki-ee-data-collect-toc (data)
  (pmwiki-ee-data-collect-menu data [menu-bar PmWiki ToC]))
(defun pmwiki-ee-data-collect-sitemap (data)
  (pmwiki-ee-data-collect-menu data [menu-bar PmWiki SiteMap]))

(defun pmwiki-ee-menubar-search (&optional arg)
  "Categorized access to Emacs menu-bar."
  (interactive "P")
  (or (featurep 'tmm)
      (require  'tmm))
  ;; TODO: remove next two lines, when submenus will be implemented
  ;; as categories (not records) in the ee-menubar-c-tree-builder,
  ;; so ee-hidden-expansions could be used to retain opened menus
  (let ((bufname (format "*%s Search: %s*" ee-menubar-mode-name
			 pmwiki-last-search-term)))
    (if (get-buffer bufname)
	(funcall pmwiki-display-result bufname)
      (funcall pmwiki-display-result
	       (ee-view-buffer-create-noselect
		bufname
		ee-menubar-mode-name
		ee-menubar-keymap
		pmwiki-ee-data-search)))))

(defun pmwiki-ee-menubar-sitemap (&optional arg)
  "Categorized access to Emacs menu-bar."
  (interactive "P")
  (or (featurep 'tmm)
      (require  'tmm))
  ;; TODO: remove next two lines, when submenus will be implemented
  ;; as categories (not records) in the ee-menubar-c-tree-builder,
  ;; so ee-hidden-expansions could be used to retain opened menus
  (let ((bufname (format "*%s SiteMap: %s*" ee-menubar-mode-name
			 (with-current-buffer pmwiki-current-buffer
			   (pmwiki-loc 'site)))))
    (if (get-buffer bufname)
	(funcall pmwiki-display-result bufname)
      (funcall pmwiki-display-result (ee-view-buffer-create-noselect
       bufname
       ee-menubar-mode-name
       ee-menubar-keymap
       pmwiki-ee-data-sitemap)))))

(defun pmwiki-ee-menubar-toc (&optional arg)
  "Categorized access to Emacs menu-bar."
  (interactive "P")
  (or (featurep 'tmm)
      (require  'tmm))
  ;; TODO: remove next two lines, when submenus will be implemented
  ;; as categories (not records) in the ee-menubar-c-tree-builder,
  ;; so ee-hidden-expansions could be used to retain opened menus
  (let ((bufname (format "*%s: %s ToC*" ee-menubar-mode-name
			 (buffer-name pmwiki-current-buffer))))
    (if (get-buffer bufname)
	(funcall pmwiki-display-result bufname)
      (funcall pmwiki-display-result (ee-view-buffer-create-noselect
       bufname
       ee-menubar-mode-name
       ee-menubar-keymap
       pmwiki-ee-data-toc)))))

;; end (and (require 'ee-autoloads nil t) (require 'ee-menubar nil t))
)

(unless
 (require 'mmm-mode nil t)

  (defun pmwiki-multi-source (lang mode name &optional insertchar)
  "Add submode for source code.
Add submode MODE (function toggling the mode) for language LANG
(string with the SourceBlock name of language) as NAME (any symbol).
INSERTCHAR is the character to insert the source markup with
[C-c % INSERTCHAR] sequence."
    (interactive)
    (message "`pmwiki-multi-source': mmm-mode is not installed")
    (sleep-for 2)))
