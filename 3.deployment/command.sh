#Deployment: chức năng quản lý các pod, nhân bản các pod, tự động thay thế các pod lỗi đảm báo các pod luôn luôn đang chạy
#Tóm lại là để quán lý version của replicaSet, mỗi lần cập nhật deployment thì replicaset được tạo mới và replicaset cũ được scale về 0 lưu lại như lịch sử cập nhật của deploymennt, từ lịch sử này ta có thể phục hồi quay trở lại phiên bản cập nhật nào đó   


## khi deployment tạo ra nó sẽ tạo ra các replicaset, các replicaset này trực tiếp tạo và quản lý các pod, mỗi lần deployment cập nhật thì nó sẽ tạo ra các replicaset tương ứng và replicaset mới sẽ thay thế các replicaset cũ, tuy nhiên replicaset cũ sẽ không bị xóa đi, nó giử lại để cho chúng ta có nhu cầu thì phục hôì qua thao tác rollback,
# Ta cũng có thể thực hiện scale một deployment thay đổi số lượng pod, có 2 cách scale, cách 1 là scael thủ công, 2 autoscale thông qua hpa

# deployemt -> replicaset ->n pod

# Thực hiện lệnh sau để triển khai

kubectl apply -f 1.myapp-deploy.yaml
# Khi Deployment tạo ra, tên của nó là deployapp, có thể kiểm tra với lệnh:

#xóa
kubectl delete -f deploy/name-deploy

kubectl get deploy -o wide

# Deploy này quản sinh ra một ReplicasSet và quản lý nó, gõ lệnh sau để hiện thị các ReplicaSet

kubectl get rs -o wide

# NAME                             READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
# pod/deployapp-645cf8d884-22whz   1/1     Running   0          45s   10.0.3.10   node-1   <none>           <none>
# pod/deployapp-645cf8d884-fdhmw   1/1     Running   0          51s   10.0.2.89   node-2   <none>           <none>
# pod/deployapp-645cf8d884-jpqlf   1/1     Running   0          51s   10.0.3.1    node-1   <none>           <none>

# NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
# service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   45h   <none>

# NAME                        READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES         SELECTOR
# deployment.apps/deployapp   3/3     3            3           9m2s   node         nginx:1.17.6   app=deployapp

# NAME                                   DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES         SELECTOR
# replicaset.apps/deployapp-645cf8d884   3         3         3       7m36s   node         nginx:1.17.6   app=deployapp,pod-template-hash=645cf8d884
# replicaset.apps/deployapp-7b67595fbf   0         0         0       9m2s    node         busybox        app=deployapp,pod-template-hash=7b67595fbf


# deployment.apps/deployapp with revision #1
# Pod Template:
#   Labels:       
#          app=deployapp
#         pod-template-hash=7b67595fbf
#   Containers:
#    node:
#     Image:      busybox
#     Port:       8085/TCP
#     Host Port:  0/TCP

## chý ý ở đây là replicaset sẽ tạo ra một lable mới và pod cũng thể --> thì replicaset sẽ dựa bào lable này để quản lý các pod pod-template-hash=645cf8d884



# Đến lượt ReplicaSet do Deploy quản lý lại thực hiện quản lý (tạo, xóa) các Pod, để xem các Pod

kubeclt get po -o wide

# # Hoặc lọc cả label
 kubectl get po -l "app=deployapp" -o wide

# Thông tin chi tiết về deploy

kubectl describe deploy/deployapp

# *******Cập nhật Deployment****

# Khi một Deployment được cập nhật, thì Deployment dừng lại các Pod, scale lại số lượng Pod về 0, sau đó sử dụng template mới của Pod để tạo lại Pod, Pod cũ không xóa hẳng cho đến khi Pod mới đang chạy, quá trình này diễn ra đến đâu có thể xem bằng lệnh kubectl describe deploy/namedeploy. Cập nhật như vậy nó đảm bảo luôn có Pod đang chạy khi đang cập nhật.


# Có 2 cách cập nhật
#Cách 1: chỉnh sữa file và apply lại
# quá trình diễn ra : nó sẽ tạo ra một replica mới tạo ra các pod do replica mới quản lý (scale lên 3), replica cũ các pod do nó quản lí sẽ bị terminating (scale về 0)

#Khi cập nhật, ReplicaSet cũ sẽ hủy và ReplicaSet mới của Deployment được tạo, tuy nhiên ReplicaSet cũ chưa bị xóa để có thể khôi phục lại về trạng thái trước (rollback).

# Cách 2 
kubectl edit deploy/name-deploy

 kubectl get deploy/deployapp -o yaml

kubectl describe deploy/deployapp


# Có thể thu hồi lại bản cập nhật bằng cách sử dụng lệnh kubectl rollout undo

# Cập nhật image mới trong POD - ví dụ thay image của container node bằng image mới httpd

kubectl set image deploy/deployapp node=httpd --record
# Để xem quá trình cập nhật của deployment
kubectl rollout status deploy/deployapp

#Bạn cũng có thể cập nhật tài nguyên POD theo cách tương tự, ví dụ giới hạn CPU, Memory cho container với tên app-node

kubectl set resources deploy/deployapp -c=node --limits=cpu=200m,memory=200Mi


#**********Rollback Deployment
#Kiểm tra các lần cập nhật (revision)

kubectl rollout history deploy/deployapp

#Để xem thông tin bản cập nhật version 1 thì gõ lệnh
kubectl rollout history deploy/deployapp --revision=1

# root@master-1:/xuan-thu-lab/k8s/deployment# k rollout history deployment.apps/deployapp --revision=1
# deployment.apps/deployapp with revision #1
# Pod Template:
#   Labels:       app=deployapp
#         pod-template-hash=7b67595fbf
#   Containers:
#    node:
#     Image:      busybox
#     Port:       8085/TCP
#     Host Port:  0/TCP
#     Command:
#       sh
#       -c
#       while true; do echo hello; sleep 10; done
#     Limits:
#       cpu:      100m
#       memory:   128Mi
#     Environment:        <none>
#     Mounts:     <none>
#   Volumes:      <none>

#Khi cần quay lại phiên bản cũ nào đó, ví dụ bản revision 1
kubectl rollout undo deploy/deployapp --to-revision=1


#Nếu muốn quay lại bản cập nhật trước gần nhất
kubectl rollout undo deploy/deployapp



##Replicaset được điều khiển bởi 1 deployment
#Controlled By:  Deployment/deployapp (khác với replicaset ta tạo độc lập)
 kubectl describe replicaset.apps/deployapp-85656685f6


# **********Scale Deployment******
#Scale thay đổi chỉ số replica (số lượng POD) của Deployment, ý nghĩa tương tự như scale đối với ReplicaSet trong phần trước. Ví dụ để scale với 10 POD thực hiện lệnh:

kubectl scale deploy/deployapp --replicas=5

#*** hoặc HPA**************
#Muốn thiết lập scale tự động với số lượng POD trong khoảng min, max và thực hiện scale khi CPU của POD hoạt động ở mức 50% thì thực hiện

kubectl autoscale deploy/deployapp --min=2 --max=5 --cpu-percent=50

# Ki tạo no sẽ ra một hpa

#Bạn cũng có thể triển khai Scale từ khai báo trong một yaml. Hoặc có thể trích xuất scale ra để chỉnh sửa

kubectl get hpa/deployapp -o yaml > 2.hpa.yaml
