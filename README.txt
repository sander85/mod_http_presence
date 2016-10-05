This module will send HTTP POST request to specified URL with the following
parameters:

* If user changes status or logs in:
	specified_url -> action=status_change&user=user@example.com
* If user logs out:
	specified_url -> action=logout&user=user@example.com

How to configure:
  mod_http_presence:
    url: "http://example.com/your/code.php"
