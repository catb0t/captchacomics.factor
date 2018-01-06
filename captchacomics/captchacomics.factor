USING: accessors assocs classes combinators.short-circuit
formatting html.parser html.parser.analyzer http.client images
images.http images.viewer kernel math math.order math.parser
random.private sequences splitting strings summary ui
ui.gadgets.scrollers ;
IN: captchacomics

<PRIVATE

DEFER: highest-id
DEFER: (scrape-html)

CONSTANT: captchacomics-url "http://captchacomics.com/"
CONSTANT: index-query "index.php?i="
CONSTANT: archive-path "archive.php"

TUPLE: comic { data image } { name string } { id number } ;

ERROR: id-too-big ;

M: id-too-big summary
  drop highest-id "id not less than or equal to highest %d" sprintf ;

: highest-id ( -- id )
  captchacomics-url archive-path append
  (scrape-html) [
    ! somehow, this works to get the elements we want
    { [ name>> "td" = ] [ attributes>> "valign" of "top" = ] }
    1&& ! bi and
  ] find-between-all ! contents of matching tags
  [
    [ name>> text = ] filter ! text objects
    first text>> "." split   ! cut the ####.&nbsp;
    first string>number      ! drop the suffix
  ] map
  [ ] filter ! remove f
  0 [ max ] reduce ; ! highest

: normalize-id ( string/number -- number )
  ! only strings and integers are acceptable
  dup class-of string = [
    ! compute highest-id once and put it here
    dup [ highest-id ] dip
    "random" =
    [ drop 1 + random-integer ] ! make a random number
    [ over string>number <= [ id-too-big throw ] when ] ! range check and throw
    if
  ] when ;

: get-comic-image ( filename -- image )
  captchacomics-url prepend load-http-image ;

: scrape-src ( parsed -- tags )
  [ {
    [ name>> "img" = ]
    [ attributes>> "alt" of ]
    [ attributes>> "src" of ] }
    1&&
  ] find-all
  first second attributes>> "src" of ;

: scrape-name ( parsed -- name )
  "description" find-by-class-between
  [ name>> text = ] filter [ text>> ] map
  ", " join "\n" ?tail drop ;

: <comic> ( data name id -- comic )
  comic boa ;

: id>comic-url ( id -- url )
  normalize-id
  [ captchacomics-url index-query append ] dip
  number>string append ;

: (scrape-html) ( url -- page )
  http-get nip "<br>" "\n" replace parse-html ;

: comic-image ( parsed -- image )
  scrape-src get-comic-image ;

: comic-name ( parsed -- name )
  scrape-name ;

: id>comic ( id -- comic )
  [
    id>comic-url (scrape-html)
    [ comic-image ]
    [ comic-name ]
    bi
  ]
  [ normalize-id ]
  bi <comic> ;

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

: random-captchacomic  ( -- comic )
  highest-id 1 + random-integer captchacomic ;
: random-captchacomic. ( -- )
  random-captchacomic display-comic ;
