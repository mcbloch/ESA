{-
    Resources
    ---
    Prelude documentation : https://store.dhall-lang.org/Prelude-v21.1.0/
    Language spec : https://docs.dhall-lang.org/tutorials/Language-Tour.html
    Site with examples : https://dhall-lang.org/
    Why I don't use yaml : https://noyaml.com/
-}

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

let HostVarsType = < MV : types.MetalVars | CV : types.ContainerVars >

let HostVars = { mapKey : Text, mapValue : HostVarsType }

let type_containers = List types.Container.Type

let type_container_entry = { mapKey : Text, mapValue : types.Container.Type }

let type_container_map = List type_container_entry

let toMetalHostVars =
      λ(metal : types.Metal.Type) →
        { mapKey = metal.name
        , mapValue =
            HostVarsType.MV
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

let toContainerHostVars =
      λ(container : types.Container.Type) →
        { mapKey = container.name
        , mapValue = HostVarsType.CV { name = container.name }
        }

let GroupVars =
      { mapKey : Text
      , mapValue : { hosts : List { mapKey : Text, mapValue : List Text } }
      }

let toAppGroups =
      λ(app : types.Application) →
        { mapKey = app.name
        , mapValue.hosts
          =
            Prelude.List.map
              types.Container.Type
              { mapKey : Text, mapValue : List Text }
              ( λ(c : types.Container.Type) →
                  { mapKey = c.name, mapValue = [] : List Text }
              )
              app.containers
        }

let toMetalGroups =
      λ(metals : List types.Metal.Type) →
        [ { mapKey = "metal"
          , mapValue.hosts
            =
              Prelude.List.map
                types.Metal.Type
                { mapKey : Text, mapValue : List Text }
                ( λ(m : types.Metal.Type) →
                    { mapKey = m.name, mapValue = [] : List Text }
                )
                metals
          }
        ]

let toHostVars =
      λ(config : types.Config) →
        { all =
          { hosts =
                Prelude.List.map
                  types.Metal.Type
                  HostVars
                  toMetalHostVars
                  config.metals
              # Prelude.List.map
                  types.Container.Type
                  HostVars
                  toContainerHostVars
                  config.containers
          , children =
                Prelude.List.map
                  types.Application
                  GroupVars
                  toAppGroups
                  config.applications
              # toMetalGroups config.metals
          }
        }

let defaultSshIdentityFile = λ(m : types.Metal.Type) → "files/private/${m.name}"

let toSshConfig =
      λ(ms : List types.Metal.Type) →
            Prelude.Text.concatMapSep
              "\n\n"
              types.Metal.Type
              ( λ(m : types.Metal.Type) →
                      ''
                      Host ${m.name}
                        HostName ${m.ssh_config.hostname}
                        User ${m.ssh_config.user}
                        Port ${Natural/show m.ssh_config.port}
                        IdentityFile ${m.ssh_config.identity_file}
                      ''
                  ++  "\n"
                  ++  Prelude.Optional.default
                        Text
                        ""
                        ( Prelude.Optional.map
                            (List types.Container.Type)
                            Text
                            ( λ(containers : List types.Container.Type) →
                                Prelude.Text.concatMapSep
                                  "\n"
                                  types.Container.Type
                                  ( λ(c : types.Container.Type) →
                                      ''
                                      Host ${c.name}
                                        HostName ${c.ssh_config.hostname}
                                        User ${c.ssh_config.user}
                                        Port ${Natural/show c.ssh_config.port}
                                        IdentityFile ${c.ssh_config.identity_file}
                                        ProxyJump ${m.name}
                                      ''
                                  )
                                  containers
                            )
                            m.lxc_containers
                        )
              )
              ms
        ++  ''


            Host *
              LogLevel FATAL
              PasswordAuthentication no
              IdentitiesOnly yes
            ''

in  { hostVars = toHostVars config, ssh_config = toSshConfig config.metals }
