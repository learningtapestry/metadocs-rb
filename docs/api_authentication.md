# Google API Authentication

Metadocs is compatible with the [Credentials](https://www.rubydoc.info/github/google/google-auth-library-ruby/Google/Auth/Credentials)
object used by the official [googleauth](https://github.com/googleapis/google-auth-library-ruby)
library.

There are different ways to authenticate with Google:

- on behalf of end users with OAuth2, for web or console applications;
- with a service account.

See the [googleauth](https://github.com/googleapis/google-auth-library-ruby) docs for more info.

Either option will work with this library - what's important is to pass on the `Credentials` created
by `googleauth`.

The scopes you need to authorize for are provided in `Metadocs::GoogleDocument::RequiredScopes`.
Currently only `https://www.googleapis.com/auth/documents` is needed.

## Example

```ruby
credentials = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open('/path/to/service_account_json_key.json'),
  scope: Metadocs::GoogleDocument::RequiredScopes
)

metadoc = Metadocs::Parser.parse(credentials, 'https://docs.google.com/document/d/...')
```

## Permissions

Note that the credentials object must have permission to view the document you're trying to access.

For on behalf authorization, that means the user you're accessing data on behalf of has permission
to view the document.

For service accounts, you can share the document with the service account
e-mail that shows up in the `client_email` property of the service account credentials JSON file
exported by Google.
