library packagenator.core;

import 'package:hub/hub.dart';
import 'package:streamable/streamable.dart' as streams;

class Commandator{
	final MapDecorator commands = new MapDecorator();

	static create() => new Commandator();

	Commandator(){
		this.add('default');
	}

	streams.Distributor command(String com) => this.commands.get(com);

	void add(String command){
		this.commands.add(command,streams.Distributor.create(command));
	}

	void remove(String command){
		if(!this.commands.has(command)) return null;
		var com = this.commands.remove(command);
		com.free();
	}

	void fire(String command,List n){
		if(!this.commands.has(command)) return this.commands.get('default').emit(n);
		this.commands.get(command).emit(n);
	}

	void on(String command,Function n){
		if(!this.commands.has(command)) return null;
		this.command(command).on(n);
	}

	void once(String command,Function n){
		if(!this.commands.has(command)) return null;
		this.command(command).once(n);
	}

	void off(String command,Function n){
		if(!this.commands.has(command)) return null;
		this.command(command).off(n);
	}


	void analyze(List<String> args){
		if(args.length <= 0)  return;

		var finder = Enums.nthFor(args);
		this.fire(finder(0),args.sublist(1,args.length));
	}

}