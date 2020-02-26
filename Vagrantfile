N = 5

Vagrant.configure("2") do |config|
  
  # K8s Master
  config.vm.define "k8s-master" do |master|
    master.vm.box = "bento/ubuntu-16.04"
    master.vm.network "private_network", ip: "192.168.50.10"
    master.vm.hostname = "k8s-master"    
    master.vm.provision :shell, path: "deploy/deploy.sh"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
      vb.name = "k8s-master"
    end
  end
  
  # K8s Nodes
  (1..N).each do |i|
    config.vm.define "k8s-node-#{i}" do |node|
      node.vm.box = "bento/ubuntu-16.04"
      node.vm.network "private_network", ip: "192.168.50.#{i + 10}"
      node.vm.hostname = "k8s-node-#{i}"
      node.vm.provision :shell, path: "deploy/deploy.sh"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "4"
        vb.name = "k8s-node-#{i}"
      end
    end
  end

end
