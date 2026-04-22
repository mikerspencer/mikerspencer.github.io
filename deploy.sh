#!/usr/bin/env bash

default_site="rouze.hervyqa.dev"
second=5

remove=true
render=true
deploysrht=true
default_lang=("en" "fr" "id" "ja")

echo "[*] Enter your custom site (e.g., mywebsite.com)."
echo "    or leave empty for default [$default_site]."
if ! read -t "$second" -r -p "    Custom site: " input_site; then
  printf "\n"
fi
site=${input_site:-$default_site}

# remove http://, https://, and any path/slashes
clean_site=$(echo "$site" | sed -e 's|https://||' -e 's|http://||' -e 's|/.*||')

dir="_site"
files="${clean_site}.tar.gz"

echo "[*] Remove old builddir [$dir]?"
if ! read -t "$second" -r -p "    Default is Yes [Y/n]: " confirm_remove; then
  printf "\n"
fi

if [[ "$confirm_remove" =~ ^[Nn]([Oo])?$ ]]; then
  remove=false
  echo "    Not deleted."
fi

if $remove; then
  echo "[*] Execute remove [$dir]."
  rm -rf "$dir"
fi

echo "[*] Render website?"
if ! read -t "$second" -r -p "    Default is Yes [Y/n]: " confirm_render; then
  printf "\n"
fi

if [[ "$confirm_render" =~ ^[Nn]([Oo])?$ ]]; then
  render=false
  echo "    Skip render."
fi

if $render; then
  echo "[*] Render website."
  echo "    Enter profile in lang-[lang]."
  if ! read -t "$second" -r -p "    Default: en,fr,id,ja: " input_languages; then
    printf "\n"
  fi

  if [[ -z "$input_languages" ]]; then
    languages=("${default_lang[@]}")
  else
    IFS=',' read -ra languages <<< "$input_languages"
    for i in "${!languages[@]}"; do
      languages[i]=$(xargs <<< "${languages[i]}")
    done
  fi

  echo "[*] Processing languages: ${languages[*]}"
  for lang in "${languages[@]}"; do
    echo "[*] Rendering for language: $lang"
    quarto render "lang-$lang"
  done
fi

if [[ -d "$dir" ]]; then
  echo "[*] Creating tar file: $files"
  tar -czf "$files" -C "$dir" .
  size=$(du -h "$files" | cut -f1)
else
  echo "[*] Build directory [$dir] not found. Skip packaging."
  exit 0
fi

if [[ ! -f "$files" ]]; then
  echo "[*] Build archive [$files] not found. Skip deploy."
  echo "[*] Done."
  exit 0
fi

echo "[*] Publishing website to: $clean_site"
if ! read -t "$second" -r -p "    Deploy with hut (Sourcehut) [Y/n]: " confirm_deploysrht; then
  printf "\n"
fi

if [[ "$confirm_deploysrht" =~ ^[Nn]([Oo])?$ ]]; then
  deploysrht=false
  echo "    Upload skipped."
fi

if $deploysrht; then
  echo "[*] Deploy to sourcehut."
  hut pages publish -d "$clean_site" "$files"
fi

echo "[*] Cleaning build archive $files [$size]."
rm -rf "$files"

echo "[*] Done."

