{
  inputs,
  ...
}:
{
  imports = [ inputs.self.nixosModules.hosts ];

  myHosts = {
    dra = {
      builder = {
        hostName = "dra";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        sshUser = "nixremote";
        sshKey = "/root/.ssh/nixremote_ed25519";
        maxJobs = 8;
        speedFactor = 100;
      };
      builderPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOQfH0CHIoSzBVup9mtNVOeueijcOTe3CfuK722bs+0 nixremote@dra";
    };
    tau = {
      builder = {
        hostName = "tau";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        sshUser = "nixremote";
        sshKey = "/root/.ssh/nixremote_ed25519";
        maxJobs = 6;
        speedFactor = 60;
      };
      builderPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJWtBuskyuxnvNNzCxiEWzhTpmDFAOf0g5KCizl/9xko nixremote@tau";
    };
    lyr = {
      builder = {
        hostName = "lyr";
        protocol = "ssh-ng";
        system = "x86_64-linux";
        sshUser = "nixremote";
        sshKey = "/root/.ssh/nixremote_ed25519";
        maxJobs = 4;
        speedFactor = 1;
      };
      builderPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKVBFuFoBVuTT0M6lX81FLkFBseMV7T1NEmTzZXBmA5i nixremote@lyr";
    };
  };
}
