#!/usr/bin/env nu

let registry = "https://registry.npmjs.org/@zed-industries/claude-code-acp"

# Get latest version from npm
let version = (http get $registry | get dist-tags.latest)

# Prefetch source tarball hash (fetchzip uses SRI)
let src_url = $"($registry)/-/claude-code-acp-($version).tgz"
let src_hash = (nix store prefetch-file --hash-type sha256 --unpack --json $src_url | from json | get hash)

# Prefetch package-lock.json hash
let lock_url = $"https://raw.githubusercontent.com/zed-industries/claude-code-acp/refs/tags/v($version)/package-lock.json"
let lock_hash = (nix store prefetch-file --hash-type sha256 --json $lock_url | from json | get hash)

# Write coords file
{
  version: $version
  src: { url: $src_url, hash: $src_hash }
  packageLock: { url: $lock_url, hash: $lock_hash }
} | to json
  | nix eval --pretty --impure --expr 'builtins.fromJSON (builtins.readFile /dev/stdin)'
  | save -f acp-coords.nix
