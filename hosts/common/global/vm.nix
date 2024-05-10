{...}: {
  users.users.nixosvmtest.isSystemUser = true;
  users.users.nixosvmtest.initialPassword = "test";

  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};
}
