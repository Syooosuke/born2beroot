#!/bin/bash

# 1. アーキテクチャとカーネルバージョン
arch=$(uname -a)

# 2. 物理CPUの数
pcpu=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

# 3. 仮想CPUの数
vcpu=$(grep -c "^processor" /proc/cpuinfo)

# 4. メモリの使用量/合計(MB)と使用率
mem=$(free -m | awk '/^Mem:/ {printf "%d/%dMB (%.2f%%)", $3, $2, $3/$2*100}')

# 5. ディスクの使用量(MB)/合計(GB)と使用率 (/boot は除く)
disk=$(df -m | awk '/^\/dev\// && $6 != "/boot" {u += $3; t += $2} END {printf "%d/%.1fGb (%d%%)", u, t/1024, u/t*100}')

# 6. CPU使用率 (100からアイドル率を引いて計算)
cpu=$(vmstat 1 2 | tail -1 | awk '{printf "%.1f%%", 100 - $15}')

# 7. 最終起動日時
lb=$(who -b | awk '{print $3, $4}')

# 8. LVMがアクティブかどうか
if lsblk | grep -q "lvm"; then lvm="yes"; else lvm="no"; fi

# 9. アクティブなTCP接続数
tcp=$(ss -Ht state established | wc -l)

# 10. ログイン中のユーザー数
ulog=$(users | wc -w)

# 11. IPアドレスとMACアドレス
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link | awk '/link\/ether/ {print $2; exit}')

# 12. sudoが実行された合計回数 (ログフォルダのログファイルからカウント)
sudo_count=$(grep -c "COMMAND=" /var/log/sudo/sudo.log)

# wallコマンドで全端末に通知出力
wall << EOF
#Architecture: $arch
#Physical CPU: $pcpu
#vCPU: $vcpu
#Memory Usage: $mem
#Disk Usage: $disk
#CPU load: $cpu
#Last boot: $lb
#LVM use: $lvm
#TCP Connections: $tcp ESTABLISHED
#User log: $ulog
#Network: IP $ip ($mac)
#Sudo: $sudo_count cmd
EOF
