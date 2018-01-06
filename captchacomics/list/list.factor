USING: captchacomics captchacomics.private ;
IN: captchacomics.listing

<PRIVATE

: archive-tags ( -- tags )
  captchacomics-url-prefix archive-path append scrape-html ;

PRIVATE>

: list-captchacomic-ids ( -- ids )
  ;

: list-captchacomics ( -- comics )
  archive-tags ;