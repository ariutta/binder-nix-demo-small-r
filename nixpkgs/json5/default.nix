{ lib, buildPythonPackage, fetchPypi, hypothesis }:

buildPythonPackage rec {
  pname = "json5";
  version = "0.9.5";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15nvdg8a8al1hfnqwdfwf64xkc64lsmcdqcjdaspc1br83jzwg3h";
  };

  propagatedBuildInputs = [ hypothesis ];

  # there's a problem with finding the file sample.json5
  doCheck = false;

  meta = {
    description = "A Python implementation of the JSON5 data format.";
    longDescription = ''
      A Python implementation of the JSON5 data format.

      JSON5 extends the JSON data interchange format to make it slightly more usable as a configuration language:
          * JavaScript-style comments (both single and multi-line) are legal.
          * Object keys may be unquoted if they are legal ECMAScript identifiers
          * Objects and arrays may end with trailing commas.
          * Strings can be single-quoted, and multi-line string literals are allowed.
      '';
    homepage = "https://pypi.org/project/json5/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
