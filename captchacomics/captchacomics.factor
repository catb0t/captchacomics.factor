USING: accessors assocs classes combinators
combinators.short-circuit command-line formatting html.parser
html.parser.analyzer http.client images images.http
images.viewer io kernel math math.order math.parser namespaces
random.private regexp sequences splitting strings summary typed
ui ui.gadgets.scrollers ;
IN: captchacomics

<PRIVATE

TUPLE: comic { data image } { name string } { id number } ; final
SINGLETONS: latest random ;

CONSTANT: captchacomics-url "http://captchacomics.com/"
CONSTANT: index-query "index.php?i="
CONSTANT: archive-path "archive.php"

GENERIC: normalize-id ( object -- clean-id )
ERROR: id-too-big ;

DEFER: highest-id
DEFER: (scrape-html)
DEFER: (id-bounds-check)

M: id-too-big summary
  drop "id not less than or equal to highest" sprintf ;

M: string normalize-id
  string>number dup (id-bounds-check) ;

M: fixnum normalize-id
  dup (id-bounds-check) ;

M: latest normalize-id
  drop highest-id ;

M: random normalize-id
  drop highest-id 1 + random-integer ;

: highest-id ( -- id )
  captchacomics-url archive-path append http-get nip
  R/ [0-9]{1,4}.&nbsp;/ first-match
  [ from>> ] [ to>> ] [ seq>> ] tri
  subseq "." split1 drop string>number ;

: (id-bounds-check) ( id -- )
  highest-id < not [ id-too-big throw ] when ; inline

: (scrape-html) ( url -- page )
  http-get nip "<br>" "\n" replace parse-html ; inline

: get-comic-image ( filename -- image )
  captchacomics-url prepend load-http-image ; inline

: scrape-src ( parsed -- tags )
  [ {
    [ name>> "img" = ]
    [ attributes>> "alt" of ]
    [ attributes>> "src" of ] }
    1&&
  ] find-all
  first second attributes>> "src" of ;

: comic-name ( parsed -- name )
  "description" find-by-class-between
  [ name>> text = ] filter [ text>> ] map
  ", " join "\n" ?tail drop ;

: comic-image ( parsed -- image )
  scrape-src get-comic-image ; inline

: <comic> ( data name id -- comic )
  comic boa ; inline

: id>comic-url ( clean-id -- url )
  [ captchacomics-url index-query append ] dip
  number>string append ;

: id>comic ( id -- comic )
  normalize-id dup
  [
    id>comic-url (scrape-html)
    [ comic-image ]
    [ comic-name ]
    bi
  ] dip
  <comic> ;

: display-comic ( comic -- )
  [ data>> <image-gadget> <scroller> ]
  [ id>> number>string ]
  [ name>> "\n" "|" replace ]
  tri ": " glue open-window ;

PRIVATE>

: captchacomic ( id -- comic )
  id>comic ;

: captchacomic. ( id -- )
  captchacomic display-comic ;

: random-captchacomic  ( -- comic ) random captchacomic ; inline
: random-captchacomic. ( -- )       random captchacomic. ; inline

: latest-captchacomic ( -- comic ) latest captchacomic ; inline
: latest-captchacomic. ( -- )      latest captchacomic. ; inline

TYPED: (captchacomics-main) ( value: string -- )
  {
    { [ dup "latest" = ] [ drop latest-captchacomic. ] }
    { [ dup "random" = ] [ drop random-captchacomic. ] }
    { [ dup string>number dup (id-bounds-check) ] [ captchacomic. ] }
    [ drop random-captchacomic. ]
  } cond ;

: captchacomics-main ( -- )
  [
    command-line get dup length 0 >
    [ first ]
    [ drop "latest" ] if
    (captchacomics-main)
  ] with-ui ;

MAIN: captchacomics-main
