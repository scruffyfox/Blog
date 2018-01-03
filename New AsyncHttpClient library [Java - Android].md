I've had the opportunity to re-write my AsyncHttpClient in my (deprecated) X-Library. It's given me the chance to really fix all the underlining issues that were in the old library, plus make some cool changes, like the ability to use HttpEntity rather than custom non-standard classes.

I've also managed to add some useful GZipping handling for both posting and getting.

You can download/fork/contribute to the library here: [https://github.com/scruffyfox/AsyncHttpClient](https://github.com/scruffyfox/AsyncHttpClient)

Or read the documentation here: [http://scruffyfox.github.com/AsyncHttpClient/](http://scruffyfox.github.com/AsyncHttpClient/)

This is the first draft of the library, so there'll probably still be a few bugs to iron out.