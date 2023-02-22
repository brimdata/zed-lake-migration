#!/bin/sh

prior_zed_version="v1.5.0"

cd "$(dirname "$0")"
prior_zed="$(pwd)/zed-$prior_zed_version"

case $(uname -s) in
    Darwin )
        PATH=/Applications/Zui.app/Contents/Resources/app.asar.unpacked/zdeps:$PATH
        src_dir="$HOME/Library/Application Support/Brim/lake"
        dst_dir="$HOME/Library/Application Support/Zui/lake"
        ;;
    Linux )
        PATH=/opt/Zui/resources/app.asar.unpacked/zdeps:$PATH
        src_dir=$HOME/.config/Brim/lake
        dst_dir=$HOME/.config/Zui/lake
        ;;
    * ) # Windows
        PATH=$LOCALAPPDATA/Programs/Zui/resources/app.asar.unpacked/zdeps:$PATH
        src_dir=$APPDATA/Brim/lake
        dst_dir=$APPDATA/Zui/lake
        ;;
esac

if [ $# -gt 2 ] || [ $# -eq 1 ]; then
     echo "usage: $0 [SRC_DATA_DIR] [DST_DATA_DIR]" >&2
     exit 1
elif [ $# = 2 ]; then
    src_dir=$1
    dst_dir=$2
fi

set -e

echo "migrating lake at '$src_dir' to '$dst_dir'"
cd "$src_dir"

# Sort these by decreasing modification time so we can use
# 'entry.id==... | head 1 | yield entry.name' below to determine current
# pool names.  (We can't use entry.ts for that because it reflects pool
# creation time rather than modification time.)
pools_zngs=$(ls -t pools/*.zng)

if [ -e "$dst_dir" ]; then
    if ! stderr=$(zed -lake "$dst_dir" ls 2>&1 >/dev/null); then
        exec "fatal error: 'zed ls' failed with this output: '$stderr'" >&2
        exit 1
    fi
else
    zed init "$dst_dir"
fi

ksuid_glob='???????????????????????????'
for pool_ksuid in $ksuid_glob; do
    pool_name=$(zq -f text "entry.id==ksuid('$pool_ksuid') | head 1 | yield entry.name" $pools_zngs)

    # join() is needed to deal with nested pool keys, e.g., kafka.offset
    pool_order=$(zq -f text "entry.id==ksuid('$pool_ksuid') | head 1 | yield join(entry.layout.keys[0], '.') + ':' + entry.layout.order" $pools_zngs)

    # Look for [0-9]*.zng so snap.zng is excluded
    branch_count=$(zq -f text 'yield entry.name | sort | uniq | count()' $pool_ksuid/branches/[0-9]*.zng)
    if [ "$branch_count" != 1 ]; then
        echo "warning: found $branch_count branches in '$pool_name' ($pool_ksuid) but only migrating 'main'"
    fi

    if zed -lake "$dst_dir" ls "$pool_name" >/dev/null 2>&1; then
        echo "skipping '$pool_name' ($pool_ksuid): pool name already exists in '$dst_dir'"
        continue
    fi

    echo "migrating pool '$pool_name' ($pool_ksuid)"
    prior_zng=$(mktemp)
    $prior_zed -lake "$src_dir" -use "$pool_name"@main query '*' > "$prior_zng"
    zed -lake "$dst_dir" create -q -orderby "$pool_order" "$pool_name"
    zed -lake "$dst_dir" load -q -use "$pool_name" "$prior_zng"
    new_zng=$(mktemp)
    zed -lake "$dst_dir" -use "$pool_name" query '*' > "$new_zng"
    if ! cmp -s "$prior_zng" "$new_zng"; then
        echo "error: contents of migrated pool '$pool_name' differ from original"
        echo "pool dump before/after: $prior_zng $new_zng"
    else
        rm -f "$prior_zng" "$new_zng"
    fi
done
