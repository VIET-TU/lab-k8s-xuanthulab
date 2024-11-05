# Để chuyển các lệnh cài đặt và cấu hình NFS từ hệ điều hành CentOS/RHEL sang Ubuntu 20.04, bạn có thể thực hiện các bước sau:

## 1 Cài đặt gói cần thiết:

```sh
    sudo apt update
    sudo apt install nfs-kernel-server
```

## 2 Bật các dịch vụ NFS:

Trên Ubuntu, bạn không cần phải bật riêng từng dịch vụ như trên CentOS/RHEL. Chỉ cần bật và khởi động dịch vụ nfs-kernel-server là đủ.

```sh
    sudo systemctl enable nfs-kernel-server
    sudo systemctl start nfs-kernel-server
```

## 3 Cấu hình thư mục chia sẻ NFS:

````sh
   # Tạo (mở) file /etc/exports để soạn thảo, ở đây sẽ cấu hình để chia sẻ thư mục /data/mydata/

    vi /etc/exports
    /data/mydata  *(rw,sync,no_subtree_check,insecure)
    #Lưu thông lại, và thực hiện

    # Tạo thư mục
    mkdir -p /data/mydata
    chmod -R 777 /data/mydata

    # export và kiểm tra cấu hình chia sẻ
    exportfs -rav
    exportfs -v
    showmount -e

    # Khởi động lại và kiểm tra dịch vụ
    systemctl stop nfs-server
    systemctl start nfs-server
    systemctl status nfs-server
    ```
````
