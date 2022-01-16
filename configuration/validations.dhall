{-
  https://discourse.dhall-lang.org/t/config-validations/296/2
-}
let Prelude =
      https://prelude.dhall-lang.org/v21.1.0/package.dhall
        sha256:eb693342eb769f782174157eba9b5924cf8ac6793897fc36a31ccbd6f56dafe2

let types = ./types.dhall

let validatePortForwardList =
      \(pfs : List types.PortForward) ->
        let extract_metal_pf_host_ports =
              Prelude.List.map
                types.PortForward
                Natural
                (\(pf : types.PortForward) -> pf.host_port)

        let metal_pf_host_ports
            : List Natural
            = extract_metal_pf_host_ports pfs

        let NaturalIndexed = { index : Natural, value : Natural }

        let take_after =
              \(duo : NaturalIndexed) ->
                Prelude.List.drop (duo.index + 1) Natural metal_pf_host_ports

        let host_port_used_multiple_times =
              Prelude.List.any
                NaturalIndexed
                ( \(duo : NaturalIndexed) ->
                    Prelude.List.any
                      Natural
                      ( \(other : Natural) ->
                          Prelude.Natural.equal duo.value other
                      )
                      (take_after duo)
                )
                (Prelude.List.indexed Natural metal_pf_host_ports)

        in  host_port_used_multiple_times == False

let validateMetalPortsOpt =
      \(metal : types.Metal.Type) ->
        Prelude.Optional.default
          Bool
          True
          ( Prelude.Optional.map
              (List types.PortForward)
              Bool
              (\(pfs : List types.PortForward) -> validatePortForwardList pfs)
              metal.port_forwards
          )

let validateMetal = \(metal : types.Metal.Type) -> validateMetalPortsOpt metal

let validateMetals =
      \(metals : List types.Metal.Type) ->
        Prelude.List.all
          types.Metal.Type
          (\(metal : types.Metal.Type) -> validateMetal metal)
          metals

in  { validateMetals }
