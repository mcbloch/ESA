let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:eb693342eb769f782174157eba9b5924cf8ac6793897fc36a31ccbd6f56dafe2

let types = ./types.dhall

let config = ./config.dhall

let validations = ./validations.dhall

let validateConfig =
      λ(config : types.Config) →
        let validMetals = validations.validateMetals config.metals

        in  { validMetals }

let validate = assert : validateConfig config ≡ { validMetals = True }

let type_containers = List types.Container.Type

let type_container_entry = { mapKey : Text, mapValue : types.Container.Type }

let type_container_map = List type_container_entry

let toMetalHostVars =
      λ(metal : types.Metal.Type) →
        { mapKey = metal.name
        , mapValue =
          { name = metal.name
          , lxc_containers =
              Prelude.Optional.map
                type_containers
                type_container_map
                ( λ(lxc_containers : type_containers) →
                    Prelude.List.map
                      types.Container.Type
                      type_container_entry
                      ( λ(c : types.Container.Type) →
                          Prelude.Map.keyValue types.Container.Type c.name c
                      )
                      lxc_containers
                )
                metal.lxc_containers
          , port_forwards = metal.port_forwards
          }
        }

let toHostVars =
      λ(config : types.Config) →
        { all.hosts
          =
            Prelude.List.map
              types.Metal.Type
              { mapKey : Text, mapValue : types.MetalVars }
              toMetalHostVars
              config.metals
        }

let defaultSshIdentityFile = λ(m : types.Metal.Type) → "files/private/${m.name}"

let toSshConfig =
      λ(ms : List types.Metal.Type) →
            Prelude.Text.concatMapSep
              "\n"
              types.Metal.Type
              ( λ(m : types.Metal.Type) →
                  ''
                  Host ${m.name}
                    HostName ${m.ssh_config.hostname}
                    User ${m.ssh_config.user}
                    Port ${Natural/show m.ssh_config.port}
                    IdentityFile ${m.ssh_config.identity_file}
                  ''
              )
              ms
        ++  ''


            Host *
              LogLevel FATAL
              PasswordAuthentication no
              IdentitiesOnly yes
            ''

in  { hostVars = toHostVars config, ssh_config = toSshConfig config.metals }
