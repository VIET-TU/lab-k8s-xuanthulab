# DaemonSet Job và CronJob trong Kubernetes

Sử dụng DaemonSet tạo các Pod chạy trên từng Node, thi hành tác vụ vụ Job, tự động chạy các tác vụ với CronJob

DaemonSet tương tự như ReplicaSet, điểm khác là tạo ra trên mỗi Node một pod

## DaemonSet trong Kubernetes

- DaemonSet (ds) đảm bảo chạy trên mỗi NODE một bản copy của POD. Triển khai DaemonSet khi cần ở mỗi máy (Node) một POD, `thường dùng cho các ứng dụng như thu thập log, tạo ổ đĩa trên mỗi Node ... Dưới đây là ví dụ về DaemonSet, nó tạo tại mỗi Node một POD chạy nginx`

# Liệt kê các DaemonSet

kubectl get ds -o wide

# Liệt kê các POD theo nhãn

kubectl get pod -o wide -l "app=ds-nginx"

# Chi tiết về ds

kubectl describe ds/dsapp

# Xóa DaemonSet

kubectl delete ds/dsapp

- Khi một pod bị xóa trên một node thì DaemonSet sẽ ngay lập tạo một pod mới trên node đó để thay thể đảm bảo mỗi node có 1 pod (Không tạo trên Node master)

```SH
 kubectl describe node master-1
```

===> Bời vì: `Taints:  node-role.kubernetes.io/control-plane:NoSchedule`, nghĩa là nó thiết lập node này không được phép triển khai chạy các pod, nếu node master cũng chạy các pod thì Phải xóa Taints này

# xóa taint trên node master.xtl cho phép tạo Pod

```sh
    kubectl taint node master-1 node node-role.kubernetes.io/control-plane-
```

===> Thì lúc này ngay lập tức DeamonSet sẽ tạo trên node master này để đảm bảo mỗi Node đều có 1 pod

# thêm taint trên node master.xtl ngăn tạo Pod trên nó

```sh
    kubectl taint node master-1 node node-role.kubernetes.io/control-plane:NoSchedule
```

# Job trong Kubernetes

- Job (jobs) có chức năng tạo các POD đảm bảo nó chạy và kết thúc thành công. Khi các POD do Job tạo ra chạy và kết thúc thành công thì Job đó hoàn thành. Khi bạn xóa Job thì các Pod nó tạo cũng xóa theo. Một Job có thể tạo các Pod chạy tuần tự hoặc song song. `Sử dụng Job khi muốn thi hành một vài chức năng hoàn thành xong thì dừng lại (ví dụ backup, kiểm tra, clean up ...)`

Khi Job tạo Pod, Pod chưa hoàn thành nếu Pod bị xóa, lỗi Node ... nó sẽ thực hiện tạo Pod khác để thi hành tác vụ.

# Triển khai 1 job

kubectl apply -f 2.job.yaml

# Thông tin job có tên myjob

kubectl describe job/myjob

```sh
    Every 1.0s: kubectl get all -o wide                                                                 master-1: Mon Jul 29 12:04:50 2024

NAME              READY   STATUS      RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
pod/myjob-58td9   0/1     Completed   0          3m1s    10.0.3.125   node-1   <none>           <none>
pod/myjob-bxtzv   0/1     Completed   0          2m48s   10.0.2.184   node-2   <none>           <none>
pod/myjob-drs8k   0/1     Completed   0          2m49s   10.0.3.4     node-1   <none>           <none>
pod/myjob-h6r2h   0/1     Completed   0          2m55s   10.0.2.230   node-2   <none>           <none>
pod/myjob-hlf96   0/1     Completed   0          2m42s   10.0.3.110   node-1   <none>           <none>
pod/myjob-j269t   0/1     Completed   0          2m42s   10.0.2.49    node-2   <none>           <none>
pod/myjob-kbwj7   0/1     Completed   0          3m9s    10.0.2.214   node-2   <none>           <none>
pod/myjob-ph6sk   0/1     Completed   0          2m55s   10.0.3.2     node-1   <none>           <none>
pod/myjob-v6gpg   0/1     Completed   0          3m9s    10.0.3.163   node-1   <none>           <none>
pod/myjob-w8vbp   0/1     Completed   0          3m2s    10.0.2.89    node-2   <none>           <none>
pod/tools         1/1     Running     0          169m    10.0.2.220   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE    SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d2h   <none>

NAME              COMPLETIONS   DURATION   AGE    CONTAINERS   IMAGES    SELECTOR
job.batch/myjob   10/10         34s        3m9s   busybox      busybox   batch.kubernetes.io/controller-uid=2dcd44df-a664-40a5-97bf-0a

kubectl describe job/myjob

Duration:                 34s # thời gian hoàn thành
Active Deadline Seconds:  120s # thời gian tối đa để hoàn thành công việc


 k logs pod/myjob-58td9
Mon Jul 29 12:01:53 UTC 2024
Job executed
root@master-1:/xuan-thu-lab/k8s/ds-job-rj#
```

===> Một Job được coi là thành công , khi nó tạo thành công các pod và chạy thành công các lệnh trong container pod đó và container phải kết thúc bằng mã kết thúc thành công (vd chạy lệnh không có trong image này có nghĩa là container được tạo ra rồi chạy nó sẽ thoát với một mã là không thành công => Khi đó sẽ bão tác vụ không thông công)

```sh

NAME              READY   STATUS       RESTARTS   AGE    IP           NODE     NOMINATED NODE   READINESS GATES
pod/myjob-jpxph   0/1     StartError   0          42s    10.0.2.71    node-2   <none>           <none>
pod/myjob-k6pbh   0/1     StartError   0          17s    10.0.3.61    node-1   <none>           <none>
pod/myjob-t8v9q   0/1     StartError   0          17s    10.0.2.41    node-2   <none>           <none>
pod/myjob-xxppp   0/1     StartError   0          42s    10.0.3.157   node-1   <none>           <none>
pod/tools         1/1     Running      0          175m   10.0.2.220   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE    SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d2h   <none>

NAME              COMPLETIONS   DURATION   AGE   CONTAINERS   IMAGES    SELECTOR
job.batch/myjob   0/10          42s        42s   busybox      busybox   batch.kubernetes.io/controller-uid=33640882-3e11-43f4-be0d-aa9976986478

 k logs pod/myjob-58td9

Pods Statuses:            0 Active (0 Ready) / 0 Succeeded / 4 Failed # Không tác vụ Success, 4 tác vụ Failed (Nếu vượt quá 3 tác vụ Faild sẽ dừng)
```

# CronJob trong Kubernetes

CronJob (cj) - chạy các Job theo một lịch định sẵn. Việc lên lịch cho CronJob khai báo giống Cron của Linux. Xem Sử dụng Cron, Crontab từ động chạy script trên Server Linux

- 3.cronjob.yaml

Tìm hiểu định dạng các dòng Crontab
Mỗi dòng crontab có định lưu các số liệu sau:

```sh
*       	*       	*       	*       	*              	script
phút        giờ         ngày        tháng       thứ         lệnh hoặc script được chạy
1 - 59      0 - 23      1 - 31      tháng       0 - 7
                                                0=chủ nhật
                                                7=thứ bảy

```

_[phút] _[giờ] _[ngày trong tháng] _[tháng] \*[thứ] [lệnh chạy (script hoặc lệnh linux)]

Điền số 30 vào cột phút, các cột giờ, ngày, tháng, thứ điền \* vì xảy ra mọi giờ, mọi ngày, mọi tháng. Vậy dòng crontab phù hợp như sau:

30 \* \* \* \* /script/abc.sh
Tương tự như vậy xem một số ví dụ sau:

#Chạy vào lúc 3 giờ hàng ngày
0 3 \* \* _ /script/abc.sh
#Chạy vào lúc 17h ngày chủ nhật hàng tuần
0 17 _ _ sun /scripts/abc.sh
#Cứ 8 tiếng là chạy
0 _/8 \* \* _ /scripts/abc.sh
#Cứ 30 phút chạy một lần
_/30 \* \* \* \* /script/abc.sh

# Demo

```sh
    Every 1.0s: kubectl get all -o wide                                                                                       master-1: Mon Jul 29 12:30:13 2024

NAME                           READY   STATUS      RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
pod/mycronjob-28704268-64jmw   0/1     Completed   0          2m13s   10.0.3.251   node-1   <none>           <none>
pod/mycronjob-28704269-8rwlp   0/1     Completed   0          73s     10.0.3.175   node-1   <none>           <none>
pod/mycronjob-28704270-zg2tv   0/1     Completed   0          13s     10.0.3.77    node-1   <none>           <none>
pod/tools                      1/1     Running     0          3h14m   10.0.2.220   node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE    SELECTOR
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d2h   <none>

NAME                      SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE     CONTAINERS   IMAGES    SELECTOR
cronjob.batch/mycronjob   */1 * * * *   False     0        13s             2m29s   busybox      busybox   <none>

NAME                           COMPLETIONS   DURATION   AGE     CONTAINERS   IMAGES    SELECTOR
job.batch/mycronjob-28704268   1/1           7s         2m13s   busybox      busybox   batch.kubernetes.io/controller-uid=528fed78-bc7f-4d83-9b67-ab87c350b1c0
job.batch/mycronjob-28704269   1/1           8s         73s     busybox      busybox   batch.kubernetes.io/controller-uid=96bd6390-6a47-4291-9ee5-316323ac4fe1
job.batch/mycronjob-28704270   1/1           8s         13s     busybox      busybox   batch.kubernetes.io/controller-uid=eb9db078-22e6-4bd8-b490-a473f5c98a

# Cứ mỗi phút thì có một Job được khởi tạo Và lưu tối đa là 3 Job (Job cũ sẽ bị xóa đi cùng với pod mà nó tạo)
```
