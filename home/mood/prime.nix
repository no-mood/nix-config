{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global

    ./features/utilities
    ./features/cli
    ./features/browser
    ./features/desktop
    #./features/coding
    #./features/devices
    #./features/hacking
    #./features/virtualization
    #./features/gaming
  ];
}
