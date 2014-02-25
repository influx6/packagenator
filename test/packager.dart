library packagenator.spec;

import 'package:hub/hub.dart';
import 'package:packagenator/packagenator.dart';

void main(){

	Packager.findInstalled('streamable').then((pac){
		pac.listVersions().then(print);
		pac.versions.hasVersion('0.1.5').catchError(print);
	});


}