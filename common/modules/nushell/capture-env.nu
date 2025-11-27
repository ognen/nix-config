# A module for importing foreign environment vars

def parse-env-0 [] {
  split row "\u{0}"
   | where ($it | is-not-empty)
   | split column "=" name value
}

def as-record [] {
  transpose  --header-row  --as-record 
} 

export def main [
  --shell (-s): string = /bin/bash
  script: path
] {
  const ignored = [
    "_AST_FEATURES"
    "SHLVL"
    "_"
  ]

  let current_env = env -0 | parse-env-0 | as-record

  ^$shell -c $'
    source "($script)"
    env -0
   '
   | parse-env-0
   | where { |e| ($current_env | get -o $e.name) != $e.value }
   | where name not-in $ignored
   | as-record  
}
