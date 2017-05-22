bash 'Install java' do
  code <<-EOH
    cd /tmp &&
    curl -Lo jdk-8-linux-x64.rpm --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.rpm
    EOH
  not_if { ::File.exist?('/tmp/jdk-8-linux-x64.rpm') }
end

rpm_package 'Oracle Java' do
 source '/tmp/jdk-8-linux-x64.rpm'
end
