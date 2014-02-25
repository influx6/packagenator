library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(){

	var ver = Versionator.create();
	ver.use(Packager.packages.Dir('./streamable'));
	ver.retrieveVersions().then(print);

	ver.hasVersion('< 0.1.6').catchError(print);
	ver.hasVersion('<= 0.1.4').catchError(print);
	ver.hasVersion('0.1.5').catchError(print);
	ver.hasVersion('> 0.1.5').catchError(print);
	ver.hasVersion('>= 0.1.5').catchError(print);


}