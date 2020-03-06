# ayehu_alert.pl
### Derek Pascarella <derekp@ayehu.com>
### Ayehu, Inc.
---

**Requirements:**
* Perl (Ships with required libraries by default on all major Linux/UNIX/BSD distributions)
* HTTP::Tiny (Perl library)
* JSON (Perl library)
* Getopt::Long (Perl library)

For Windows support, you have two options:
<br>
<ul>
  <li>Strawberry Perl distribution (<a href="http://strawberryperl.com/">http://strawberryperl.com/</a>), which ships with all three required libraries by default.</li>
  <li>Use the stand-alone executable (ayehu_alert.exe) and store your configuration file in <code>C:\ayehu.conf</code>.</li>
</ul>


**Usage:**
<br>
`ayehu_alert --host <LABEL> --mode <GET/POST> --sid <SESSION_ID> alertKey1 "alert value 1" alertKey2 "alert value 2"`


**Configuration (modify script to point to the location of your .conf file):**
<br>
`/etc/ayehu.conf`

This utility acts as a powerful and easy-to-use abstraction layer for the Ayehu NG Web Service API. This API allows data to
be sent to an Ayehu NG server via HTTP POST requests. The API also supports GET requests for retrieving the response from a
WebServiceResponse activity used in an Ayehu NG workflow.

This utility eliminates the need for writing from scratch a program or script to manually send HTTP POST and GET requests
to an Ayehu NG server, freeing up valuable time and allowing users to begin quickly and effectively communicating between
an external Linux/UNIX/BSD/MacOS system and an Ayehu NG server.

If any parameter or argument is missing, invalid, or malformed, a detailed error will be returned. Should there be a
problem sending a request, the response message will contain a reason for the failure.

The first step to utilizing this tool is creating a configuration file (by default `/etc/ayehu.conf`, `C:\ayehu.conf` on Windows). The format is as
follows:
<br>
`HostLabel|TargetURL|Secret`


**Example:**
<br>
`MyAyehuServer|http://1.2.3.4:8888/AyehuAPI/|p@$$w0rd`

To send a POST request to an Ayehu NG server, a command like this would be executed:
<br>
`ayehu_alert --host MyAyehuServer --mode POST FirstName Derek`

The response would resemble this:
<br>
```
Status:         Success
Session ID:     dfe002cd-9593-4e85-830a-55a4bd8b2e0d
Payload:        {"root":{"item":{"auth":"p@$$w0rd","sessionid":"0","FirstName":"Derek"}}}
```

After receiving this message, an Ayehu NG server may be configured to trigger a workflow that contains a WebServiceResponse
activity containing the message "Hi %FirstName%, what's your age?" To retrieve this message, a GET request would be sent,
along with the session ID returned by the previous command, by executing a command like this:
<br>
`ayehu_alert --host MyAyehuServer --mode GET --sid dfe002cd-9593-4e85-830a-55a4bd8b2e0d`

The response would resemble this:
<br>
```
Status:     Success
Response:   Hi Derek, what's your age?
```

To respond to the WebServiceResponse activity, another POST request can be sent containing the session ID and a key named
"message" with a response as its value. This is achieved with a command like this:
<br>
`ayehu_alert --host MyAyehuServer --mode POST --sid dfe002cd-9593-4e85-830a-55a4bd8b2e0d message 100`

The response would resemble this:
<br>
```
Status:         Success
Session ID:     dfe002cd-9593-4e85-830a-55a4bd8b2e0d
Payload:        {"root":{"item":{"auth":"p@$$w0rd","message":"100","sessionid":"dfe002cd-9593-4e85-830a-55a4bd8b2e0d"}}}
```

The process of retrieving additional messages sent by the WebServiceResponse activity can continue with more GET requests
like this:
<br>
`ayehu_alert --host MyAyehuServer --mode GET --sid dfe002cd-9593-4e85-830a-55a4bd8b2e0d`

The response would resemble this:
<br>
```
Status:         Success
Response:       Wow Derek, you're 100 years old!
```

For more information on building Ayehu NG workflows with WebServiceResponse activities for bi-directional communication
between an external system and an Ayehu NG server, consult the documentation found in the Ayehu Support Portal:
* [Integrating with Ayehu NG Web Services](https://support.ayehu.com/hc/en-us/articles/360014152193-Integrating-with-Ayehu-NG-Web-Services)
* [Trigger Workflows remotely via Web Service API](https://support.ayehu.com/hc/en-us/articles/360034892433-Trigger-Workflows-remotely-via-Web-Service-API)
* [Bidirectional communication between a client and the Web Service API (WebServiceResponse)](https://support.ayehu.com/hc/en-us/articles/360037302894-Bidirectional-communication-between-a-client-and-the-Web-Service-API-WebServiceResponse-)
