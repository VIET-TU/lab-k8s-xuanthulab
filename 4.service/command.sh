# Trong Kubernetes, Service là một đối tượng logic dùng để xác định một tập hợp các Pod và cung cấp một phương thức để truy cập chúng. Khi bạn tạo một Service, Kubernetes API server lưu trữ đối tượng này trong etcd, giống như các đối tượng khác (Pod, Deployment, ReplicaSet, etc.).

# Quá trình khởi tạo và hoạt động của Service:
# Lưu trữ trong etcd: Khi bạn tạo một Service, đối tượng này được lưu trữ trong etcd.
# Endpoints: Kubernetes tạo và cập nhật một đối tượng Endpoints cho mỗi Service, chứa danh sách các IP của Pod được phục vụ bởi Service đó.
# Kube-proxy: Kube-proxy trên mỗi node trong cluster lắng nghe các thay đổi về Service và Endpoints, và cấu hình các quy tắc iptables hoặc IPVS để định tuyến lưu lượng đến các Pod tương ứng.
#*******************************************************
# Trong Kubernetes, Service không thực sự "chạy" trên một node cụ thể như Pod. Thay vào đó, Service là một đối tượng logic được sử dụng để định danh và truy cập một tập hợp các Pod. Nó cung cấp một cách nhất quán để truy cập các Pod mà không cần phải biết vị trí cụ thể của chúng.

# Cách Service hoạt động trong Kubernetes:
# Service Object: Khi bạn tạo một Service, đối tượng Service này được lưu trữ trong etcd, giống như các đối tượng Kubernetes khác.

# Kube-proxy: Mỗi node trong Kubernetes cluster có một thành phần gọi là kube-proxy. kube-proxy chịu trách nhiệm thực hiện các quy tắc mạng để định tuyến lưu lượng đến các Pod tương ứng thông qua các Service. kube-proxy có thể sử dụng iptables hoặc IPVS để thực hiện điều này.

# ClusterIP: Khi bạn tạo một Service, Kubernetes cấp cho Service một IP ảo được gọi là ClusterIP. ClusterIP này không liên kết với một node cụ thể mà là một IP ảo có thể truy cập từ mọi node trong cluster.

# Endpoints: Kubernetes tự động tạo và duy trì một đối tượng Endpoints cho mỗi Service, chứa danh sách các Pod IP và cổng mà Service đó đại diện. Các Endpoints này được cập nhật tự động khi các Pod được thêm hoặc xóa.

# Quá trình định tuyến lưu lượng của Service:
# Client: Khi một client (có thể là một Pod khác) gửi yêu cầu đến ClusterIP của Service, kube-proxy trên node đó nhận yêu cầu.

# kube-proxy: Kube-proxy kiểm tra các quy tắc iptables/IPVS để xác định Endpoints nào (Pod IP và cổng) mà Service đó đại diện.

# Routing: Kube-proxy chuyển tiếp yêu cầu đến một trong các Pod được liệt kê trong đối tượng Endpoints, sử dụng thuật toán round-robin hoặc một phương thức khác để cân bằng tải.

#**************** Xuanhulab Service trong Kubernetes****************

# Các POD được quản lý trong Kubernetes, trong vòng đời của nó chỉ diễn ra theo hướng - được tạo ra, chạy và khi nó kết thúc thì bị xóa và khởi tạo POD mới thay thế. ! Có nghĩa ta không thể có tạm dừng POD, chạy lại POD đang dừng ...

# Mặc dù mỗi POD khi tạo ra nó có một IP để liên lạc, tuy nhiên vấn đề là mỗi khi POD thay thế thì là một IP khác, nên các dịch vụ truy cập không biết IP mới nếu ta cấu hình nó truy cập đến POD nào đó cố định. Để giải quết vấn đề này sẽ cần đến Service.

# Service (micro-service) là một đối tượng trừu tượng nó xác định ra một nhóm các POD và chính sách để truy cập đến POD đó. Nhóm cá POD mà Service xác định thường dùng kỹ thuật Selector (chọn các POD thuộc về Service theo label của POD).

# Cũng có thể hiểu Service là một dịch vụ mạng, tạo cơ chế cân bằng tải (load balancing) truy cập đến các điểm cuối (thường là các Pod) mà Service đó phục vụ.

#Tạo Service kiểu ClusterIP, không Selector

apiVersion: v1
kind: Service
metadata:
  name: svc1
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
# ClusterIP: cho thành phầnion trong cluster lên lạc đến


kubectl get svc

kubeclt get svc/svc1 -yaml

kubeclt describe svc/svc1
# Hệ thống đã tạo ra service có tên là svc1 với địa chỉ IP là 10.96.188.161, khi Pod truy cập địa chỉ IP này với cổng 80 thì nó truy cập đến các endpoint định nghĩa trong dịch vụ. Tuy nhiên thông tin service cho biết phần endpoints là không có gì, có nghĩa là truy cập thì không có phản hồi nào.



# root@deployapp-645cf8d884-22whz:/# exit
# exit
# command terminated with exit code 1
# root@master-1:/xuan-thu-lab/k8s/service# kubectl describe svc/svc1
# Name:              svc1
# Namespace:         default
# Labels:            <none>
# Annotations:       <none>
# Selector:          <none>
# Type:              ClusterIP
# IP Family Policy:  SingleStack
# IP Families:       IPv4
# IP:                10.96.188.161
# IPs:               10.96.188.161
# Port:              <unset>  80/TCP
# TargetPort:        80/TCP
# Endpoints:         <none>
# Session Affinity:  None
# Events:            <none>

###
kubectl cluster-info

root@master-1:/xuan-thu-lab/k8s/service# k cluster-info
Kubernetes control plane is running at https://192.168.72.180:6443
CoreDNS is running at https://192.168.72.180:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

 
#Ta thấy thành phần đang hoạt động CoreDNS: nó sẽ giúp ta phần giải tên của của các service thành các địa chỉ IP -> Ta có thể truy đến các service thông qua Name hoặc IP của service

# root@master-1:/xuan-thu-lab/k8s/service# k exec -it pod/deployapp-645cf8d884-22whz bash
# root@deployapp-645cf8d884-22whz:/# ping svc1
# PING svc1.default.svc.cluster.local (10.96.188.161) 56(84) bytes of data.


#**** Chú ý đây là trường hợp pod và service cùng namespace, nếu truy cập cập các service khác namespace thì ta phải viết tên namespace sau tên service
#Do có dịch vụ CoreDns nên có thể truy cập thông qua phân giải tên, truy cập đến service theo cấu trúc namespace.servicename nếu cùng namespace chỉ cần servicenname
# Ví dụ svc1.default

ping sv1.default



#EndPoint có vai trò giống như backend trong hệ thống cân bằng tải, khi service svc1 được tạo ra mà ta không thiết lập selector, mặc định thì nó tìm trên cluster xem có một endpoint nào cao tên là svc1 không , nếu mà có endpoint cùng tên svc1 thì nó sẽ lấy endpoint đó làm endpint của service 

# lấy ra endpoint

kubectl get endpoints


# root@master-1:/xuan-thu-lab/k8s/service# kubectl get endpoints
# NAME         ENDPOINTS                                 AGE
# kubernetes   192.168.72.181:6443,192.168.72.182:6443   46h


#Tạo EndPoint cho Service (không selector)
#Service trên có tên svc1, không có selector để xác định các Pod là endpoint của nó, nên có thể tự tạo ra một endpoint cùng tên svc1

#2.endpoint
apiVersion: v1
kind: Endpoints
metadata:
  name: svc1
subsets:
  - addresses:
      - ip: 216.58.220.195      # đây là IP google
    ports:
      - port: 80
#Triển khai với lệnh

kubectl apply -f 2.endpoint.yaml

kubectl get endpoints

# NAME         ENDPOINTS                                 AGE
# kubernetes   192.168.72.181:6443,192.168.72.182:6443   46h
# svc1         216.58.220.195:80                         11s

 k delete endpoints svc1

 ## Kiểm ta lại serivce svc1 

  kubectl describe svc/svc1

# Name:              svc1
# Namespace:         default
# Labels:            <none>
# Annotations:       <none>
# Selector:          <none>
# Type:              ClusterIP
# IP Family Policy:  SingleStack
# IP Families:       IPv4
# IP:                10.96.188.161
# IPs:               10.96.188.161
# Port:              <unset>  80/TCP
# TargetPort:        80/TCP
# Endpoints:         216.58.220.195:80
# Session Affinity:  None
# Events:            <none>

# Như vậy svc1 đã có endpoints, khi truy cập svc1:80 hoặc svc1.default:80 hoặc 10.96.188.161:80 có nghĩa là truy cập 216.58.220.195:80

# Do có dịch vụ CoreDns nên có thể truy cập thông qua phân giải tên, truy cập đến service theo cấu trúc namespace.servicename nếu cùng namespace chỉ cần servicenname

# Ví dụ trên sử dụng Service (không có Selector), cần tạo Endpoint có tên cùng tên Service: dùng loại này khi cần tạo ra một điểm truy cập dịch vụ tương tự như proxy đến một địa chỉ khác (một server khác, một dịch vụ khác ở namespace khác ...)

 k exec -it pod/deployapp-645cf8d884-22whz bash

# root@deployapp-645cf8d884-22whz:/# curl svc1:80
# <!DOCTYPE html>
# <html lang=en>
#   <title>Error 404 (Not Found)!!1</title>
#   <a href=//www.google.com/><span id=logo aria-label=Google></span></a>
#   <p><b>404.</b> <ins>That’s an error.</ins>
#   <p>The requested URL <code>/</code> was not found on this server.  <ins>That’s all we know.</ins>
 
 #=====> như vậy yêu cầu của ta đến service svc1 đã được chuyển hướng tới một seriver khác


#*************************Thực hành tạo Service có Selector, chọn các Pod là Endpoint của Service
#Trước tiên triển khai trên Cluster 2 POD chạy độc lập, các POD đó đều có nhãn app: app1
#====> Sau này làm các endpoint của service, lable=app1 sẽ được service chọn và tìm ra pod để làm endpoint

## Tạo 2 pod => Đừng nhầm lần tạo Service thì phải cần deployemnt nha thằng ngu, service cân bằng tải dựa vào lable của pod
3.pods.yaml

#Triển khai file trên

kubectl apply -f 3.pods.yaml

# Nó tạo ra 2 POD myapp1 (192.168.41.147 chạy nginx) và myapp2 (192.168.182.11 chạy httpd), chúng đều có nhãn app=app1

# Tiếp tục tạo ra service có tên svc2 có thêm thiết lập selector chọn nhãn app=app1 ==> Nó sẽ lấy 2 pod này làm endpoint, nghĩa là mỗi lần ta truy cập tới service thì nghĩa là truy cập vào myapp1 hoặc myapp2

4.svc2.yaml

apiVersion: v1
kind: Service
metadata:
  name: svc2
spec:
  selector:
     app: app1
  type: ClusterIP
  ports:
    - name: port1
      port: 80
      targetPort: 80


##
 kubectl apply -f 4.svc2.yaml
kubectl describe svc/svc2


# Name:              svc2
# Namespace:         default
# Labels:            <none>
# Annotations:       <none>
# Selector:          app=app1
# Type:              ClusterIP
# IP Family Policy:  SingleStack
# IP Families:       IPv4
# IP:                10.110.218.38
# IPs:               10.110.218.38
# Port:              port1  80/TCP
# TargetPort:        80/TCP
# Endpoints:         10.0.2.46:80,10.0.3.116:80
# Session Affinity:  None
# Events:            <none>
# root@master-1:/xuan-thu-lab/k8s/service#

# Thông tin trên ta có, endpoint của svc2 là  10.0.2.46:80,10.0.3.116:80, hai IP này tương ứng là của 2 POD trên. Khi truy cập địa chỉ svc2:80 hoặc 10.110.218.38:80 thì căn bằng tải hoạt động sẽ là truy cập đến 192.168.182.11:80 (myapp1) hoặc 192.168.41.147:80 (myapp2)

### TEST

# root@tools:/# curl svc2
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# </head>
# <body>
# <h1>Welcome to nginx!</h1>
# <p><em>Thank you for using nginx.</em></p>
# </body>
# </html>
# root@tools:/#

=====> Ta đang truy cập đên myapp1

Truy cập lần 2 thì vào myapp2

# root@tools:/# curl svc2
# <html><body><h1>It works!</h1></body></html>

===> Hệ thống cân bằng tải làm việc và chuyển hướng yêu cầu đến 1 trong 2 pod 


#### **** Thực hành tạo Service kiểu NodePort

# Kiểu NodePort này tạo ra có thể truy cập từ ngoài internet bằng IP của các Node, ví dụ sửa dịch vụ svc2 trên thành dịch vụ svc3 kiểu NodePort

# 5.svc3.yaml

apiVersion: v1
kind: Service
metadata:
  name: svc3
spec:
  selector:
     app: app1
  type: NodePort
  ports:
    - name: port1
      port: 80
      targetPort: 80
      nodePort: 31080

# Trong file trên, thiết lập kiểu với type: NodePort, lúc này Service tạo ra có thể truy cập từ các IP của Node với một cổng nó ngẫu nhiên sinh ra trong khoảng 30000-32767. Nếu muốn ấn định một cổng của Service mà không để ngẫu nhiên thì dùng tham số nodePort như trên.

# NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE   SELECTOR
# service/svc3         NodePort    10.109.216.149   <none>        80:31080/TCP   17s   app=app1

# =======> Tất nhiên nó vẫn có vẫn có địa chỉ  CLUSTER-IP  để cho những thành phần khác ở trên cluster nó liên lac đến

# ========> truy cập svc3 thông qua ip của node master, hoặc node woker đều dược


# *******************************Ví dụ ứng dụng Service, Deployment, Secret**************************
# Trong ví dụ này, sẽ thực hành triển khai chạy máy chủ nginx với mức độ áp dụng phức tạp hơn đó là:

# Xây dựng một image mới từ image cơ sở nginx rồi đưa lên registry Hub Docker đặt tên là viettu123/swarmtest:nginx
# Tạo Secret chứa xác thực SSL sử dụng bởi viettu123/swarmtest:nginx
# Tạo deployment chạy/quản lý các POD có chạy viettu123/swarmtest:nginx
# Tạo Service kiểu NodePort để truy cập đến các POD trên
# Xây dựng image viettu123/swarmtest:nginx
# Image cơ sở là nginx (chọn tag bản 1.17.6), đây là một proxy nhận các yêu cầu gửi đến. Ta sẽ cấu hình để nó nhận các yêu cầu http (cổng 80) và https (cổng 443).

# Tạo ra thư mục nginx để chứa các file dữ liệu, đầu tiên là tạo ra file cấu hình nginx.conf, file cấu hình này được copy vào image ở đường dẫn /etc/nginx/nginx.conf khi build image.

# 1) Chuẩn bị file cấu hình nginx.conf


# Để ý file cấu hình này, thiết lập nginx lắng nghe yêu cầu gửi đến cổng 80 và 443 (tương ứng với 2 server), thư mục gốc làm việc mặc định của chúng là /usr/share/nginx/html, tại đây sẽ copy và một file index.html

# 2) Chuẩn bị file index.html

index.html

<!DOCTYPE html>
<html>
<head><title>Nginx -  Test!</title></head>
<body>
    <h1>Chạy Nginx trên Kubernetes</h1>    
</body>
</html>

# 3) Xây dựng image mới

# Tạo Dockerfile xây dựng Image mới, từ image cơ sở nginx:1.17.6, có copy 2 file nginx.conf và index.html vào image mới này


# Dockerfile

FROM nginx:1.17.6
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html


# Build thành Image mới đặt tên là ichte/swarmtest:nginx (đặt tên theo tài khoản của bạn trên Hub Docker, hoặc theo cấu trúc Registry riêng nếu sử dụng) và push Image nên Docker Hub

# build image từ Dockerfile, đặt tên image mới là ichte/swarmtest:nginx
docker build -t ichte/swarmtest:nginx -f Dockerfile .

# đẩy image lên hub docker
docker push ichte/swarmtest:nginx


# Khi triển khai file này, có lỗi tạo container vì trong cấu hình có thiết lập SSL (server lắng nghe cổng 443) với các file xác thực ở đường dẫn /certs/tls.crt, /certs/tls.key nhưng hiện tại file này không có, ta sẽ sinh hai file này và đưa vào qua Secret


# Tự sinh xác thực với openssl
# Xác thực SSL gồm có server certificate và private key, đối với nginx cấu hình qua hai thiết lập ssl_certificate và ssl_certificate_key tương ứng ta đã cấu hình là hai file tls.crt, tls.key. Ta để tên này vì theo cách đặt tên của letsencrypt.org, sau này bạn có thể thận tiện hơn nếu xin xác thực miễn phí từ đây.

# Thực hiện lệnh sau để sinh file tự xác thực
##********* Chúy ý tạo thư mục certs
mkdir certs

cd certs

openssl req -nodes -newkey rsa:2048 -keyout tls.key  -out ca.csr -subj "/CN=viettu.net"
openssl x509 -req -sha256 -days 365 -in ca.csr -signkey tls.key -out tls.crt

# Đến đây có 2 file tls.key và tls.crt

# Tạo Secret tên secret-nginx-cert chứa các xác thực
# Thi hành lệnh sau để tạo ra một Secret (loại ổ đĩa chứa các thông tin nhạy cảm, nhỏ), Secret này kiểu tls, tức chứa xác thức SSL


kubectl create secret tls secret-nginx-cert --cert=certs/tls.crt  --key=certs/tls.key

# Secret này tạo ra thì mặc định nó đặt tên file là tls.crt và tls.key có thể xem với lệnh

kubectl describe secret/secret-nginx-cert

#Sử dụng Secret cho Pod

6.nginx.yaml

### chạy file đó là oK xog