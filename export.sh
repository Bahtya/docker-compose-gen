#!/bin/bash

# 获取正在运行的容器列表
container_list=$(docker ps --format "{{.ID}} {{.Names}} {{.Image}}")

# 输出的 Docker Compose 文件名
OUTPUT_FILE="docker-compose.yml"

# 清空已有的输出文件内容
> "$OUTPUT_FILE"

# 写入 Docker Compose 文件的顶部信息
echo "version: '3'" >> "$OUTPUT_FILE"
echo "services:" >> "$OUTPUT_FILE"

# 遍历容器列表
while read -r container; do
    container_id=$(echo "$container" | awk '{print $1}')
    container_name=$(echo "$container" | awk '{print $2}')
    container_image=$(echo "$container" | awk '{print $3}')

    # 获取容器详细信息


    # 获取端口映射
    container_ports=$(docker container port "$container_id" | sed 's#/.*##' | awk '{print $1":"$1}' | sort -u)
    # 获取端口映射
    container_info=$(docker inspect "$container_id")
    #container_ports=$(echo "$container_info" | jq -r '.[0].NetworkSettings.Ports | to_entries[] | .key + ":" + (.value[0].HostPort // "")')

    # 获取文件夹映射
    container_volumes=$(echo "$container_info" | jq -r '.[0].HostConfig.Binds[]?')

    # 写入服务定义
    echo "  $container_name:" >> "$OUTPUT_FILE"
    echo "    image: $container_image" >> "$OUTPUT_FILE"
    echo "    ports:" >> "$OUTPUT_FILE"
    for port in $container_ports; do
        #host_port=$(echo "$port" | cut -d'/' -f1)
        #container_port=$(echo "$port" | cut -d'/' -f2)
        #echo "      - $container_port:$container_port" >> "$OUTPUT_FILE"
        echo "      - $port" >> "$OUTPUT_FILE"
    done
    echo "    volumes:" >> "$OUTPUT_FILE"
    for volume in $container_volumes; do
        echo "      - $volume" >> "$OUTPUT_FILE"
    done
    echo "" >> "$OUTPUT_FILE"
done <<< "$container_list"

echo "Docker Compose 文件生成完成：$OUTPUT_FILE"

