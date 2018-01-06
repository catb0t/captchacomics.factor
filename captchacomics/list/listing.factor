USING: captchacomics captchacomics.private ;
IN: captchacomics.listing

<PRIVATE

CONSTANT: archive-path "archive.php"

: archive-tags ( -- tags )
  captchacomics-url-prefix archive-path append scrape-html ;

PRIVATE>

: list-captchacomics ( -- comics )
  archive-tags ;