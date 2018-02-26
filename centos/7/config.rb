$vm_memory = 8196
$vm_cpus = 4

$shared_folders = {
   '/Users/yoaneskoesno/Development/AWS/' => '/home/vagrant/AWS/',
   '/Users/yoaneskoesno/Development/workspace' => '/home/vagrant/workspace'
}

$shared_files = {
   '/Users/yoaneskoesno/.ssh/github.key' => '/home/vagrant/.ssh/github.key'
}

$storage = {
   '../storage/hdd1.vdi' => '250000'
}
