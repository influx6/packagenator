part of packagenator.core;

/*
	handles version trival and production for library files
	major desire is to use format:
	librartFolder
		version1
		version2
		version3

	version will follow linux 3 digits minor signatur major.minor.minor i.e 0.0.1
*/

final RegExp excessSpace = new RegExp(r'\s+');
final RegExp _degree = new RegExp(r'(^[<|>]=?)?\s*([\d+\.*]+)');

class Versionator{
	Future<fs.GuardedDirectory> dir;

	static bool validVersionNumber(String ver){
		var state = _degree.hasMatch(ver);
		if(!state) return false;

		var find = _degree.firstMatch(ver);
		var tag = find.group(1);
		var region = find.group(2);

		if(region.split('.').length > 3) return false;

		return true;
	}

	static create() => new Versionator();

	Versionator();

	void use(dir){
		this.dir = dir;
	}

	Future retrieveVersions(){
		return this.retrieveVersionPaths().then((versions){
			return Enums.map(versions,(e,i,o) => paths.basename(e));
		});
	}

	Future retrieveVersionPaths(){
		return Funcs.when(Valids.exist(this.dir),(){
			return this.dir.then((dir){
				var f = new Completer(), versions = [];
				var stream = dir.directoryListsAsString();
				stream.on(Funcs.compose(versions.add,paths.normalize));
				stream.whenEnded((n){
					f.complete(versions);
				});
				return f.future;
			});
		},(){
			return new Future.error(new Exception('Versionator not ready!'));
		});
	}

	Future validateVersion(String version){
		return this.retrieveVersions().then((vers){
		  var deg = _degree.firstMatch(version);
		  var type = deg.group(1);
		  var region = deg.group(2);

		  return this.filterBase(region,vers,type);
		});
	}

	
	Future hasVersion(String version){
		return this.validateVersion(version).then((set){
			if(set.isEmpty) return false;
			return true;
		});
	}

	List filterBase(String reg,List versions,[String grip]){
		var r = Enums.map(reg.split('.').sublist(0, 3),(e,i,o) => int.parse(e));
		return Enums.filterValues(versions,(e,i,o){
			var state = false,
				f = Enums.map(e.split('.').sublist(0, 3),(e,i,o) => int.parse(e));

			Funcs.when((grip == '' || grip == null),(){
				if(e == r.join('.')) state = true;
			});

			Funcs.when((grip == '<'),(){
				if(Enums.first(f) <= Enums.first(r) && Enums.second(f) <= Enums.second(r) && Enums.third(f) < Enums.third(r)) 
					state = true;
			});

			Funcs.when((grip == '<='),(){
				if(Enums.first(f) <= Enums.first(r) && Enums.second(f) <= Enums.second(r) && Enums.third(f) <= Enums.third(r)) 
					state = true;
			});

			Funcs.when((grip == '>'),(){
				state = (Enums.first(f) > Enums.first(r) ? true : (Enums.second(f) > Enums.second(r) ? true : (Enums.third(f) > Enums.third(r) ? true : false)));
			});


			Funcs.when((grip == '>='),(){
				state = (Enums.first(f) > Enums.first(r) ? true : 
					(Enums.first(f) == Enums.first(r) && (Enums.second(f) > Enums.second(r) ? true : (Enums.second(f) == Enums.second(r) && 
					Enums.third(f) >= Enums.third(r) ? true : false))));

			});

			return state;
		});
	}

	void close(){
		this.dir = null;
	}
}
