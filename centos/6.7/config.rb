$vm_memory = 8192

$forwarded_ports = {
   '8080' => '8080',
   '8085' => '8085',
   '54663' => '54663',
   '9060' => '9060',
   '9080' => '9080',
   '9043' => '9043'
}

$shared_folders = {
   '/Users/ykoesno/Development/workspace/' => '/home/vagrant/workspace',
   '/Users/ykoesno/Development/workspace/devops-tools/ansible/' => '/home/vagrant/ansible/',
   '/Users/ykoesno/Development/workspace/anz-setup' => '/home/vagrant/anz_setup'
}

$shared_files = {
   '/Users/ykoesno/.ssh/config' => '/home/vagrant/.ssh/config',
   '/Users/ykoesno/.ssh/devops.centos7.key' => '/home/vagrant/.ssh/devops.centos7.key',
   '/Users/ykoesno/.ssh/root.centos7.key' => '/home/vagrant/.ssh/root.centos7.key',
   '/Users/ykoesno/.ssh/macmini.devops.key' => '/home/vagrant/.ssh/macmini.devops.key',
   '/Users/ykoesno/.ssh/dev1sol.aubdccddga.key' => '/home/vagrant/.ssh/dev1sol.aubdccddga.key'
}
