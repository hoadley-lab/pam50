# https://github.com/NixOS/nixpkgs/issues/177908#issuecomment-1495625986
{ pkgs, contents, name, runscript ? ''
  #!/bin/sh
  bash'' }:
pkgs.runCommand "make-container" { } ''
  set -o pipefail
  closureInfo=${
    pkgs.closureInfo { rootPaths = contents ++ [ pkgs.bashInteractive ]; }
  }
  mkdir -p r/{bin,etc,dev,proc,sys,usr,tmp,.singularity.d/{actions,env,libs}}
  pushd r
  cp -na --parents $(cat $closureInfo/store-paths) .
  touch etc/{passwd,group}
  ln -s /bin usr/
  ln -s ${pkgs.bashInteractive}/bin/bash bin/sh
  for p in ${pkgs.lib.concatStringsSep " " contents}; do
    ln -sn $p/bin/* bin/ || true
  done
  echo "${runscript}" >.singularity.d/runscript
  chmod +x .singularity.d/runscript
  popd
  mkdir $out
  ${pkgs.squashfsTools}/bin/mksquashfs r $out/${name}.sqfs -no-hardlinks -all-root
''
