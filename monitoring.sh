#!/bin/bash

# 1. アーキテクチャとカーネルバージョン
arch=$(uname -a)

# 2. 物理CPUの数
pcpu=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

# 3. 仮想CPUの数
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)

# 4. 現在のメモリ使用率と合計 (MB単位とパーセンテージ)
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# 5. 現在のディスク使用率と合計 (GB/MB単位とパーセンテージ)
fdisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
udisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
pdisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t += $2} END {printf("%d"), disk_u/disk_t*100}')

# 6. CPU使用率 (アイドル率から100を引いて計算)
cpul=$(top -bn1 | grep "^%Cpu" | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')

# 7. 最終再起動日時
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# 8. LVMがアクティブかどうか
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# 9. アクティブなTCP接続数
tcpc=$(ss -neopt state established | wc -l)

# 10. ログイン中のユーザー数
ulog=$(users | wc -w)

# 11. IPアドレスとMACアドレス
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# 12. sudoが実行された合計回数 (ログフォルダからカウント)
cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# wallコマンドで全画面に通知出力
cat << EOF "	#Architecture: $arch
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: $uram/${fram}MB ($pram%)
	#Disk Usage: $udisk/${fdisk} ($pdisk%)
	#CPU load: $cpul
	#Last boot: $lb
	#LVM use: $lvmu
	#Connexions TCP: $tcpc ESTABLISHED
	#User log: $ulog
	#Network: IP $ip ($mac)
	#Sudo: $cmnd cmd"
EOF