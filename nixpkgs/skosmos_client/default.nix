{ lib
, buildPythonPackage
, fetchPypi
, rdflib
, requests
}:

buildPythonPackage rec {
  pname = "skosmos-client";
  version = "0.3.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "121drkk5mjsaxcdja43bacr57zzmm99s54ylyjw4iv46sxyj925y";
  };

  propagatedBuildInputs = [
    rdflib
    requests
  ];

  doCheck = true;

  meta = with lib; {
    description = "Client library for accessing Skosmos REST API endpoints";
    homepage = "https://github.com/NatLibFi/Skosmos-client";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ ariutta ];
  };
}
