{ pkgs ? import <nixpkgs> {} }:

# nix-shell -A atributte-name

let
  riscv-pkgs = import <nixpkgs> {
    crossSystem = (import <nixpkgs/lib>).systems.examples.riscv32-embedded;
  };
in
{
  vhdl = pkgs.mkShell { # VHDL
    buildInputs = [
      pkgs.ghdl
      pkgs.gtkwave
    ];
  };

  riscv = pkgs.mkShell { # cross-compiling
    nativeBuildInputs = [
      riscv-pkgs.stdenv.cc  # Traz o riscv32-none-elf-gcc, ld, as, etc.
      pkgs.qemu             # Emulador para RISC-V
    ];
  };

  default = pkgs.mkShell { # unified
    nativeBuildInputs = [
      riscv-pkgs.stdenv.cc
      pkgs.qemu
    ];
    
    buildInputs = [
      pkgs.ghdl
      pkgs.gtkwave
    ];
  };
}
