USING: captchacomics captchacomics.private tools.test ;
IN: captchacomics.tests

{ 1 } [ 1 (id-bounds-check) ] unit-test
{ 112 } [ 112 (id-bounds-check) ] unit-test
{ 112 } [ -112 (id-bounds-check) ] unit-test
{ 2921 } [ highest-id (id-bounds-check) ] unit-test
{ 2921 } [ 9999 (id-bounds-check) ] unit-test

{ "http://captchacomics.com/index.php?i=123" } [ 123 id>comic-url ] unit-test

{ } [ 1 captchacomic. ] unit-test
{ } [ random-captchacomic. ] unit-test
{ } [ 2921 captchacomic. ] unit-test
{ } [ latest-captchacomic. ] unit-test
