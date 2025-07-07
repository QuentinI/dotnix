{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  llm,
  httpx,
  pytestCheckHook,
  jsonschema,
}:

buildPythonPackage {
  pname = "llm-cerebras";
  version = "0.1.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "irthomasthomas";
    repo = "llm-cerebras";
    rev = "6a2e48850179067ab4312a7ccd4fdc77480e6ec7";
    hash = "sha256-Ffs0/0JpW15PIUHdWor9mFX03EXOOLZRRzqFz4O3sQk=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    llm
    httpx
    jsonschema
  ];

  doCheck = false;

  meta = {
    description = "Plugin for LLM adding fast Cerebras inference API support";
    homepage = "https://github.com/irthomasthomas/llm-cerebras";
    changelog = "https://github.com/irthomasthomas/llm-cerebras/releases";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
