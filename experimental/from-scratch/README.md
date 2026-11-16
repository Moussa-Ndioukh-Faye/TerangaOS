# Build « from scratch » (expérimental)

Ces scripts (toolchain GCC, noyau Linux, rootfs BusyBox, ISO manuelle) sont une
piste d'apprentissage, **pas** la méthode de build de TérangaOS 1.0.

Ils ne fonctionnent pas en l'état : ils attendent les sources amont (gcc,
glibc, linux, busybox…) dans des dossiers qui ne sont volontairement pas dans
le dépôt (plusieurs gigaoctets). Pour construire TérangaOS, utilisez
`build.sh` ou `build-docker.sh` à la racine.
