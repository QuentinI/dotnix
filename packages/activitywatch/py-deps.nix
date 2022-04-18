{ python3, lib, ... }:
{
  persist-queue = python3.pkgs.buildPythonPackage rec {
    version = "0.6.0";
    pname = "persist-queue";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "5z3WJUXTflGSR9ljaL+lxRD95mmZozjW0tRHkNwQ+Js=";
    };

    checkInputs = with python3.pkgs; [
      msgpack
      nose2
    ];

    checkPhase = ''
      runHook preCheck
      nose2
      runHook postCheck
    '';

    meta = with lib; {
      description = "Thread-safe disk based persistent queue in Python";
      homepage = "https://github.com/peter-wangxu/persist-queue";
      license = licenses.bsd3;
    };
  };

  TakeTheTime = python3.pkgs.buildPythonPackage rec {
    pname = "TakeTheTime";
    version = "0.3.1";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "2+MEU6G1lqOPni4/qOGtxa8tv2RsoIN61cIFmhb+L/k=";
    };

    checkInputs = [
      python3.pkgs.nose
    ];

    doCheck = false; # tests not available on pypi

    checkPhase = ''
      runHook preCheck
      nosetests -v tests/
      runHook postCheck
    '';

    meta = with lib; {
      description = "Simple time taking library using context managers";
      homepage = "https://github.com/ErikBjare/TakeTheTime";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mit;
    };
  };

  timeslot = python3.pkgs.buildPythonPackage rec {
    pname = "timeslot";
    version = "0.1.2";

    src = python3.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "oqyZhlfj87nKkodXtJBq3SwFOQxfwU7XkruQKNCFR7E=";
    };

    meta = with lib; {
      description = "Data type for representing time slots with a start and end";
      homepage = "https://github.com/ErikBjare/timeslot";
      maintainers = with maintainers; [ jtojnar ];
      license = licenses.mit;
    };
  };
}
