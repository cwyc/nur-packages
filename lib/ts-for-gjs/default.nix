{stdenv, nodejs, python3, automake, fetchFromGitHub, callPackage, lib}:
{
	name ? "ts-for-gjs", #name of the derivation
	sources, #derivations containing gir files
	modules ? null, #names of the modules (i.e. Gtk-3.0 for Gtk-3.0.gir) to generate definitions for, or null to generate definitions for all available libraries
	ignore ? [], #names of the modules not to generate
	prettify ? true, #whether to prettify the output typescript files
	environment ? "both" #"gjs" for gjs runtime, "node" for node-gtk runtime, or "both" for both
}:
let
	nodeDependencies = (callPackage ./package/default.nix {}).shell.nodeDependencies;
	librariesString = 
		builtins.concatStringsSep 
			" " 
			(map 
				(path: "-g " + path) 
				sources);
	namesString = 
		if (modules == null)
			then ''"*"''
			else (builtins.concatStringsSep " " modules);
	ignoreString =
		builtins.concatStringsSep 
			" " 
			(map 
				(name: "-i " + name) 
				ignore);
	environmentString =
		if environment == "gjs" then "-e gjs"
		else if environment == "node" then "-e node"
		else if environment == "both" then ""
		else throw ''"environment" must be "gjs", "node", or "both"'';
in 
lib.makeOverridable stdenv.mkDerivation {
	name = name;
	src = fetchFromGitHub {
      owner = "sammydre";
      repo = "ts-for-gjs";
      rev = "6e2ad562a5df18ef4e1667ef4dd6dfbe2ef77cc9";
      sha256 = "0m6wbasr4pahwn4cr3c25p6f3xv697zygnih1p8y0n9m7x8zssnd";
      fetchSubmodules = true;
    };
	buildInputs = [nodejs python3 automake];
	buildPhase = ''

		ln -s ${nodeDependencies}/lib/node_modules ./node_modules
		export PATH="${nodeDependencies}/bin:$PATH"

		mkdir -p $out
		npm run start -- generate ${namesString} ${librariesString} -o $out ${if prettify then "--pretty" else ""} ${environmentString} --ignoreConflicts
	'';
	dontInstall = true;
	dontFixup = true;
	dontCopyDist = true;
}