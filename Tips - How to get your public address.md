# How to get you Public address

Using the ````Invoke-WebRequest```` Cmdlet, you can easily get your public Address.

The Site <http://Ipconfig.me> can provide this information

````powershell
Invoke-WebRequest -Uri "http://ipconfig.me"
StatusCode        : 200
StatusDescription : OK 8
Content           : xxx.xxx.xxx.xxx
RawContent        : HTTP/1.1 200 OK
                    Access-Control-Allow-Origin: *
                    Content-Length: 14
                    Content-Type: text/plain; charset=utf-8
                    Date: Mon, 20 Jul 2020 05:46:50 GMT
                    Via: 1.1 google

                    xxx.xxx.xxx.xxx
Forms             : {}
Headers           : {[Access-Control-Allow-Origin, *], [Content-Length, 14], [Content-Type, text/plain;
                    charset=utf-8], [Date, Mon, 20 Jul 2020 05:46:50 GMT]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
````

And now, if you focus only on the property **Content**, this return the only information we're looking for : Public IP Address

````powershell
(Invoke-WebRequest -Uri "http://ipconfig.me").content
xxx.xxx.xxx.xxx
````

Simple, isn't it ?

Hope this help.
