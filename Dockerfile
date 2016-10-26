###############################################################################
# base os and tools
# purdygoodengineering/docker-pge-base-centos6
# https://github.com/purdygood/docker-pge-hadoop-273-centos6
###############################################################################

from centos:centos6.7
  
  # maintainer
  maintainer matthew purdy <matthew.purdy@purdygoodengineering.com>
  
  # add custom bashrc
  add pge_bashrc /root/pge_bashrc
   
  run yum -y update kernel*
  run yum -y install wget httpd sed gcc kernel-devel kernel-headers bind-utils nmap dkms make bzip2 perl    \
                     vim-common vim-enhanced mlocate tree curl tar wget unzip libcurl openssh-clients       \
                     openssh-server rsync selinux-policy
  
  # turn sshd on
  run service sshd start
  run chkconfig sshd on

  # install java8
  run mkdir -p /tmp/pge/java \
    && wget --quiet --output-document /tmp/pge/java/jdk-8u102-linux-x64.rpm                                 \
            --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
            http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.rpm 
  run rpm -ivh /tmp/pge/java/jdk-8u102-linux-x64.rpm 
  run echo ''                                                                          >> /etc/environment  \
    && echo 'BASE_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'   >> /etc/environment  \
    && echo 'export JAVA_HOME=/usr/java/default'                                       >> /etc/environment  \
    && echo 'export PATH=$JAVA_HOME/bin:$BASE_PATH'                                    >> /etc/environment  \
    && echo ''                                                                         >> /etc/environment  \
    && echo 'source /root/pge_bashrc'                                                  >> /etc/environment  \
    && echo ''                                                                         >> /etc/environment  \
    && echo ''                                                                         >> /root/.bashrc     \
    && echo 'BASE_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'   >> /root/.bashrc     \
    && echo 'export JAVA_HOME=/usr/java/default'                                       >> /root/.bashrc     \
    && echo 'export PATH=$JAVA_HOME/bin:$BASE_PATH'                                    >> /root/.bashrc     \
    && echo ''                                                                         >> /root/.bashrc     \
    && echo 'source $HOME/pge_bashrc'                                                  >> /root/.bashrc     \
    && echo ''                                                                         >> /root/.bashrc     \     
    && source /root/.bashrc
  env JAVA_HOME /usr/java/default
  
  # disable selinx
  #run rm -f /etc/selinux/*.conf \
  run sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
 
  # disable ssh strict host checking
  run sed -i "s/# *StrictHostKeyChecking ask/StrictHostKeyChecking no/" /etc/ssh/ssh_config
  
  # disable pam for sshd
  run sed -i "s/#UsePAM no/UsePAM no/" /etc/ssh/sshd_config \
    && sed -i "s/UsePAM yes/#UsePAM yes/" /etc/ssh/sshd_config
  
  # turn off swappiness
  run echo 0 > /proc/sys/vm/swappiness & echo '\n#turn of swappiness \nvm.swappiness = 0' >> /etc/sysctl.conf
  
  # add ssh keys
  run mkdir /root/.ssh
  add ssh /root/.ssh 
  run chmod 644 /root/.ssh/id_rsa.pub       \
    && chmod 600 /root/.ssh/id_rsa          \
    && chmod 600 /root/.ssh/authorized_keys \
    && chmod 755 /root/.ssh
  

