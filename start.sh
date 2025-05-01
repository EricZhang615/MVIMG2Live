#!/bin/bash

for img in MVIMG*.jpg; do
    [[ -f "$img" ]] || continue

    # 复制文件到目标目录
    cp "$img" "livephoto/$img"
    cd livephoto || exit 1

    # 分离视频和照片
    video_offset=$(grep -F -a -b --only-matching ftypmp4 "$img" | cut -d: -f1)
    if [[ -n "$video_offset" ]]; then
        jpeg_end=$((video_offset - 4))
        mov_file="${img%.jpg}.mov"

        # 执行文件分离
        dd if="$img" of="$mov_file" bs="$jpeg_end" skip=1 2>/dev/null
        truncate -s "$jpeg_end" "$img"

        # 生成大写UUID
        uuid=$(uuidgen | tr '[:lower:]' '[:upper:]')

        # 内存流拼接二进制数据
        {
            cat mod.bin  # 32字节
            printf "%-36s" "$uuid" | iconv -t ASCII  # 36字节
            printf '\0'  # 1字节
        } | exiftool "-MakerNoteApple<=-" -unsafe -overwrite_original "$img"

        # 修改视频元数据
        exiftool -QuickTime:ContentIdentifier="$uuid" -overwrite_original "$mov_file"
    fi
    cd ..
done