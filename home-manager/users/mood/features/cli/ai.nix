{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    github-copilot-cli
    codex
    opencode
  ];

  programs.claude-code = {
    enable = true;
  };
}
