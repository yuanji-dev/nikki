#!/bin/bash

tg_dir="tcardgen"
tg_bin="${tg_dir}/tcardgen"
tg_font_dir="${tg_dir}/font"
tg_config="${tg_dir}/config.yaml"

articles=$(git diff --name-only HEAD content/posts)

for article in $articles; do
    cover="$(dirname "$article")/cover.en.png"
    article="$(dirname "$article")/index.en.md"
    $tg_bin -f $tg_font_dir -o "$cover" -c $tg_config "$article"
done
