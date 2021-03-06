{- let machine2 =
      types.Metal::{
      , name = "zeus-king"
      , ssh_config = types.SshConfig::{
        , hostname = "zeus.ugent.be"
        , port = 2222
        , user = "root"
        , identity_file = "~/.ssh/id_ed25519_zeus"
        }
      } -}
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
      , ssh_config = types.SshConfig::{
        , hostname = "192.168.122.125"
        , identity_file = "~/.ssh/id_ed25519_common"
        }
      }

let c2 =
      types.Container::{
      , name = "ruby-web-01"
      , ssh_config = types.SshConfig::{
        , hostname = "192.168.122.249"
        , identity_file = "~/.ssh/id_ed25519_common"
        }
      }

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

let a1
    : types.Application
    = { name = "simple_web", users = [ "maxime" ], containers = [ c1 ] }

let a2
    : types.Application
    = { name = "ruby_web", users = [ "maxime" ], containers = [ c2 ] }

in    { containers = [ c1, c2 ]
      , metals = [ machine1 ]
      , applications = [ a1, a2 ]
      }
    : types.Config
