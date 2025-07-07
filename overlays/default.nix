self: super: {
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      llm-cerebras = python-self.callPackage ../packages/llm-cerebras.nix { };
    };
  };
  python3Packages = self.python3.pkgs;
}
