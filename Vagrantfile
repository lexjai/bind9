BOX_IMAGE = "ubuntu/focal64"
DOMAIN = "aula104.local"
DNSIP = "192.168.1.12"
LAB = "bind9"

$apache = <<-SHELL
  sudo apt update
  sudo apt-get -y install apache2
SHELL

$nginx = <<-SHELL
  sudo apt update
  sudo apt -y install nginx
  SHELL

$dnsclient = <<-SHELL
  echo -e "nameserver $1\ndomain aula104.local">/etc/resolv.conf
SHELL

services ={
  "apache1"=>{:ip=>"192.168.1.15", :provision=>$apache},
  "apache2"=>{:ip=>"192.168.1.10", :provision=>$apache},
  "nginx"=>{:ip=>"192.168.1.25", :provision=>$nginx},
}

Vagrant.configure("2") do |config|
  # config general
  config.vm.box = BOX_IMAGE

  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = 1024
    vb.customize ["modifyvm", :id, "--groups", "/DNSLAB9"]
  end

  # dns 
  config.vm.define "dns" do |guest|
    guest.vm.provider "virtualbox" do |vb, subconfig|
      vb.name = "dns"
      subconfig.vm.hostname = "dns.#{DOMAIN}"
      subconfig.vm.network :private_network, ip: DNSIP,  virtualboxintnet: LAB # ,  name: RED #
    end
    guest.vm.provision "shell", name: "dns-server", path: "enable-bind9.sh", args: DNSIP
  end

  #services
  services.each_with_index do |(hostname, info),index|
    puts hostname
    config.vm.define hostname do |guest|
      guest.vm.provider "virtualbox" do |vs, subconfig|
        vs.name = hostname
        subconfig.vm.hostname = hostname
        subconfig.vm.network :private_network, ip: info[:ip], virtualboxintnet: LAB
      end
      guest.vm.provision "shell", name: "services", path: "enable-bind9.sh", args: DNSIP
    end
  end
  # clients DHCP
  (1..1).each do |id|
    config.vm.define "client#{id}" do |guest|
      guest.vm.provider "virtualbox" do |vb, subconfig|
        vb.name = "client#{id}"
        if id>1
          vb.gui = true
          vb.cpus = 2
          vb.memory = 2048
          subconfig.vm.box = BOX_DESKTOP
          subconfig.vbguest.auto_update = true
        end
        subconfig.vm.hostname = "client#{id}.#{DOMAIN}"

        subconfig.vm.network :private_network, ip: "192.168.33.#{150+id}",  virtualboxintnet: LAB
      end
      guest.vm.provision "shell", name: "dns-client", inline: $dnsclient, args: DNSIP
      guest.vm.provision "shell", name: "testing", inline: <<-SHELL
        dig google.com +short
        dig -x 192.168.1.10 +short
        ping -a -c 1 google.com
        ping -a -c 1 ns2
      SHELL
    end
  end
end