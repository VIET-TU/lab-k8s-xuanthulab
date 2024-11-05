# Để sử dụng Docker để chạy NFS server trên Ubuntu 20.04, bạn có thể thực hiện các bước sau

## 1 Cài đặt Docker:

```sh
    sudo apt update
    sudo apt install docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
```

## 2 Tạo Dockerfile cho NFS Server:

```sh
   mkdir nfs-docker
    cd nfs-docker
    nano Dockerfile

```

Thêm nội dung sau vào tệp Dockerfile

```Dockerfile
    FROM ubuntu:20.04

    RUN apt update && apt install -y nfs-kernel-server

    RUN mkdir -p /mnt/nfs_share && \
        chown nobody:nogroup /mnt/nfs_share && \
        chmod 777 /mnt/nfs_share

    COPY exports /etc/exports

    CMD ["bash", "-c", "service nfs-kernel-server start && tail -f /dev/null"]

```

## 3 Tạo tệp exports:

```sh
   nano exports
   # hêm nội dung sau vào tệp exports (điều chỉnh 192.168.1.0/24 thành mạng của bạn):
   /mnt/nfs_share 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)

```

## 4 Xây dựng Docker Image:

```sh
   docker build -t nfs-server .

```

## 5 Chạy Container từ Docker Image:

```sh
   docker run --rm -d --name nfs-server --privileged --network host nfs-server
    # Chú ý: --privileged và --network host giúp container có đủ quyền và cấu hình mạng để chạy NFS server.

```

## 5 Server Node muốn muont tới

```sh
   docker run -d --name nfs-server --privileged --network host nfs-server
    # Chú ý: --privileged và --network host giúp container có đủ quyền và cấu hình mạng để chạy NFS server.

```
