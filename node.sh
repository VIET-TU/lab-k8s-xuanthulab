kubectl [command] [TYPE] [NAME] [flags]
# Trong đó:

# [command] là lệnh, hành động như apply, get, delete, describe ...
# [TYPE] kiểu tài nguyên như ns, no, po, svc ...
# [NAME] tên đối tượng lệnh tác động
# [flags] các thiết lập, tùy thuộc loại lệnh
# Cách lệnh làm việc với POD ở phần này:

 kubectl api-resources ## liệt ke ra các type

#****************NODE******************

 ## hiển thị chi tiết hơn
 kubectl get no k8s-master-1 -o wide  
 # xem thong tin file yaml
 kubectl get no k8s-master-1 -o yaml 

kubectl get nodes	#Danh sách các Node trong Cluster
kubectl describe node k8s-master-1	#Thông tin chi tiết về Node có tên name-node    

## label: nhãn dùng để ta lựa chon các cái node thích hợp, ta muốn ấn định một cái pod chạy một node nào đó theo nhãn mà ta chọn
# gán nhãn cho một đối tượng như: service, pod, node, ...
kubectl lable node k8s-master-1 key_lable=value_lable # (nodeabc=dechayungudngphp)
kubectl get node -l "nodeabc"

#xóa nhãn cho node
kubectl label node k8s-master-1 nodeabc-

#****************POD******************



