{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    tinyusb_src.url = "git+https://github.com/hathach/tinyusb.git?ref=refs/tags/0.14.0&submodules=1";
    tinyusb_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, tinyusb_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        examples = [
          "audio_4_channel_mic"
          "audio_test"
          "board_test"
          "cdc_dual_ports"
          "cdc_msc"
          "cdc_msc_freertos"
          "dfu"
          "dfu_runtime"
          "dynamic_configuration"
          "hid_boot_interface"
          "hid_composite"
          "hid_composite_freertos"
          "hid_generic_inout"
          "hid_multiple_interface"
          "midi_test"
          "msc_dual_lun"
          "net_lwip_webserver"
          "uac2_headset"
          "usbtmc"
          "video_capture"
          "webusb_serial"
        ];

        boards = [
          "stm32f103_bluepill"
          "stm32f401blackpill"
        ];

        mkTinyusbExample = (board: example:
          pkgs.stdenv.mkDerivation rec {
            name = "tinyusb-${board}-${example}";

            src = tinyusb_src;

            buildPhase = ''
              cd examples/device/${example}
              make BOARD=${board}
            '';

            installPhase = ''
              mkdir -p $out/bin/
              cp _build/${board}/${example}.bin $out/bin/
              cp _build/${board}/${example}.hex $out/bin/
              cp _build/${board}/${example}.elf $out/bin/
            '';

            buildInputs = with pkgs; [
              gcc-arm-embedded
            ];
          }
        );
      in {
        packages =
          (builtins.listToAttrs
            (builtins.concatLists
            (map (board:
              (map (example:
                let
                  pkg = mkTinyusbExample board example;
                in
                  {
                    name = pkg.name;
                    value = pkg;
                  })
                examples))
              boards)
            )
          );
      }
    );
}
