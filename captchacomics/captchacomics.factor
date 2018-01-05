USING: accessors assocs classes combinators.short-circuit
html.parser.analyzer images images.http images.viewer kernel
math math.parser sequences splitting strings ui ;
IN: captchacomics

<PRIVATE

CONSTANT: captchacomics-url-prefix "http://captchacomics.com/"
CONSTANT: index-query "index.php?i="
CONSTANT: images-path "images/"

TUPLE: comic { data image } { name string } { id number } ;

: normalize-id ( string/number -- number )
  dup class-of string = [ string>number ] when ;

: get-comic-image ( filename -- image ) cc-url-prefix prepend load-http-image ;

: comic-data ( url -- tags )
  scrape-html nip [
    { [ name>> "img" = ] [ attributes>> "alt" of ] } 1&&
  ] find-all
  first second attributes>> ;

: <comic> ( data name id -- comic )
  comic boa ;

: id>comic-url ( id -- url )
  normalize-id [ cc-url-prefix index-query append ] dip number>string append ;

: id>comic-image ( id -- image )
  id>comic-url comic-data "src" of get-comic-image ;

: id>comic-name ( id -- name )
  id>comic-url comic-data "alt" of "\n" ?tail drop ;

: id>comic ( id -- comic )
  [ id>comic-image ]
  [ id>comic-name ]
  [ normalize-id ]
  tri <comic> ;

: display-comic ( comic -- )
  [ data>> <image-gadget> ]
  [ id>> number>string ]
  [ name>> "\n" "|" replace ]
  tri ": " glue open-window ;

PRIVATE>

: captchacomic ( id -- comic )
  id>comic ;

: captchacomic. ( id -- )
  captchacomic display-comic ;
