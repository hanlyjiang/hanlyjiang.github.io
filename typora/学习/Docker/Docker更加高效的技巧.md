## 使用Volume应对大量的数据写入

> 参考: https://docs.docker.com/storage/storagedriver/#copying-makes-containers-efficient
>
> **Note**: for write-heavy applications, you should not store the data in the container. Instead, use Docker volumes, which are independent of the running container and are designed to be efficient for I/O. In addition, volumes can be shared among containers and do not increase the size of your container’s writable layer.

因为volume的读写效率比容器层要好很多；





## 镜像构建/容器运行的建议

1. 清楚运行时产生的文件在哪，如果非常多，应该将其挂载为数据卷，避免持续写入到容器层；
2. 