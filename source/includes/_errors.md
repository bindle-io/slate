# Errors

The Bindle API uses the following error codes:


Error Code | Meaning
---------- | -------
400 | Bad Request -- Your request is incorrect in some way. Check the documentation again.
401 | Unauthorized -- Your API key is incorrect
403 | Forbidden -- The resource requested is hidden 
404 | Not Found -- The specified resource could not be found
405 | Method Not Allowed -- You tried to access a resource with an invalid method
406 | Not Acceptable -- You requested a format that isn't json
500 | Internal Server Error -- We had a problem with our server. Try again later.
503 | Service Unavailable -- We're temporarily offline for maintenance. Please try again later.
