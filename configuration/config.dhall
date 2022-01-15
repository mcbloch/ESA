let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:eb693342eb769f782174157eba9b5924cf8ac6793897fc36a31ccbd6f56dafe2

let types = ./types.dhall

let c1 =
      types.Container::{
      , name = "simple-web-01"
      , distro = "debian"
      , release = "buster"
      , arch = "amd64"
      , store = "dir"
      }

let c2 = types.Container::{ name = "ruby-web-01" }

let machine1 =
      types.Metal::{
      , name = "machine1"
      , lxc_containers = Some [ c1, c2 ]
      , port_forwards = Some
        [ { host_port = 8321, container_port = 80, container_name = c1.name }
        , { host_port = 8322, container_port = 80, container_name = c2.name }
        ]
      , ssh_config = types.SshConfig::{
        , hostname = "127.0.0.1"
        , user = "vagrant"
        , port = 2222
        , identity_file = ".vagrant/machines/machine1/virtualbox/private_key"
        }
      }

let machine2 =
      types.Metal::{
      , name = "zeus-king"
      , ssh_config = types.SshConfig::{
        , hostname = "zeus.ugent.be"
        , port = 2222
        , user = "root"
        , identity_file = "~/.ssh/id_ed25519_zeus"
        }
      }

in  { containers = [ c1, c2 ], metals = [ machine1, machine2 ] } : types.Config
