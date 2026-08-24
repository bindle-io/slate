# Bindle API reference

The reference published at [api.bindle.io](https://api.bindle.io).

## How it works

There is no build step and nothing here describes the API.

`index.html` loads [Redoc](https://github.com/Redocly/redoc) from the vendored
`redoc.standalone.js` and points it at `https://app.bindle.io/api/v1/swagger_doc`, which the
Bindle application generates from the Grape endpoints themselves. Adding a parameter, changing
a description or mounting a new endpoint updates this site the moment that change is deployed.

That is the whole point of it. The previous version of this site was written by hand in Slate
and had drifted: one endpoint had never been documented at all, and the page quoted an error
message the API does not send.

Anything that needs saying beyond what the endpoints declare belongs in the application, in
`app/api/bindle/documentation.rb`, not here.

## Changing the styling

Edit the `OPTIONS` object in `index.html`. The palette is taken from the Bindle application:
`#337AB7` for brand blue, `#2B313A` for the sidebar, and adelle-sans from the same Typekit kit
the application uses.

`api.bindle.io` must be an authorised domain on Typekit kit `xam3lle` or the type falls back to
Helvetica.

## Publishing

`./publish.sh` copies the site to the `gh-pages` branch, which is what GitHub Pages serves.
`CNAME` is part of the site, so publishing can no longer take the custom domain down.

Serving Pages from `master` instead would remove even that step. Nothing here needs building.
