# Loads the credentials of an AWS profile into the environment as plain
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN variables.
# Tools that cannot run a credential_process (e.g. Cognitect aws-api) read them.
export def --env aws-load-env [
  --profile (-p): string # profile to export; defaults to AWS_PROFILE
] {
  let profile_args = if $profile == null { [] } else { [--profile $profile] }
  let creds = ^aws configure export-credentials --format process ...$profile_args | from json

  load-env ({
    AWS_ACCESS_KEY_ID: $creds.AccessKeyId
    AWS_SECRET_ACCESS_KEY: $creds.SecretAccessKey
    AWS_SESSION_TOKEN: ($creds.SessionToken? | default null)
    AWS_SESSION_EXPIRATION: ($creds.Expiration? | default null)
  } | compact)

  print $"AWS credentials loaded, expire ($creds.Expiration? | default 'never')"
}
