# Get the current macOS appearance mode
export def get-appearance [] {
  let result = (defaults read -g AppleInterfaceStyle | complete)
  if $result.exit_code == 0 {
    "dark"
  } else {
        "light"
  }
}

# Adds a hook (closure) for appearance changes. Hook is called with a
# single arg, either 'dark' or 'light'
export def --env appearance-hook [
  hook: closure
] {
  $env.config.hooks = $env.config.hooks | upsert env_change.MACOS_APPEARANCE_STYLE {
    $in | default [] | append { |old new| do --env $hook $new }
   }
}

# Returns a hook suitable for use in pre_prompt that updates an environment variable
# with the current macOS appearance mode
def track-appearance [ ] {
  {||
     let appearance = (get-appearance)
     $env.MACOS_APPEARANCE_STYLE = $appearance
  }
}

export-env {
  $env.config.hooks = $env.config.hooks
    | upsert pre_prompt {
       $in | default [] | append (track-appearance)
    }
}
