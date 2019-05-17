## [YApi](https://yapi.ymfe.org) docker 容器部署

以 1.7.0 为例。

### 1. 创建 yapi 镜像

部署于 docker 容器中，首先创建 docker 镜像，编写 Dockerfile 如下：

    # Dockerfile for YApi, Dunnen 2019/05/16
    FROM node:10.15-alpine

    ENV YAPI_VERSION 1.7.0

    WORKDIR /yapi

    COPY config.json .

    RUN wget -O yapi.tgz http://registry.npm.taobao.org/yapi-vendor/download/yapi-vendor-${YAPI_VERSION}.tgz \
        && apk add --no-cache python make \
        && tar -xf yapi.tgz \
        && mv package vendors \
        && cd vendors \
        && rm -rf .github \
        && rm -rf .history \
        && npm install --production --registry https://registry.npm.taobao.org \
    #   && npm run install-server \
        && rm -rf ../yapi.tgz

    WORKDIR /yapi/vendors

    CMD [ "node", "server/app.js" ]

构建镜像时强制要求 yapi 的配置文件，即 config.json，参见 [内往部署](https://yapi.ymfe.org/devops/index.html)，简单示例如：

    {
      "port": "3000",
      "adminAccount": "admin@mail.com",
      "closeRegister": false, // 禁止注册
      "db": {
        "servername": "simple-yapi-mongo", // docker --link 的 mongo 容器
        "DATABASE": "yapi",
        "port": 27017
      }
    }

执行 `docker build -t yapi:1.7.0-runtime .` 构建本地 `yapi:1.7.0-runtime` 镜像。

注意上面**注释掉**的内容 `npm run install-server`，按照官网的描述，这一步*“安装程序会初始化数据库索引和管理员账号”*。如果是第一次全新安装 yapi，可将这个注释放开，然后执行 `docker build -t yapi:1.7.0-initial .` 构建另一种 `yapi:1.7.0-initial` 镜像。

### 2. 启动 mongo 4 容器

创建并启动专用于 yapi 的 mongo 容器，注意确定一个大版本，以免数据迁移时导入、导出 mongo 数据库异常。**挂载 host 特定目录**并启动：

    docker run -d --name simple-yapi-mongo -v /simple/yapi/mongo/:/data/db mongo

### 3. 启动 yapi 容器

注意 `-p` 暴露的端口与 config.json 中的一致：

    docker run --name simple-yapi --link simple-yapi-mongo:simple-yapi-mongo -p 3000:3000 -d yapi:1.7.0-runtime

### 4. yapi/mongo 备份和迁移

备份 yapi，本质上就是备份 mongo 数据库，如果没有安装 mongo，可基于 mongo 镜像进行备份操作，假如备份到 host 的 `/backup/yapi`，示例如下：

    docker run --rm --link simple-yapi-mongo-origin:mongo -v /backup/yapi:/backup mongo:4-xenial  bash -c 'mongodump --out /backup --host mongo:27017'

可在另外一个 mongo 容器中进行还原，注意 host 上 mongo 备份数据路径，示例如下：

    docker run --rm --link simple-yapi-mongo-dest:mongo -v /backup/yapi:/backup mongo:4-xenial  bash -c 'mongorestore /backup --host mongo:27017'

迁移，也仅仅是在另外一台电脑上构建镜像，创建容器，和还原 mongo 数据库的过程。

### 5. 复用

将镜像随送至 Registry，以供直接拉取使用。

### 6. compose

编写 `docker-compose.yaml` 快速编排 yapi 和 mongo。因为单独执行也很简单，不在此赘述。

**参见：**

 - [YApi](https://yapi.ymfe.org)
 - [node](https://hub.docker.com/_/node)
 - [mongo](https://hub.docker.com/_/mongo)

