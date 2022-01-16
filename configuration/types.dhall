let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:eb693342eb769f782174157eba9b5924cf8ac6793897fc36a31ccbd6f56dafe2

let SshConfig =
      { Type =
          { hostname : Text, user : Text, port : Natural, identity_file : Text }
      , default =
        { hostname = "127.0.0.1", user = "root", port = 22, identity_file = "" }
      }

let ContainerVars = { name : Text }

let Container =
      { Type =
          { name : Text
          , distro : Text
          , release : Text
          , arch : Text
          , store : Text
          , ssh_config : SshConfig.Type
          }
      , default =
        { distro = "debian"
        , release = "buster"
        , arch = "amd64"
        , store = "dir"
        , ssh_config = SshConfig.default
        }
      }

let ApplicationVars = { users : List Text }

let Application =
      { name : Text, users : List Text, containers : List Container.Type }

let PortForward =
      { host_port : Natural, container_port : Natural, container_name : Text }

let MetalVars =
      { name : Text
      , lxc_containers :
          Optional (List { mapKey : Text, mapValue : Container.Type })
      , port_forwards : Optional (List PortForward)
      }

let Metal =
      { Type =
          { name : Text
          , lxc_containers : Optional (List Container.Type)
          , port_forwards : Optional (List PortForward)
          , ssh_config : SshConfig.Type
          }
      , default =
        { lxc_containers = None (List Container.Type)
        , port_forwards = None (List PortForward)
        , ssh_config = SshConfig.default
        }
      }

let Config =
      { containers : List Container.Type
      , metals : List Metal.Type
      , applications : List Application
      }

in  { Container
    , ContainerVars
    , ApplicationVars
    , Application
    , PortForward
    , Metal
    , MetalVars
    , Config
    , SshConfig
    }
