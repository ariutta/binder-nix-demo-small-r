{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, jinja2
, tornado
, pyzmq
, ipython_genutils
, traitlets
, jupyter_core
, jupyter_client
, nbformat
, nbconvert
, send2trash
, terminado
, prometheus_client
, anyio
}:

buildPythonPackage rec {
  pname = "jupyter_server";
  version = "1.2.2";
  name = "${pname}-${version}";
  format = "pyproject";
  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1bikk47ihyjipzk7wx8yjyi3rym8a31qcm9120gbv3jvqkaqra96";
  };

  # not sure why it's complaining about this
  # I think I have anyio 2.0.2 installed
  patchPhase = ''
    substituteInPlace setup.py --replace 'anyio>=2.0.2' 'anyio'
  '';

  propagatedBuildInputs = [
    jinja2
    tornado
    pyzmq
    ipython_genutils
    traitlets
    jupyter_core
    jupyter_client
    nbformat
    nbconvert
    send2trash
    terminado
    prometheus_client
    anyio
  ];

  doCheck = true;

  meta = with lib; {
    description = "The backend—i.e. core services, APIs, and REST endpoints—to Jupyter web applications.";
    longDescription = "The Jupyter Server provides the backend (i.e. the core services, APIs, and REST endpoints) for Jupyter web applications like Jupyter notebook, JupyterLab, and Voila.";
    homepage = "https://github.com/jupyter/jupyter-server";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
