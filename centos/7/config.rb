$vm_memory = 8196
$vm_cpus = 4

$forwarded_ports = {
   '8080' => '8080',
   '8090' => '8090',
   '18090' => '18090',
   '8085' => '8085',
   '54663' => '54663',
   '9060' => '9060',
   '9080' => '9080',
   '9043' => '9043',
   '1521' => '1521'
}

$shared_folders = {
   '/Users/koesnoy/Development/AWS/' => '/home/vagrant/AWS/',
   '/Users/koesnoy/Development/workspace' => '/home/vagrant/workspace',
   '/Users/koesnoy/Development/workspace/tab/keno' => '/home/vagrant/.ssh/keno'
}

$shared_files = {
   '/Users/koesnoy/.ssh/yk_od_aws' => '/home/vagrant/.ssh/yk_od_aws',
   '/Users/koesnoy/.ssh/github.key' => '/home/vagrant/.ssh/github.key'
}

$storage = {
   '../storage/hdd1.vdi' => '250000'
}
