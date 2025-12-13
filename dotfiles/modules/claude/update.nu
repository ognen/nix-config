#!/usr/bin/env nu

let bucket = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

let version =  http get $"($bucket)/stable" | str trim
let manifest = http get $"($bucket)/($version)/manifest.json"

let final = {
  version: $version
  platforms: ($manifest
    | get platforms
    | transpose platform sha256
    | update sha256 { $in.checksum }
    | update sha256 { nix hash convert --to sri --hash-algo sha256 $in }
    | insert system {
        match $in.platform {
          "darwin-arm64" => "aarch64-darwin",
          "darwin-x64" => "x86_64-darwin",
          "linux-arm64" => "aarch64-linux",
          "linux-x64" => "x86_64-linux",
          _ => ""        
        }
    }
    | insert url { $"($bucket)/($version)/($in.platform)/claude" }
    | insert coord { {url: $in.url, sha256: $in.sha256 } }
    | where system != ""
    | select system coord
    | transpose  -rd
  
  )
}

$final
  | to json
  | nix eval --pretty --impure --expr 'builtins.fromJSON (builtins.readFile /dev/stdin)'
  | save -f coords.nix
