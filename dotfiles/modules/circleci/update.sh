# Pins the latest CircleCI CLI release in sources.json, next to this script's
# copy in the repo. Run from anywhere inside the repo; update-flake calls it.

repo="CircleCI-Public/circleci-cli"
sources="$(git rev-parse --show-toplevel)/dotfiles/modules/circleci/sources.json"

# nix system -> release asset platform suffix
declare -A platforms=(
  [aarch64-darwin]=darwin_arm64
  [x86_64-darwin]=darwin_amd64
  [aarch64-linux]=linux_arm64
  [x86_64-linux]=linux_amd64
)

tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name)
version=${tag#v}
current=$(jq -r '.version // empty' "$sources" 2>/dev/null || true)

if [[ "$version" == "$current" ]]; then
  echo "> circleci is up to date ($version)"
  exit 0
fi

echo "> Updating circleci ${current:-none} -> $version"

base="https://github.com/$repo/releases/download/$tag"
checksums=$(curl -fsSL "$base/circleci-cli_${version}_checksums.txt")

json=$(jq -n --arg version "$version" '{version: $version, systems: {}}')
for system in "${!platforms[@]}"; do
  file="circleci-cli_${version}_${platforms[$system]}.tar.gz"
  hex=$(awk -v f="$file" '$2 == f { print $1 }' <<<"$checksums")
  if [[ -z "$hex" ]]; then
    echo "error: no checksum for $file" >&2
    exit 1
  fi
  hash=$(nix hash convert --hash-algo sha256 --to sri "$hex")
  json=$(jq --arg s "$system" --arg url "$base/$file" --arg hash "$hash" \
    '.systems[$s] = {url: $url, hash: $hash}' <<<"$json")
done

jq -S . <<<"$json" >"$sources"
echo "> Wrote $sources"
