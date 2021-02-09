{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
}:

buildPythonPackage rec {
  pname = "aquirdturtle_collapsible_headings";
  version = "3.0.1";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15zbbp7zhvx4a3z6y372k9kby6hfsd7psc0q6j3nkwkxi529dmjl";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab ];

  meta = with lib; {
    description = "Make headings collapsible like the old Jupyter notebook extension and like mathematica notebooks.";
    homepage = "https://pypi.org/project/aquirdturtle-collapsible-headings/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
