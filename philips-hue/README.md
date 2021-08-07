# Philips Hue
* Getting Started: https://developers.meethue.com/develop/get-started-2/
* Dev Tool/Debugger: http://<bridge_addr>/debug/clip.html
* API Docs: https://developers.meethue.com/develop/hue-api/

## Get Username for App
1. Push link button
2. POST /api `{"devicetype":"app_name#device"}`

Response:

```json
[
	{
		"success": {
			"username": "faKekjh6kj435kBaDc23h688L67duMmYk134hvl9"

		}
	}
]
```

## Making Requests
http://<bridge_addr>/api/<username>/...

## Projects
* https://github.com/ccaroon/iss

## Misc
### Python
* https://github.com/benknight/hue-python-rgb-converter
