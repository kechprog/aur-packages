#!/bin/bash
# Bump _ovver to the version of Arch's openvino package, but only once upstream
# has tagged the matching openvino.genai and openvino_tokenizers releases.
# Edits PKGBUILD in place; prints a one-line summary when it changed anything.
set -euo pipefail
cd "$(dirname "$0")"

arch_ver=$(curl -fsS https://archlinux.org/packages/extra/x86_64/openvino/json/ | jq -r .pkgver)
current=$(sed -n 's/^_ovver=//p' PKGBUILD)
[[ $arch_ver == "$current" ]] && exit 0

tag="${arch_ver}.0"
for repo in openvino.genai openvino_tokenizers; do
  if ! git ls-remote --exit-code --tags "https://github.com/openvinotoolkit/${repo}.git" "refs/tags/${tag}" >/dev/null; then
    echo "openvino ${arch_ver} is out, but ${repo} has no ${tag} tag yet; waiting" >&2
    exit 0
  fi
done

sed -i -e "s/^_ovver=.*/_ovver=${arch_ver}/" -e 's/^pkgrel=.*/pkgrel=1/' PKGBUILD
echo "openvino-genai: ${current}.0 -> ${tag}"
