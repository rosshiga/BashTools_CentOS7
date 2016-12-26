#!/bin/sh
####################
# A minimal CentOS 7 Deployment Script 
# Options
#
USER="ross"
TIMEZONE="Pacific/Honolulu"
PACKAGES="wget"
SSHKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCls7blTjrl6awhBw0VdwqvrmdedaAm9+bF7dViHW/AbA4xXl34vhyJej4dNQO2S8hYxVeikpk4q2vfAA3I6N4lzxy7oISggu9cIBMlmFhRDrkM2SeuIkE7J+SP9Azx4m9CBHrULRfYfAShnAFHsr2MqqFKt1vKXxSi9MlQ1gBsz/RNg9WJKXOmtKZOkmZm92hGL6QhZPQKK6R5pL2M9c/OssUCTDq8qA0EvYMYyP/fLmNSKogGGajFtMlGloIyCNpBis9O7m5Bggxd8uMfLyLfuM6V02MOwPAe8gol52t+TPiEf5J14rwKxu7JkRQ6eTVbCk+EuKaH6APLiDuw7J5Z Asterisk-AWS"
###################

timedatectl set-timezone $TIMEZONE
authconfig --passalgo=sha512 --update

useradd $USER -c "Administrator"
usermod -aG wheel $USER
sudo passwd -d $USER


passwd -l root
chage -d 0 $USER

mkdir -p /home/$USER/.ssh

echo $SSHKEY > /home/$USER/.ssh/authorized_keys

chown $USER:$USER -R /home/$USER/.ssh
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys

sed -i -e "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

cat >>/etc/ssh/sshd_config <<EOL
PermitRootLogin no
MaxAuthTries 5
MaxSessions 8
RSAAuthentication yes
PubkeyAuthentication yes
EOL

yum install -y epel-release 
yum -y update
yum install -y yum-cron fail2ban $PACKAGES

echo "nameserver 8.8.8.8" > /etc/resolv-peerdns.conf
echo "nameserver 8.8.4.4" >> /etc/resolv-peerdns.conf

sed -i -e "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf

systemctl enable firewalld.service
systemctl start firewalld.service
systemctl enable crond
systemctl enable ntpd


cd /etc/fail2ban
cp fail2ban.conf fail2ban.local
cp jail.conf jail.local
sed -i -e "s/backend = auto/backend = systemd/" /etc/fail2ban/jail.local
systemctl enable fail2ban


cat >>/etc/sysctl.conf <<EOL
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_max_syn_backlog = 1280
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.core.wmem_max=4194304
net.core.rmem_max=12582912
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 87380 4194304
kernel.exec-shield = 1
kernel.randomize_va_space=2
fs.suid_dumpable = 0
EOL

sysctl -p

touch /etc/security/limits.d/core.conf
echo "* hard core 0" > /etc/security/limits.d/core.conf
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf