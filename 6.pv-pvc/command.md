# Sử dụng Persistent Volume (pv) và Persistent Volume Claim (pvc) trong Kubernetes

Tạo ổ đĩa lưu dữ liệu lâu dài PV và yêu cầu truy cập đến PV bằng PVC, cách mount PVC vào POD

## Persistent Volume trong Kubernetes

- PersistentVolume (pv) là một phần không gian lưu trữ dữ liệu trong cluster, các PersistentVolume giống với Volume bình thường tuy nhiên nó tồn tại độc lập với POD (pod bị xóa PV vẫn tồn tại), có nhiều loại PersistentVolume có thể triển khai như NFS, Clusterfs ... (xem tại Các kiểu PersistentVolume )

- PersistentVolumeClaim (pvc) là yêu cầu sử dụng không gian lưu trữ (sử dụng PV). Hình dung PV giống như Node, PVC giống như POD. POD chạy nó sử dụng các tài nguyên của NODE, PVC hoạt động nó sử dụng tài nguyên của PV.

Đối với các ứng dụng cần có khu vực lưu trữ lâu dài (persistent) vd DB hoặc một service cần đọc/ghi file, ta cần cung cấp Pesistent Volume cho chúng.
Pesistent Volume có thể nằm trên ổ cứng của Node, nfs hoặc Cloud Service (EBS).
Lưu ý: Kubernetes không chịu trách nhiệm cho việc quản lý các dis

Persistent Volume là một resource nằm ngoài namespace.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
name: pv1
labels:
  name: pv1
spec:
storageClassName: mystorageclass
capacity:
  storage: 5Gi
accessModes:
  - ReadWriteOnce # chỉ dụng bởi một node
hostPath:
  path: "/v1" #/ sử dụng thư  mục trên  node làm ổ đĩa, tham số hostPatch chỉ sử dụng khi ta tạo các ổ đĩa mà nó sử dụng các thư mục của các node, còn lại tùy thuộc lưu trữ file sử dụng ta khai báo thêm các thiết lập khác nhau
```

### watch -n 1 kubectl get all,pv,pvc -o wide

```bash
# triển khai
kubectl apply -f 1.persistent-vol.yaml

# liệt kê các PV
kubectl get pv -o wide

# thông tin chi tiết
kubectl describe pv/pv1

NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS     REASON   AGE   VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Available           mystorageclass            65s   Filesystem

root@master-1:/xuan-thu-lab/k8s/pv-pvc# kubectl describe pv/pv1
Name:            pv1
Labels:          name=pv1
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    mystorageclass
Status:          Available
Claim:
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        5Gi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /v1
    HostPathType:
Events:            <none>
root@master-1:/xuan-thu-lab/k8s/pv-pvc#

```

#### CHÚ Ý: khi ta tạo PV với hostPath /v1 thì trên 2 node woker 1 và 2 đều sẽ được tạo thư mục v1, nhưng hai thư mục này hoạt động độc lập với nhau, Vì vậy khi Pod ở trên 2 node ý sẽ mount vào 3 thư mục của Node đó ,Nếu muốn chia sẽ thì dùng NFS

## Tạo Persistent Volume Claim trong Kubernetes

PVC (Persistent Volume Claim) là yêu cầu truy cập đến PV, một PV chỉ có một PVC

2.persistent-vol-claim.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc1
  labels:
    name: pvc1
spec:
  storageClassName: mystorageclass # phải chọn ra class mà nó tìm ra những pv trên cluster và nó sẽ gắn kết vào nhưng pv đó ==> Yêu câu truy cập PV có stronageClassNmae là mystringaeclass
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 150Mi
```

```bash
# triển khai
kubectl apply -f 2.persistent-vol-claim.yaml

kubectl get pvc,pv -o wide
kubectl describe pvc/pvc1


NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS     REASON   AGE    VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Bound    default/pvc1   mystorageclass            9m2s   Filesystem

NAME                         STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS     AGE   VOLUMEMODE
persistentvolumeclaim/pvc1   Bound    pv1      5Gi        RWO            mystorageclass   44s   Filesystem

# STATUS=Bound : nghĩa là pvc đã gắn kết với một pv ở đây là pv1 và status của pv cung đã chuyển thành STATUS=Bound mục CLAIM  cho biết có pvc1 đã yêu cầu truy cập, pvc1 được gắn kết với nhau dựa vào thông tin strorageclass
```

# Thử xóa pvc1 đi

```sh
k delete -f 2.pvc.yaml

NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM          STORAGECLASS     REASON   AGE   VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Released   default/pvc1   mystorageclass            13m   Filesystem

# Lúc này PV có trạng thái giải phóng (Released), Nó cho biết trước đây có yêu cầu truy cập  default/pvc1 đã được gắn kết nhưng đã giải phóng, `Chú ý khi PV ở trạng thái Released thì không sử dụng lại được nữa`
 k apply -f 2.pvc.yaml

NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM          STORAGECLASS     REASON   AGE   VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Released   default/pvc1   mystorageclass            16m   Filesystem

NAME                         STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS     AGE   VOLUMEMODE
persistentvolumeclaim/pvc1   Pending                                      mystorageclass   8s    Filesystem

# Status lúc này cửa PVC1 đang là PENDING  nó không được gắn kết với một PV nào cả, tức là không sử dụng được
# Nếu muốn sử dụng lại ta phải chỉnh sửa menifet của nó

 k delete -f 2.pvc.yaml

 k edit pv/pv1

### Xóa toàn bộ mục claimRef: Đi thì dùng lại được

spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
#   claimRef:
#     apiVersion: v1
#     kind: PersistentVolumeClaim
#     name: pvc1
#     namespace: default
#     resourceVersion: "154529"
#     uid: 55ae7e5d-03f0-4e8a-8206-d7b770be3751
#   hostPath:
#     path: /v1
#     type: ""
#   persistentVolumeReclaimPolicy: Retain
#   storageClassName: mystorageclass
#   volumeMode: Filesystem



NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS     REASON   AGE   VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Available           mystorageclass            20m   Filesystem

# lúc nó chuyển sang trạng thái Available, triển khai lại PV1 thì gắn kết lại được

NAME                   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM          STORAGECLASS     REASON   AGE   VOLUMEMODE
persistentvolume/pv1   5Gi        RWO            Retain           Bound    default/pvc1   mystorageclass            21m   Filesystem

NAME                         STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS     AGE   VOLUMEMODE
persistentvolumeclaim/pvc1   Bound    pv1      5Gi        RWO            mystorageclass   3s    Filesystem
```

### Sử dụng PVC với Pod

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      name: myapp
  template:
    metadata:
      name: myapp
      labels:
        name: myapp
    spec:
      volumes:
        # Khai báo VL sử dụng PVC
        - name: myvolume
          persistentVolumeClaim:
            claimName: pvc1
      containers:
        - name: myapp
          image: busybox
          resources:
            limits:
              memory: "50Mi"
              cpu: "500m"
          command:
            - sleep
            - "600"
          volumeMounts:
            - mountPath: "/data"
              name: myvolume
```

```sh
 k exec -it pod/myapp-hvg7s sh
```
