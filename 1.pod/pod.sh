#****************POD******************
#Tóm tắt: pod là đơn vị nhỏ nhát set về phần mềm khác với node đơn vị nhỏ nhất về mặt phàn chứn
# Khi pod được tạo ra thì nó có thể chạy trên một node nào đó của cluster, mỗi pod bên trong có thể chạy một container hoặc nhiều container, mỗi pod có IP Address, địa chỉ ip này trong mạng nội bộ cluster liên lạc với nhau
# Trong pod có các volume -> các contianer chạy trong pod đó có thể chia sẽ ổ địa cho nhau


apiVersion: v1
kind: Pod
metadata: # thông tin bổ sung cho Pod
  labels:
    app: app1 #nhãn tùy do ta đặt-> để sau này ta sẽ chọn ra các pod theo lable
    ungdung: ungdung1
  name: ungdungnode
spec:
  containers:
  - name: c1
    image: viettu123/swarmtest:php
    resources:
      limits:
        memory: "150M"
        cpu: "100m" # 1 core cpu: 1000m
    ports:
      - containerPort: 8085
      # - containerPort: 8086

# run
 kubectl apply -f firstpod.yaml

# xóa pod
 kubectl delete po nginxapp

#Mặc định Kubernetes không tạo và chạy POD ở Node Master để đảm bảo yêu cầu an toàn, nếu vẫn muốn chạy POD ở Master thi hành lệnh sau:

kubectl taint nodes --all node-role.kubernetes.io/master-1


# kubectl get pods	#L#iệt kê các POD trong namespace hiện tại, thêm tham số -o wide hiện thị chi tiết hơn, thêm -A hiện thị tất cả namespace, thêm -n namespacename hiện thị Pod của namespace namespacename
# kubectl explain pod --recursive=true	#Xem cấu trúc mẫu định nghĩa POD trong file cấu hình yaml
# kubectl apply -f firstpod.yaml	#Triển khai tạo các tài nguyên định nghĩa trong file firstpod.yaml
# kubectl delete -f firstpod.yaml	#Xóa các tài nguyên tạo ra từ định nghĩa firstpod.yaml
# kubectl describe pod/namepod	#Lấy thông tin chi tiết POD có tên namepod, nếu POD trong namespace khác mặc định thêm vào tham số -n namespace-name
# kubectl logs pod/podname	#Xem logs của POD có tên podname
# kubectl exec mypod command	#Chạy lệnh từ container của POD có tên mypod, nếu POD có nhiều container thêm vào tham số -c và tên container
# kubectl exec -it mypod bash	#Chạy lệnh bash của container trong POD mypod và gắn terminal
# kubectl proxy	#Tạo server proxy truy cập đến các tài nguyên của Cluster. http://localhost/api/v1/namespaces/default/pods/mypod:8085/proxy/, truy cập đến container có tên mypod trong namespace mặc định.
# kubectl delete pod/mypod	#Xóa POD có tên mypod

## get ra các sự kiện trong cluster
kubectl get ev

# get ra thông tin file .yaml
kubectl get pod/ungdungnode -o yaml

# chỉnh sửa
kubectl edit pod/ungdungnode #lập tức nó sẽ tạo lại và cập nhật lại nhưng gì vừa sửa

# logs pod
kubectl logs pod/podname	

## thi hành lệnh
kubectl exec ungdungnode bash | sh
kubectl exec ungdungnode ls  /

## exec vào pod có nhiều container
kubectl exec -it tools -c n1 bash
## 2 pod trên 2 node khác nhau có thể call đến nhau

## **** IP: chú í ip của pod là ip nội bộ trong cluster để giao tiếng với nhau, từ bên ngoiaf không thể truy cập vào -> phải dùng service, Ingress

NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
pod/deployapp-7b67595fbf-9n72j   1/1     Running   0          13s   10.0.2.215   node-2   <none>           <none>
pod/deployapp-7b67595fbf-f5l89   1/1     Running   0          13s   10.0.3.205   node-1   <none>           <none>
pod/deployapp-7b67595fbf-lrggm   1/1     Running   0          13s   10.0.2.245   node-2   <none>           <none>

 kubectl exec -it pod/deployapp-7b67595fbf-9n72j ping 10.0.3.205


#**Truy cập Pod từ bên ngoài
# Trong thông tin của Pod ta thấy có IP của Pod và cổng lắng nghe, tuy nhiên Ip này là nội bộ, chỉ các Pod trong Cluster liên lạc với nhau. Nếu bên ngoài muốn truy cập cần tạo một Service để chuyển traffic bên ngoài vào Pod (tìm hiểu sau), tại đây để debug - truy cập kiểm tra bằng cách chạy proxy -> Proxy giống như côngr kết nối giúp ta truy cập vào clusster giống như là truy cập nội bộ


# Chú ý nginxapp ở node-1 chẳng hạn, mà ta truy cập lại là ip của master-1, do mạng netowk k8s nó điều phối xuống node 
#chú ý: tôi có 2 master tôi chạy lệnh kubectl proxy ở master 1 chẳng hạn,thì chỉ có thể truy cập từ ip của master-1, truy cập ip master-2 thì khôngn được

kubectl proxy

#hoặc
kubectl proxy --address="0.0.0.0" --accept-hosts='^*$'
Truy cập đến địa chỉ http://192.168.72.181:8001/api/v1/namespaces/default/pods/nginxapp:80/proxy/


#Khi kiểm tra chạy thử, cũng có thể chuyển cổng để truy cập. Ví dụ cổng host 8080 được chuyển hướng truy cập đến cổng 8085 của POD mypod

kubectl port-forward mypod 8080:8085


#Cấu hình thăm dò Container còn sống

#Bạn có thể cấu hình livenessProbe cho mỗi container, để Kubernetes kiểm tra xem container còn sống không. Ví dụ, đường dẫn kiểm tra là /healthycheck, nếu nó trả về mã header trong khoảng 200 đến 400 được coi là sống (tất nhiên bạn cần viết ứng dụng trả về mã này). Trong đó cứ 10s kiểm tra một lần

# Trong Kubernetes, livenessProbe là một cơ chế kiểm tra sức khỏe (health check) của các container trong Pod để đảm bảo chúng đang chạy đúng cách. Nếu một container không phản hồi tốt với livenessProbe, Kubernetes sẽ khởi động lại container đó để khắc phục tình trạng không ổn định.

apiVersion: v1
kind: Pod
metadata:
  name: mypod
  labels:
    app: mypod
spec:
  containers:
  - name: mycontainer
    image: nginx:1.17.6
    ports:
    - containerPort: 80
    resources: {}
    
    livenessProbe:
      httpGet:
        path: / # Đây là đường dẫn root, sẽ được kiểm tra bởi liveness probe
        port: 80 # Cổng mà liveness probe sẽ kiểm tra
      initialDelaySeconds: 10
      periodSeconds: 10

#Pod có nhiều container

kubectl exec -it nginx-swarmtest -c n1 ls / 
kubectl exec -it nginx-swarmtest -c n1 bash
kubectl get nginx-swarmtest -o yaml

# http://192.168.72.181:8001/api/v1/namespaces/default/pods/nginx-swarmtest:80/proxy/
# http://192.168.72.181:8085/api/v1/namespaces/default/pods/nginx-swarmtest:80/proxy/

apiVersion: v1
kind: Pod
metadata:
  name: nginx-swarmtest
  labels:
    app: myapp
spec:
  containers:
    - name: n1
      image: nginx:1.17.6
      resources:
        limits:
          memory: "128Mi"
          cpu: "100m"
      ports:
        - containerPort: 80
    - name: s1
      image: busybox
      command: ["sh", "-c", "while true; do echo hello; sleep 10; done"]
      resources:
        limits:
          memory: "150Mi"
          cpu: "100m"
      ports:
        - containerPort: 8085


#Ổ đĩa / Volume trong POD

#Nếu muốn sử dụng ổ đĩa - giống nhau về dữ liệu trên nhiều POD, kể cả các POD đó chạy trên các máy khác nhau thì cần dùng các loại đĩa Remote - ví dụ NFS - loại đĩa này nói ở các phần sau.

apiVersion: v1
kind: Pod
metadata:
  name: nginx-swarmtest-vol
  labels:
    app: myapp
spec:
  volumes:
    # Định nghĩa một volume - ánh xạ thư mục /home/www máy host
    - name: "myvol"
      hostPath:
        path: "/home/html" # thư mục node đang chạy (pod chạy trên node đó)
  containers:
    - name: n1
      image: nginx:1.17.6
      resources:
        limits:
          memory: "128Mi"
          cpu: "100m"
      ports:
        - containerPort: 80
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: "myvol"
    - name: s1
      image: busybox
      command: ["sh", "-c", "while true; do echo hello; sleep 10; done"]
      resources:
        limits:
          memory: "150Mi"
          cpu: "100m"
      ports:
        - containerPort: 8085
      volumeMounts:
        - mountPath: /data/
          name: "myvol"



# http://192.168.72.181:8001/api/v1/namespaces/default/pods/nginx-swarmtest-vol:80/proxy/

# ta sẽ ssh vào node chay pod trên và thê file index.html /home/html
cd /home/html
echo 'hello worl' > index.html

#Nếu muốn sử dụng ổ đĩa - giống nhau về dữ liệu trên nhiều POD, kể cả các POD đó chạy trên các máy khác nhau thì cần dùng các loại đĩa Remote - ví dụ NFS - loại đĩa này nói ở các phần sau.

## Chống chế chỉ tạo trên node-1
kubectl describe node/node-1

# Labels:             beta.kubernetes.io/arch=amd64
#                     beta.kubernetes.io/os=linux
#                     kubernetes.io/arch=amd64
#                     kubernetes.io/hostname=node-1
#                     kubernetes.io/os=linux

 nodeselector:
    kubernetes.io/hostname: node-1 #label=value

#xóa tất cả pod vừa tạo

kubectl delete -f /1.pods/

## để kiểm tra lỗi trong container
docker describe nam-pod