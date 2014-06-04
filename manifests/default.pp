class windfly-env{
	include apt
	include maven

	$wildfly_url = "http://download.jboss.org/wildfly/8.1.0.CR2/wildfly-8.1.0.CR2.tar.gz"
	
	apt::ppa { "ppa:webupd8team/java": }

	exec { 'apt-get update':
		command => '/usr/bin/apt-get update',
		before => Apt::Ppa['ppa:webupd8team/java'],
	}

	exec { 'apt-get update 2':
    		command => '/usr/bin/apt-get update',
    		require => [ Apt::Ppa["ppa:webupd8team/java"], Package["git-core"] ],
  	}
		
	package { ["vim",
        		"curl",
                	"git-core",
                	"expect",
                	"bash"]:
    		ensure => present,
    		require => Exec["apt-get update"],
    		before => Apt::Ppa["ppa:webupd8team/java"],
	}

        package { ["oracle-java7-installer"]:
        	ensure => present,
	        require => Exec["apt-get update 2"],
  	}

  	exec {
    		"accept_license":
    		command => "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections",
    		cwd => "/home/vagrant",
    		user => "vagrant",
    		path    => "/usr/bin/:/bin/",
    		require => Package["curl"],
    		before => Package["oracle-java7-installer"],
    		logoutput => true,
  	}

	maven::settings { 'mvn-settings' :
                local_repo          => '/vagrant/maven/.m2/repository'
  	}

  	Exec {
    		path  => "${::path}",
  	}

	package { "wget":
		ensure => installed,
	}

	user { "vagrant":
    		ensure    => present,
    		comment   => "Wildfly User",
    		home      => "/home/vagrant",
    		shell     => "/bin/bash",
  	}

  	exec { "check_wildfly_url":
    		cwd       => "/tmp",
    		command   => "wget -S --spider ${wildfly_url}",
    		timeout   => 900,
    		require   => Package["wget"],
    		notify    => Exec["get_wildfly"],
    		logoutput => "on_failure"
  	}

  	exec { "get_wildfly":
    		cwd       => "/tmp",
    		command   => "wget ${wildfly_url} -O wildfly.tar.gz > /opt/.get_wildfly",
    		creates   => "/opt/.get_wildfly",
    		timeout   => 900,
    		require   => Package["wget"],
    		notify    => Exec["extract_wildfly"],
    		logoutput => "on_failure"
  	}

  	exec { "extract_wildfly":
    		cwd         => "/vagrant",
    		command     => "tar zxf /tmp/wildfly.tar.gz; mv wildfly* wildfly",
    		creates     => "/vagrant/tomcat",
    		require     => Exec["get_wildfly"],
    		refreshonly => true,
  	}

	exec { "add_admin_user":
		command		=> "/vagrant/wildfly/bin/add-user.sh admin password --silent=true",
		logoutput	=> true,
		require		=> Exec["extract_wildfly"],
		path		=> "/usr/local/bin:/bin/:/usr/bin",
	}

}

include windfly-env
