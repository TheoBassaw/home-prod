machine:
  install:
    image: factory.talos.dev/metal-installer-secureboot/{{ env "SCHEMATIC_ID" }}:v{{ .TalosVersion }}
