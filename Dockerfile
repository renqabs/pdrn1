# 使用基础镜像
FROM golang:alpine AS builder

# 安装必要的工具
RUN apk update && apk add --no-cache \
    curl \
    tar  \
    jq

# 创建新的工作目录
WORKDIR /app


# 下载并解压文件，并给予所有用户读写和执行权限
RUN version=$(basename $(curl -sL -o /dev/null -w %{url_effective} https://github.com/pandora-next/deploy/releases/latest)) \
    && base_url="https://github.com/pandora-next/deploy/releases/expanded_assets/$version" \
    && latest_url="https://github.com/$(curl -sL $base_url | grep "href.*amd64.*\.tar.gz" | sed 's/.*href="//' | sed 's/".*//')" \
    && curl -Lo PandoraNext.tar.gz $latest_url \
    && tar -xzf PandoraNext.tar.gz --strip-components=1 \
    && rm PandoraNext.tar.gz \
    && chmod 777 -R .

# 获取tokens.json
RUN --mount=type=secret,id=TOKENS_JSON,dst=/etc/secrets/TOKENS_JSON \
    if [ -f /etc/secrets/TOKENS_JSON ]; then \
    cat /etc/secrets/TOKENS_JSON > tokens.json \
    && chmod 777 tokens.json; \
    else \
    echo "TOKENS_JSON not found, skipping"; \
    fi

# 获取config.json
RUN --mount=type=secret,id=CONFIG_JSON,dst=/etc/secrets/CONFIG_JSON \
    cat /etc/secrets/CONFIG_JSON > config.json && chmod 777 config.json

# 修改PandoraNext的执行权限
RUN chmod 777 ./PandoraNext

# 创建全局缓存目录并提供最宽松的权限
RUN mkdir /.cache && chmod 777 /.cache

# 开放端口
EXPOSE 8080

# 启动命令
CMD ["./PandoraNext"]
