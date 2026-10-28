# libhwy's googletest suite segfaults during CMake test discovery on i686 (GCC 16),
# breaking 32-bit consumers such as bottles' FHS env. Hydra does not build i686 libhwy,
# so it is built locally. Tests are only built when doCheck is set (HWY_ENABLE_TESTS).
# Remove once the i686 build passes upstream.
final: prev: {
  libhwy =
    if final.stdenv.hostPlatform.isx86_32 then
      prev.libhwy.overrideAttrs { doCheck = false; }
    else
      prev.libhwy;
}
