require 'spec_helper'

['Debian', 'RedHat', 'Archlinux', 'Amazon', 'Gentoo'].each do |osfamily|

  describe 'docker::run', :type => :define do
    let(:title) { 'sample' }

    context "on #{osfamily}" do

    if osfamily == 'Debian'
      let(:facts) { {
        :osfamily               => 'Debian',
        :lsbdistid              => 'Ubuntu',
        :operatingsystem        => 'Ubuntu',
        :lsbdistcodename        => 'trusty',
        :operatingsystemrelease => '14.04',
        :kernelrelease          => '3.8.0-29-generic'
      } }
      initscript = '/etc/init.d/docker-sample'
      command = 'docker'
      systemd = false
    elsif osfamily == 'Archlinux'
      let(:facts) { {:osfamily => osfamily} }
      initscript = '/etc/systemd/system/docker-sample.service'
      command = 'docker'
      systemd = true
    elsif osfamily == 'Gentoo'
      let(:facts) { {:osfamily => osfamily} }
      initscript = '/etc/init.d/docker-sample'
      command = 'docker'
      systemd = false
    elsif osfamily == 'RedHat'
      let(:facts) { {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '6.6',
        :operatingsystemmajrelease => '6',
      } }
      initscript = '/etc/init.d/docker-sample'
      command = 'docker'
      systemd = false
    else
      let(:facts) { {
        :osfamily => 'RedHat',
        :operatingsystem => 'Amazon',
        :operatingsystemrelease => '2015.09',
        :operatingsystemmajrelease => '2015',
      } }
      initscript = '/etc/init.d/docker-sample'
      command = 'docker'
      systemd = false
    end

    context 'passing the required params' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should compile.with_all_deps }
      it { should contain_service('docker-sample') }
      it { should_not contain_service('docker') }
      if (osfamily == 'Debian')
        it { should contain_file(initscript).with_content(/\$docker run/) }
        it { should contain_file(initscript).with_content(/#{command}/) }
      else
        it { should contain_file(initscript).with_content(/#{command} run/).with_content(/base/) }
        it { should contain_file(initscript).with_content(/#{command} run/).with_content(/command/) }
      end

      ['p', 'dns', 'H', 'dns-search', 'u', 'v', 'e', 'n', 't', 'volumes-from', 'name'].each do |search|
        it { should_not contain_file(initscript).with_content(/-${search}/) }
      end
    end

    context 'when passing `after` containers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'after' => ['foo', 'bar']} }
      if (systemd)
        it { should contain_file(initscript).with_content(/After=(.*\s+)?docker-foo.service/) }
        it { should contain_file(initscript).with_content(/After=(.*\s+)?docker-bar.service/) }
        it { should contain_file(initscript).with_content(/Wants=(.*\s+)?docker-foo.service/) }
        it { should contain_file(initscript).with_content(/Wants=(.*\s+)?docker-bar.service/) }
      else
        if (osfamily == 'Gentoo')
          it { should contain_file(initscript).with_content(/after.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/after.*\s+docker-bar/) }
        else
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-bar/) }
        end
      end
    end

    context 'when passing `depends` containers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'depends' => ['foo', 'bar']} }
      if (systemd)
        it { should contain_file(initscript).with_content(/After=(.*\s+)?docker-foo.service/) }
        it { should contain_file(initscript).with_content(/After=(.*\s+)?docker-bar.service/) }
        it { should contain_file(initscript).with_content(/Requires=(.*\s+)?docker-foo.service/) }
        it { should contain_file(initscript).with_content(/Requires=(.*\s+)?docker-bar.service/) }
      else
        if (osfamily == 'Gentoo')
          it { should contain_file(initscript).with_content(/after.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/after.*\s+docker-bar/) }
          it { should contain_file(initscript).with_content(/need.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/need.*\s+docker-bar/) }
        else
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-bar/) }
          it { should contain_file(initscript).with_content(/Required-Stop:.*\s+docker-foo/) }
          it { should contain_file(initscript).with_content(/Required-Stop:.*\s+docker-bar/) }
        end
      end
    end

    context 'when passing `depend_services`' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'depend_services' => ['foo', 'bar']} }
      if (systemd)
        it { should contain_file(initscript).with_content(/After=(.*\s+)?foo.service/) }
        it { should contain_file(initscript).with_content(/After=(.*\s+)?bar.service/) }
        it { should contain_file(initscript).with_content(/Requires=(.*\s+)?foo.service/) }
        it { should contain_file(initscript).with_content(/Requires=(.*\s+)?bar.service/) }
      else
        if (osfamily == 'Gentoo')
          it { should contain_file(initscript).with_content(/after.*\s+foo/) }
          it { should contain_file(initscript).with_content(/after.*\s+bar/) }
          it { should contain_file(initscript).with_content(/need.*\s+foo/) }
          it { should contain_file(initscript).with_content(/need.*\s+bar/) }
        else
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+foo/) }
          it { should contain_file(initscript).with_content(/Required-Start:.*\s+bar/) }
          it { should contain_file(initscript).with_content(/Required-Stop:.*\s+foo/) }
          it { should contain_file(initscript).with_content(/Required-Stop:.*\s+bar/) }
        end
      end
    end

    context 'removing containers and volumes' do
      context 'when trying to remove the volume and not the container on stop' do
        let(:params) {{
          'command' => 'command',
          'image' => 'base',
          'remove_container_on_stop' => false,
          'remove_volume_on_stop' => true,
        }}
        it do
          expect {
            should contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'when trying to remove the volume and not the container on start' do
        let(:params) {{
          'command' => 'command',
          'image' => 'base',
          'remove_container_on_start' => false,
          'remove_volume_on_start' => true,
        }}
        it do
          expect {
            should contain_service('docker-sample')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'when not removing containers on container start and stop' do
        let(:params) {{
          'command' => 'command',
          'image' => 'base',
          'remove_container_on_start' => false,
          'remove_container_on_stop' => false,
        }}
        if (systemd)
          it { should_not contain_file(initscript).with_content(/ExecStartPre=-\/usr\/bin\/docker rm/) }
        else
          it { should_not contain_file(initscript).with_content(/\$docker rm  sample/) }
        end
      end

      context 'when removing containers on container start' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_container_on_start' => true} }
        if (systemd)
          it { should contain_file(initscript).with_content(/ExecStartPre=-\/usr\/bin\/docker rm/) }
        else
          it { should contain_file(initscript).with_content(/\$docker rm  sample/) }
        end
      end

      context 'when removing containers on container stop' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_container_on_stop' => true} }
        if (systemd)
          it { should contain_file(initscript).with_content(/ExecStop=-\/usr\/bin\/docker rm/) }
        else
          it { should contain_file(initscript).with_content(/\$docker rm  sample/) }
        end
      end

      context 'when not removing volumes on container start' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_volume_on_start' => false} }
        if (systemd)
          it { should_not contain_file(initscript).with_content(/ExecStartPre=-\/usr\/bin\/docker rm -v/) }
        else
          it { should_not contain_file(initscript).with_content(/\$docker rm -v sample/) }
        end
      end

      context 'when removing volumes on container start' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_volume_on_start' => true} }
        if (systemd)
          it { should contain_file(initscript).with_content(/ExecStartPre=-\/usr\/bin\/docker rm -v/) }
        else
          it { should contain_file(initscript).with_content(/\$docker rm -v/) }
        end
      end

      context 'when not removing volumes on container stop' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_volume_on_stop' => false} }
        if (systemd)
          it { should_not contain_file(initscript).with_content(/ExecStop=-\/usr\/bin\/docker rm -v/) }
        else
          it { should_not contain_file(initscript).with_content(/\$docker rm -v sample/) }
        end
      end

      context 'when removing volumes on container stop' do
        let(:params) { {'command' => 'command', 'image' => 'base', 'remove_volume_on_stop' => true} }
        if (systemd)
          it { should contain_file(initscript).with_content(/ExecStop=-\/usr\/bin\/docker rm -v/) }
        else
          it { should contain_file(initscript).with_content(/\$docker rm -v/) }
        end
      end
    end

    context 'with autorestart functionality' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      if (systemd)
        it { should contain_file(initscript).with_content(/Restart=on-failure/) }
      end
    end

    context 'when lxc_conf disables swap' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'lxc_conf' => 'lxc.cgroup.memory.memsw.limit_in_bytes=536870912'} }
      it { should contain_file(initscript).with_content(/-lxc-conf=\"lxc.cgroup.memory.memsw.limit_in_bytes=536870912\"/) }
    end

    context 'when `use_name` is true' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'use_name' => true } }
      it { should contain_file(initscript).with_content(/ --name sample /) }
    end

    context 'when stopping the service' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'running' => false} }
      it { should contain_service('docker-sample').with_ensure(false) }
    end

    context 'when passing a memory limit in bytes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory_limit' => '1000b'} }
      it { should contain_file(initscript).with_content(/-m 1000b/) }
    end

    context 'when passing a cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'cpuset' => '3'} }
      it { should contain_file(initscript).with_content(/--cpuset=3/) }
    end

    context 'when passing a multiple cpu cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'cpuset' => ['0', '3']} }
      it { should contain_file(initscript).with_content(/--cpuset=0,3/) }
    end

    context 'when not passing a cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/--cpuset=/) }
    end

    context 'when passing a links option' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'links' => ['example:one', 'example:two']} }
      it { should contain_file(initscript).with_content(/ --link example:one --link example:two /) }
    end

    context 'when passing a hostname' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'hostname' => 'example.com'} }
      it { should contain_file(initscript).with_content(/-h 'example.com'/) }
    end

    context 'when not passing a hostname' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/-h ''/) }
    end

    context 'when passing a username' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'username' => 'bob'} }
      it { should contain_file(initscript).with_content(/-u 'bob'/) }
    end

    context 'when not passing a username' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/-u ''/) }
    end

    context 'when passing a port number' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'ports' => '4444'} }
      it { should contain_file(initscript).with_content(/-p 4444/) }
    end

    context 'when passing a port to expose' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'expose' => '4666'} }
      it { should contain_file(initscript).with_content(/--expose=4666/) }
    end

    context 'when passing a label' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'labels' => 'key=value'} }
      it { should contain_file(initscript).with_content(/-l key=value/) }
    end

    context 'when passing a hostentry' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'hostentries' => 'dummyhost:127.0.0.2'} }
      it { should contain_file(initscript).with_content(/--add-host dummyhost:127.0.0.2/) }
    end

    context 'when connecting to shared data volumes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes_from' => '6446ea52fbc9'} }
      it { should contain_file(initscript).with_content(/--volumes-from 6446ea52fbc9/) }
    end

    context 'when connecting to several shared data volumes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes_from' => ['sample-linked-container-1', 'sample-linked-container-2']} }
      it { should contain_file(initscript).with_content(/--volumes-from sample-linked-container-1/) }
      it { should contain_file(initscript).with_content(/--volumes-from sample-linked-container-2/) }
    end

    context 'when passing several port numbers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'ports' => ['4444', '4555']} }
      it { should contain_file(initscript).with_content(/-p 4444/).with_content(/-p 4555/) }
    end

    context 'when passing several labels' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'labels' => ['key1=value1', 'key2=value2']} }
      it { should contain_file(initscript).with_content(/-l key1=value1/).with_content(/-l key2=value2/) }
    end

    context 'when passing several ports to expose' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'expose' => ['4666', '4777']} }
      it { should contain_file(initscript).with_content(/--expose=4666/).with_content(/--expose=4777/) }
    end

    context 'when passing serveral environment variables' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env' => ['FOO=BAR', 'FOO2=BAR2']} }
      it { should contain_file(initscript).with_content(/-e FOO=BAR/).with_content(/-e FOO2=BAR2/) }
    end

    context 'when passing an environment variable' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env' => 'FOO=BAR'} }
      it { should contain_file(initscript).with_content(/-e FOO=BAR/) }
    end

    context 'when passing serveral environment files' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env_file' => ['/etc/foo.env', '/etc/bar.env']} }
      it { should contain_file(initscript).with_content(/--env-file \/etc\/foo.env/).with_content(/--env-file \/etc\/bar.env/) }
    end

    context 'when passing an environment file' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env_file' => '/etc/foo.env'} }
      it { should contain_file(initscript).with_content(/--env-file \/etc\/foo.env/) }
    end

    context 'when passing serveral dns addresses' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns' => ['8.8.8.8', '8.8.4.4']} }
      it { should contain_file(initscript).with_content(/--dns 8.8.8.8/).with_content(/--dns 8.8.4.4/) }
    end

    context 'when passing a dns address' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns' => '8.8.8.8'} }
      it { should contain_file(initscript).with_content(/--dns 8.8.8.8/) }
    end

    context 'when passing serveral sockets to connect to' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'socket_connect' => ['tcp://127.0.0.1:4567', 'tcp://127.0.0.2:4567']} }
      it { should contain_file(initscript).with_content(/-H tcp:\/\/127.0.0.1:4567/) }
    end

    context 'when passing a socket to connect to' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'socket_connect' => 'tcp://127.0.0.1:4567'} }
      it { should contain_file(initscript).with_content(/-H tcp:\/\/127.0.0.1:4567/) }
    end

    context 'when passing serveral dns search domains' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns_search' => ['my.domain.local', 'other-domain.de']} }
      it { should contain_file(initscript).with_content(/--dns-search my.domain.local/).with_content(/--dns-search other-domain.de/) }
    end

    context 'when passing a dns search domain' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns_search' => 'my.domain.local'} }
      it { should contain_file(initscript).with_content(/--dns-search my.domain.local/) }
    end

    context 'when disabling network' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'disable_network' => true} }
      it { should contain_file(initscript).with_content(/-n false/) }
    end

    context 'when running privileged' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'privileged' => true} }
      it { should contain_file(initscript).with_content(/--privileged/) }
    end

    context 'should run with correct detached value' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      if (systemd)
        it { should_not contain_file(initscript).with_content(/--detach=true/) }
      else
        it { should contain_file(initscript).with_content(/--detach=true/) }
      end
    end

    context 'should be able to override detached' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'detach' => false} }
      it { should contain_file(initscript).without_content(/--detach=true/) }
    end

    context 'when running with a tty' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'tty' => true} }
      it { should contain_file(initscript).with_content(/-t/) }
    end

    context 'when passing serveral extra parameters' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'extra_parameters' => ['--rm', '-w /tmp']} }
      it { should contain_file(initscript).with_content(/--rm/).with_content(/-w \/tmp/) }
    end

    context 'when passing an extra parameter' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_file(initscript).with_content(/-c 4/) }
    end

    context 'when passing a data volume' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes' => '/var/log'} }
      it { should contain_file(initscript).with_content(/-v \/var\/log/) }
    end

    context 'when passing serveral data volume' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes' => ['/var/lib/couchdb', '/var/log']} }
      it { should contain_file(initscript).with_content(/-v \/var\/lib\/couchdb/) }
      it { should contain_file(initscript).with_content(/-v \/var\/log/) }
    end

    context 'when using network mode' do
      let(:params) { {'command' => 'command', 'image' => 'nginx', 'net' => 'host'} }
      it { should contain_file(initscript).with_content(/--net host/) }
    end

    context 'when `pull_on_start` is true' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'pull_on_start' => true } }
      it { should contain_file(initscript).with_content(/docker pull base/) }
    end

    context 'when `pull_on_start` is false' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'pull_on_start' => false } }
      it { should_not contain_file(initscript).with_content(/docker pull base/) }
    end

    context 'when `before_start` is set' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'before_start' => "echo before_start" } }
      it { should contain_file(initscript).with_content(/before_start/) }
    end

    context 'when `before_start` is not set' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'before_start' => false } }
      it { should_not contain_file(initscript).with_content(/before_start/) }
    end

    context 'when `before_stop` is set' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'before_stop' => "echo before_stop" } }
      it { should contain_file(initscript).with_content(/before_stop/) }
    end

    context 'when `before_stop` is not set' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'before_stop' => false } }
      it { should_not contain_file(initscript).with_content(/before_stop/) }
    end

    context 'with an title that will not format into a path' do
      let(:title) { 'this/that' }
      let(:params) { {'image' => 'base'} }

      if osfamily == 'Debian'
        new_initscript = '/etc/init.d/docker-this-that'
      elsif osfamily == 'Archlinux'
        new_initscript = '/etc/systemd/system/docker-this-that.service'
      else
        new_initscript = '/etc/init.d/docker-this-that'
      end

      it { should contain_service('docker-this-that') }
      it { should contain_file(new_initscript) }
    end

    context 'with manage_service turned off' do
      let(:title) { 'this/that' }
      let(:params) { {'image' => 'base', 'manage_service' => false} }

      if osfamily == 'Debian'
        new_initscript = '/etc/init.d/docker-this-that'
      elsif osfamily == 'Archlinux'
        new_initscript = '/etc/systemd/system/docker-this-that.service'
      else
        new_initscript = '/etc/init.d/docker-this-that'
      end

      it { should_not contain_service('docker-this-that') }
      it { should contain_file(new_initscript) }
    end

    context 'with service_prefix set to empty string' do
      let(:title) { 'this/that' }
      let(:params) { {'image' => 'base', 'service_prefix' => ''} }

      if osfamily == 'Debian'
        new_initscript = '/etc/init.d/this-that'
      elsif osfamily == 'Archlinux'
        new_initscript = '/etc/systemd/system/this-that.service'
      else
        new_initscript = '/etc/init.d/this-that'
      end

      it { should contain_service('this-that') }
      it { should contain_file(new_initscript) }
    end

    context 'with an invalid title' do
      let(:title) { 'with spaces' }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid image name' do
      let(:params) { {'command' => 'command', 'image' => 'with spaces', 'running' => 'not a boolean'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid running value' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'running' => 'not a boolean'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid memory value' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory' => 'not a number'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with a missing memory unit' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory' => '10240'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with restart policy set to no' do
      let(:params) { {'restart' => 'no', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_exec('run sample with docker') }
      it { should contain_exec('run sample with docker').with_unless(/\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_unless(/-a/) }
      it { should contain_exec('run sample with docker').with_command(/--cidfile=\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_command(/-c 4/) }
      it { should contain_exec('run sample with docker').with_command(/--restart="no"/) }
      it { should contain_exec('run sample with docker').with_command(/base command/) }
      it { should contain_exec('run sample with docker').with_timeout(0) }
    end

    context 'with restart policy set to always' do
      let(:params) { {'restart' => 'always', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_exec('run sample with docker') }
      it { should contain_exec('run sample with docker').with_unless(/\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_unless(/-a/) }
      it { should contain_exec('run sample with docker').with_command(/--cidfile=\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_command(/-c 4/) }
      it { should contain_exec('run sample with docker').with_command(/--restart="always"/) }
      it { should contain_exec('run sample with docker').with_command(/base command/) }
      it { should contain_exec('run sample with docker').with_timeout(0) }
    end

    context 'with restart policy set to on-failure' do
      let(:params) { {'restart' => 'on-failure', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_exec('run sample with docker') }
      it { should contain_exec('run sample with docker').with_unless(/\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_unless(/-a/) }
      it { should contain_exec('run sample with docker').with_command(/--cidfile=\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_command(/-c 4/) }
      it { should contain_exec('run sample with docker').with_command(/--restart="on-failure"/) }
      it { should contain_exec('run sample with docker').with_command(/base command/) }
      it { should contain_exec('run sample with docker').with_timeout(0) }
    end

    context 'with restart policy set to on-failure:3' do
      let(:params) { {'restart' => 'on-failure:3', 'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_exec('run sample with docker') }
      it { should contain_exec('run sample with docker').with_unless(/\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_unless(/-a/) }
      it { should contain_exec('run sample with docker').with_command(/--cidfile=\/var\/run\/docker-sample.cid/) }
      it { should contain_exec('run sample with docker').with_command(/-c 4/) }
      it { should contain_exec('run sample with docker').with_command(/--restart="on-failure:3"/) }
      it { should contain_exec('run sample with docker').with_command(/base command/) }
      it { should contain_exec('run sample with docker').with_timeout(0) }
    end

    context 'when `docker_service` is false' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'docker_service' => false} }
      it { should compile.with_all_deps }
			it { should contain_service('docker-sample') }
    end

    context 'when `docker_service` is true' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'docker_service' => true} }
			let(:pre_condition) { "service { 'docker': }" }
      it { should compile.with_all_deps }
			it { should contain_service('docker').that_comes_before('Service[docker-sample]') }
			it { should contain_service('docker').that_notifies('Service[docker-sample]') }
    end

    context 'when `docker_service` is true and `restart_service_on_docker_refresh` is false' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'docker_service' => true, 'restart_service_on_docker_refresh' => false} }
			let(:pre_condition) { "service { 'docker': }" }
      it { should compile.with_all_deps }
			it { should contain_service('docker').that_comes_before('Service[docker-sample]') }
    end

    context 'when `docker_service` is `my-docker`' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'docker_service' => 'my-docker'} }
			let(:pre_condition) { "service{ 'my-docker': }" }
      it { should compile.with_all_deps }
			it { should contain_service('my-docker').that_comes_before('Service[docker-sample]') }
			it { should contain_service('my-docker').that_notifies('Service[docker-sample]') }
    end

    context 'when `docker_service` is `my-docker` and `restart_service_on_docker_refresh` is false' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'docker_service' => 'my-docker', 'restart_service_on_docker_refresh' => false} }
			let(:pre_condition) { "service{ 'my-docker': }" }
      it { should compile.with_all_deps }
			it { should contain_service('my-docker').that_comes_before('Service[docker-sample]') }
    end

    context 'with extra_systemd_parameters' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'extra_systemd_parameters' => { 'Service' => {'RestartSec' => 5}}} }
      if (systemd)
        it { should contain_file(initscript).with_content(/^RestartSec=5$/) }
      end
    end

    context 'with ensure absent' do
      let(:params) { {'ensure' => 'absent', 'command' => 'command', 'image' => 'base'} }
      it { should compile.with_all_deps }
      it { should contain_service('docker-sample').with_ensure(false) }
      it { should contain_exec("remove container docker-sample").with_command('docker rm -v sample') }
    end

  end
  end

end
