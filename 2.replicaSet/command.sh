# Trong Kubernetes, ReplicaSet không chỉ định cụ thể node nào sẽ chạy các Pod của nó. Thay vào đó, Kubernetes Scheduler tự động quyết định node nào sẽ chạy mỗi Pod dựa trên nhiều yếu tố
# Kubernetes Scheduler nhận yêu cầu tạo Pod từ ReplicaSet và quyết định node nào là tốt nhất để chạy Pod đó. Quy trình bao gồm các bước sau:

# ReplicaSet là một đối tượng logic trong Kubernetes, không phải là một thực thể vật lý mà bạn có thể "nhìn thấy" chạy trên một node cụ thể. Khi bạn khởi tạo một ReplicaSet, Kubernetes API server lưu trữ trạng thái của ReplicaSet trong etcd (kho dữ liệu phân tán). ReplicaSet quản lý số lượng Pod mong muốn bằng cách đảm bảo rằng số lượng Pod đang chạy luôn phù hợp với cấu hình của nó.

# Quá trình khởi tạo và hoạt động của ReplicaSet:
# Khởi tạo ReplicaSet:
# Khi bạn tạo một ReplicaSet, Kubernetes API server lưu trữ đối tượng ReplicaSet và trạng thái mong muốn trong etcd.

# Kubernetes Controller Manager:
# Kubernetes Controller Manager theo dõi các đối tượng ReplicaSet. Nó đảm bảo rằng số lượng Pod chạy khớp với số lượng được chỉ định trong ReplicaSet.

# Tạo và quản lý Pod:
# Nếu số lượng Pod ít hơn số lượng mong muốn, Controller Manager sẽ tạo thêm Pod. Nếu số lượng Pod nhiều hơn, nó sẽ loại bỏ bớt Pod.



## watch liên tục
 watch -n 1 kubectl get all -o wide

#ReplicaSet trong Kubernetes
#ReplicaSet là một điều khiển Controller - nó đảm bảo ổn định các nhân bản (số lượng và tình trạng của POD, replica) khi đang chạy.

#Cách thức hoạt động

#Khi định nghĩa một ReplicaSet (định nghĩa trong file .yaml) gồm các trường thông tin, gồm có trường selector để chọn ra các các Pod theo label, từ đó nó biết được các Pod nó cần quản lý(số lượng POD có đủ, tình trạng các POD). Trong nó nó cũng định nghĩa dữ liệu về Pod trong spec template, để nếu cần tạo Pod mới nó sẽ tạo từ template đó. Khi ReplicaSet tạo, chạy, cập nhật nó sẽ thực hiện tạo / xóa POD với số lượng cần thiết trong khai báo (repilcas).

#Replicaset quản lý pod bằng label trong selector, nó sẽ quản lí những pod có cùng lable được chỉ định


NAME              READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod/rsapp-q69lb   1/1     Running   0          7s    10.0.2.18    node-2   <none>           <none>
pod/rsapp-w7lk8   1/1     Running   0          7s    10.0.3.113   node-1   <none>           <none>
pod/rsapp-w87m6   1/1     Running   0          7s    10.0.2.217   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE    SELECTOR
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   28h    <none>
service/svc1         ClusterIP   10.97.84.157   <none>        80/TCP    4h6m   <none>

NAME                    DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES         SELECTOR
replicaset.apps/rsapp   3         3         3       7s    rsapp        nginx:1.17.6   app=rsapp


# Replica replicaset.apps/rsapp  này sẽ quản lý các pod có lable app=rsapp

 kubectl get rs -o yaml
 
 kubectl describe rs/rsapp

 kubectl get rs -o wide

kubectl  get rs -o wide -n default

 kubectl get po -l "app=rsapp"

kubectl describe po/rsapp-fnxn2
# ***************Chú ý
# Chỉ POD nào có cùng lable với replicaset chỉ định thì mới có thuộc tính này
# Controlled By:  ReplicaSet/rsapp (cho biết pod được điều khiển bởi 1 replicaset rsapp) nó không độc như các pod trước mà ta tạo, mà bây giờ nó được giám sát và điều khiển bởi 1 replicaset

###***  xóa 1 pod
 kubectl delete po/rsapp-fnxn2

# xóa hết pod
 kubectl delete po --all

  kubectl delete rs rsapp


 #************Chú ý xóa nhãn pod bằng cách thêm - sau lable
#=====> khi ta xóa label app của pod thì lúc này replicaset nhận thấy thiếu 1 pod (số lượng chỉ định thiếu) nó sẽ tạo thêm một pod nữa ==> KQ: bh có 4 pod (với 3 pod có lable app=rsapp chịu quán lý bới replicaset và 1 pod không có lable hay pod này độc lập ko chịu quản lý replicaset)

kubectl label pod/rsapp-h25tt app-

## Bây giời khi xóa replicaset đó đi thì chỉ có nhưng pod nào chịu quản lý của replicaset mới bị xóa
kubectl delete -f 2.rs.yaml

###********Chú ý giả sử tạo tạo 1 pod trước có cùng lable quản lý bới replicaset, xog tạo 1 replicaset với lable đó
##===> Kết quản lúc này replicaset thấy dã có 1 pod trùng lable quản lý rồi, nên chỉ thêm 2 pod nữa thôi
## Và lúc này pod vừa tạo thì được thêm Controlled By:  ReplicaSet/rsapp, chịu quản lý của replica
kubectl apply -f 1.pod.yaml

#Demo
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod/rsapp         1/1     Running   0          26s   10.0.2.120   node-2   <none>           <none>
pod/rsapp-fb8pk   1/1     Running   0          8s    10.0.3.55    node-1   <none>           <none>
pod/rsapp-tghpm   1/1     Running   0          8s    10.0.2.145   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   28h     <none>
service/svc1         ClusterIP   10.97.84.157   <none>        80/TCP    4h24m   <none>

NAME                    DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES         SELECTOR
replicaset.apps/rsapp   3         3         3       9s    rsapp        nginx:1.17.6   app=rsapp

root@master-1:/xuan-thu-lab/k8s/replicaset# k describe pod/rsapp
Name:             rsapp
Namespace:        default
Priority:         0
Service Account:  default
Node:             node-2/192.168.72.184
Start Time:       Sun, 28 Jul 2024 14:33:11 +0000
Labels:           app=rsapp
Annotations:      <none>
Status:           Running
IP:               10.0.2.120
IPs:
  IP:           10.0.2.120
Controlled By:  ReplicaSet/rsapp

#****************Horizontal Pod Autoscaler với ReplicaSet
# Horizontal Pod Autoscaler là chế độ tự động scale (nhân bản POD) dựa vào mức độ hoạt động của CPU đối với POD, nếu một POD quá tải - nó có thể nhân bản thêm POD khác và ngược lại - số nhân bản dao động trong khoảng min, max cấu hình



# Ví dụ, với ReplicaSet rsapp trên đang thực hiện nhân bản có định 3 POD (replicas), nếu muốn có thể tạo ra một HPA để tự động scale (tăng giảm POD) theo mức độ đang làm việc CPU, có thể dùng lệnh sau:

kubectl autoscale rs rsapp --max=2 --min=1
# Lệnh trên tạo ra một hpa có tên rsapp, có dùng tham chiếu đến ReplicaSet có tên rsapp để scale các POD với thiết lập min, max các POD


# Để liệt kê các hpa gõ lệnh

kubectl get hpa
kubectl get hpa -o wide
 kubectl describe hpa/rsapp-scaler

 #Để linh loạt và quy chuẩn, nên tạo ra HPA (HorizontalPodAutoscaler) từ cấu hình file yaml (Tham khảo HPA API ) , ví dụ:

 apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: rsapp-scaler
spec:
  scaleTargetRef: ## xác định replicaset nào chịu tác động caler này
    apiVersion: apps/v1
    kind: ReplicaSet
    name: rsapp ## tên replicaset chịu tác động
  minReplicas: 3 ## tối thiểu
  maxReplicas: 7 ## tối đa
  # Thực hiện scale CPU hoạt động ở 50% so với CPU mà POD yêu cầu
  targetCPUUtilizationPercentage: 50



# Nó REFERENCE ReplicaSet/rsapp
NAME                                               REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/rsapp-scaler   ReplicaSet/rsapp   <unknown>/50%   4         7         0          4s


# Mình cần hiểu thêm chi tiết hơn 1 số tiêu chí.
# 1. "# Thực hiện scale CPU hoạt động ở 50% so với CPU mà POD yêu cầu
# targetCPUUtilizationPercentage: 50"

# Cái này là tính trên từng pod ah? hay của cả cluster?
# 2. Khi sử dụng hpa, thì số lượng replicas trong ReplicaSet sẽ không có ý nghĩa nữa, nên bỏ trống bạn nhỉ?

# 3. Khi sử dụng ReplicaSet và HPA rồi thì mình thấy k cần Deployment nữa nhỉ. Vì thấy cái ReplicaSet có hết tính năng của Deployment rồi. hiểu vậy đúng k nhỉ?
# Thích · Phản hồi · 4 năm

# Xuanthulab
# Tuan Le Dang 1) CPU tính cho từng POD (nếu hoạt động tăng đến 50% thì scale up - tạo thêm POD)
# 2) Đúng rồi, nếu HPA đang hoạt động thì replicas lại do HPA điều khiển, số lượng replicas trong ReplicaSet chỉ còn đúng khi nó khởi tạo
# 3) Dùng Deployment tốt hơn nhiều, vì Deployment quản lý ReplicaSet - Deployment thì bạn mới có các thao tác liên quan đến Update, rollback (cập nhật, hủy cập nhật, chuyển đến một phiên bản nào đó của ứng dụng)
# Thích · Phản hồi · 4 năm