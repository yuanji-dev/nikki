#!/bin/bash

tg_dir="tcardgen"
tg_bin="${tg_dir}/tcardgen"
tg_font_dir="${tg_dir}/font"
tg_tpl_dir="${tg_dir}/template.png"

articles=$(git diff --name-only HEAD content/posts)

for article in $articles; do
    cover="$(dirname "$article")/cover.en.png"
    article="$(dirname "$article")/index.en.md"
    $tg_bin -f $tg_font_dir -o "$cover" -t $tg_tpl_dir "$article"
done
