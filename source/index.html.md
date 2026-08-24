---
title: API Reference

language_tabs:
- shell

toc_footers:
- <a href='mailto:support@bindle.io'>Bindle Support</a>

includes:
- errors

search: true
---

# Introduction

Welcome to the Bindle API.

We have language bindings only for terminal shell at the moment. We'd love some language specific clients if you wanna build us one, but in the meantime, you know curl, right? :)

# Authentication

> This is what happens when a valid API access token is sent to us:

```shell
curl "https://app.bindle.io/api/v1/ping" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 200 Response:

```json
{"message": "pong"}
```

> This is what happens when an invalid API access token is sent to us:

```shell
curl "https://app.bindle.io/api/v1/ping" \
-H "Authorization: Token token=invalid_access_token"
```

> 401 Response:

```json
{"error": "Unauthorized. Invalid or inactive API access token."}
```

Bindle uses API access tokens to allow access to some parts of the API.

If you are a Bindle account owner or administrator, you can find your API access token by logging into Bindle and looking at the Admin page.

Where required, Bindle expects the API access token to be included in requests to the server in a header that looks like the following:

`Authorization: Token token=your_access_token_goes_here`

<aside class="notice">
  You must replace <code>your_access_token_goes_here</code> with your own API access token.
</aside>

# Balances

```shell
curl "https://app.bindle.io/api/v1/balance?email=someone%40your-company.com" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 200 Response:

```json
{"balance": "35.5"}
```
> This is what happens when an unknown email address is sent to us:

```shell
curl "https://app.bindle.io/api/v1/balance?email=missing%40your-company.com" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 404 Response:

```json
{"error":"Not found. Main entitlement not found for that email address."}
```

> This is what happens if you haven't yet set up Bindle to track leave balances:

```shell
curl "https://app.bindle.io/api/v1/balance?email=someone%40your-company.com" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 400 Response:

```json
{"error":"Your company is not set up to use Bindle to track balances."}
```

This endpoint will return the annual leave balance for individuals within your company.
The balance is calculated as at today and the balance amount is given in days.

### HTTP Request

`GET https://app.bindle.io/api/v1/balance`

### Query Parameters

Parameter | Required | Default | Description
--------- | -------- | ------- | -----------
email | true | none | The email address of the user.

<aside class="notice">
  The email address is sent as an unquoted URL encoded parameter string.
</aside>

# Entitlements

```shell
curl "https://app.bindle.io/api/v1/entitlements?email=someone%40your-company.com" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 200 Response:

```json
{"entitlements": ["Annual Leave", "Personal Leave", "Compassionate Leave"]}
```

> This is what happens when an unknown email address is sent to us:

```json
{"error":"No entitlements found for that email address."}
```

This endpoint lists the names of every entitlement a person has.

### HTTP Request

`GET https://app.bindle.io/api/v1/entitlements`

### Query Parameters

Parameter | Required | Default | Description
--------- | -------- | ------- | -----------
email | true | none | The email address of the user.

# Leave

```shell
curl "https://app.bindle.io/api/v1/leave?email=someone%40your-company.com&from=2026-01-01&to=2026-03-31" \
-H "Authorization: Token token=your_access_token_goes_here"
```

> 200 Response:

```json
{
  "email": "someone@your-company.com",
  "from": "2026-01-01",
  "to": "2026-03-31",
  "entitlements": [
    {
      "name": "Annual Leave",
      "balance": "12.8151",
      "leave": [
        {"paid": true, "days": 3.0},
        {"paid": false, "days": 0}
      ]
    },
    {
      "name": "Compassionate Leave",
      "balance": null,
      "leave": [
        {"paid": true, "days": 0},
        {"paid": false, "days": 0}
      ]
    }
  ]
}
```

> This is what happens when an unknown email address is sent to us:

```json
{"error":"Not found. No person with that email address."}
```

> This is what happens when the period runs backwards:

```json
{"error":"from must not be later than to."}
```

This endpoint returns every entitlement a person has, each with its balance as at
the end of the period and the leave booked or taken within it.

Use it to answer questions like "what was everyone's annual leave balance at the
end of each quarter, and how much did they book or take inside it". Ask for the
period you care about and total it up however you like. Bindle does not impose a
quarter, a month or a leave year on the figures.

`balance` is the balance in days as at the `to` date, not as at today. It is
`null` where the entitlement does not carry a balance, or where your company is
not set up to track balances. The rest of the response is still returned.

`leave` is the leave booked or taken inside the period, in days, counting both
approved and pending bookings, with `paid` marking which kind each figure is. A
booking that straddles the edge of the period is counted only for the part that
falls inside it, so consecutive periods never double count the same day.

<aside class="notice">
  Both <code>from</code> and <code>to</code> are inclusive.
</aside>

### HTTP Request

`GET https://app.bindle.io/api/v1/leave`

### Query Parameters

Parameter | Required | Default | Description
--------- | -------- | ------- | -----------
email | true | none | The email address of the user.
from | true | none | First day of the period, as YYYY-MM-DD.
to | true | none | Last day of the period, as YYYY-MM-DD. Balances are given as at this date.

# Leave Calculator

You don't need a Bindle account to use our leave calculator. It's open for anyone to use.
Hence, you can it them without including an API access token.

```shell
curl \
-X POST https://app.bindle.io/api/v1/calculator \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data '{
"start_date": "2015-01-01",
"end_date": "2015-12-31",
"days_taken": "5.0",
"part_time": "true",
"part_time_hours": "19.0",
"accrual_rate": "20.0",
"shift_worker": "false"}'
```

> 200 Response:

```json
{"balance": "5.0"}
```

> A global validation error (e.g. 'days_taken' is missing):

```shell
curl \
-X POST http://app.bindle.io/api/v1/calculator \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data '{
"start_date": "2015-01-01",
"end_date": "2015-12-31"}'
```

> 400 Response:

```json
{"error":"days_taken is missing"}
```

> A field validation error (e.g. 'part_time_hours' is too large):

```shell
curl \
-X POST http://app.bindle.io/api/v1/calculator \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data '{
"start_date": "2015-01-01",
"end_date": "2015-12-31",
"days_taken": "5.0",
"part_time": "true",
"part_time_hours": "419.0"}'
```

> 400 Response:

```json
{"part_time_hours":["must be less than or equal to 38.0"]}
```

This endpoint calculates an annual leave balance under the Australian National Employment Standards (NES).

### HTTP Request

`POST https://app.bindle.io/api/v1/calculator`

### Query Parameters

Parameter | Required | Default | Description
--------- | -------- | ------- | -----------
start_date | true | none | The date to start calculating leave accrual from.
end_date | true | none | Calculate balance as at this date.
days_taken | true | none | The number of leave days already taken. Must be > 0 and < 100000.
part_time | false | false | Is this employee a part time employee? Can be true or false.
part_time_hours | false | 38.0 | The average number of hours worked per week. Required if part_time set to true, otherwise ignored. Must be > 0 and <= 38.0.
accrual_rate | false | 20.0 | Leave accrual rate in days per year. Must be > 0.
shift_worker | false | false | Is this employee a shift worker? Can be true or false.


<aside class="notice">
  This end point does not require authentication.
</aside>
